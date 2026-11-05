# Especificação 01 — Protocolo de sincronização

Complementa a seção 7.4 da proposta técnica (`entrega-basica/AgroManejo-Entrega-Basica.md`). Define o comportamento necessário para implementar a sincronização entre o SQLite do aparelho e o PostgreSQL (Supabase) sem perda nem duplicação de dados.

## 1. Princípios

1. **O aparelho é a fonte de trabalho; o servidor é a fonte de verdade compartilhada.** O produtor lê e grava sempre no SQLite. O servidor decide se uma alteração é aceita.
2. **O relógio do aparelho nunca decide nada.** Ordem, versão e cursor vêm do servidor.
3. **Toda operação pode ser repetida sem efeito colateral** (idempotência).
4. **Nenhuma alteração é sobrescrita sem que o produtor a tenha visto.**

## 2. Unidades de sincronização

| Unidade | Conteúdo | Observação |
|---|---|---|
| Unidade de manejo | Dados da unidade **e** todos os seus vértices | Bloco único: o contorno inteiro é aceito ou recusado junto. Os vértices nunca são sincronizados isoladamente. |
| Atividade | Todos os campos da atividade | Independente da unidade; referencia a unidade pelo identificador. |

## 3. Estado de cada registro no aparelho

| Situação | Significado | Pode ser editado? |
|---|---|---|
| SINCRONIZADO | Igual à versão do servidor. | Sim (passa a PENDENTE) |
| PENDENTE | Alterado no aparelho e ainda não aceito pelo servidor. | Sim |
| CONFLITO | O servidor tem uma versão mais nova feita em outro aparelho. | **Não**, até o produtor resolver (UC10) |
| REJEITADO | O servidor recusou por regra de validação. O motivo fica registrado. | Sim (a correção volta a PENDENTE) |

Cada registro guarda também:

- **versão-base:** a versão do servidor sobre a qual a edição foi feita (nula em registros novos);
- **identificador da operação pendente:** um UUID gerado quando o registro passa a PENDENTE e regenerado a cada nova edição local. Garante a idempotência.

O bloqueio de edição em CONFLITO evita conflitos sobre conflitos, que o produtor não conseguiria entender.

## 4. Ciclo de sincronização

**Gatilhos:**

- conexão restabelecida;
- aplicativo trazido para o primeiro plano;
- 5 segundos após a última gravação local, com conexão;
- fim do login.

Só um ciclo roda por vez; um gatilho durante um ciclo agenda o próximo.

**Ordem:**

1. Renovar a sessão, se o token estiver vencido.
2. **Envio** (seção 5), em lotes de até 100 registros PENDENTE.
3. **Recebimento** (seção 6), em páginas de até 500 alterações, até não haver mais.
4. Gravar o horário do último ciclo bem-sucedido, informado pelo servidor.

O envio vem antes do recebimento para que o conflito seja detectado pelo servidor, com versão, e não por sobrescrita local.

## 5. Envio de alterações

O aplicativo chama **uma função do banco** (RPC do Supabase), não as tabelas diretamente. Uma função do PostgreSQL executa dentro de uma transação, então a gravação da unidade com todos os vértices é atômica.

**Conteúdo do lote**, para cada registro:

- identificador do registro;
- identificador da operação;
- tipo (unidade ou atividade);
- versão-base;
- dados completos (para a unidade, inclui a lista ordenada de vértices).

O aplicativo também envia a sua **versão**.

**Processamento no servidor**, registro a registro, cada um isolado dos demais, para que um conflito não bloqueie o lote:

1. Se o identificador da operação já foi processado, devolver o mesmo resultado anterior (idempotência).
2. Conferir que o registro pertence ao produtor autenticado.
3. Validar:
   - polígono válido, reconstruído a partir dos vértices com as funções do PostGIS;
   - no mínimo 3 vértices;
   - campos obrigatórios presentes;
   - valores monetários não negativos.
4. Comparar a versão-base com a versão atual:
   - registro inexistente e versão-base nula → **inserir** com versão 1;
   - versões iguais → **gravar** e incrementar a versão;
   - versões diferentes → **conflito**: nada é gravado.
5. Para unidades: recalcular a área com o PostGIS e gravar esse valor, que passa a ser a área oficial.
6. Registrar a alteração no registro de alterações (seção 6) e o identificador da operação como processado.

**Resposta por registro:**

| Resultado | Dados devolvidos | Ação no aparelho |
|---|---|---|
| ACEITO | nova versão, área oficial (unidades) | SINCRONIZADO; versão-base = nova versão; atualizar a área |
| CONFLITO | versão atual do servidor | CONFLITO; manter a versão local intacta |
| REJEITADO | motivo da recusa | REJEITADO; mostrar o motivo ao produtor |

Se a resposta se perder (queda de conexão), o reenvio com o mesmo identificador de operação devolve o mesmo resultado, sem gravar de novo.

## 6. Recebimento de alterações (cursor)

**Problema a evitar:** um contador simples pode pular registros. Uma transação que começou antes pode terminar depois e ganhar um número menor que um cursor já lido.

**Mecanismo:**

- O servidor mantém um **registro de alterações**: cada gravação aceita gera uma linha com número sequencial, produtor, tipo, identificador do registro, nova versão e o **identificador da transação** que a gravou.
- O recebimento devolve apenas as alterações:
  - do produtor autenticado,
  - com número maior que o cursor do aparelho,
  - **cujas transações já terminaram antes do início de qualquer transação ainda em andamento.** No PostgreSQL 13 ou superior, isso usa as funções `pg_current_xact_id()`, `pg_current_snapshot()` e `pg_snapshot_xmin()`.

  Alterações de transações ainda abertas ficam para o ciclo seguinte, em vez de serem puladas.
- O aparelho guarda o maior número recebido como novo cursor, **só depois** de gravar a página localmente.

**Aplicação no aparelho:**

| Situação local do registro | O que acontece com a alteração recebida |
|---|---|
| Não existe ou SINCRONIZADO | Gravada; situação SINCRONIZADO |
| PENDENTE | **Não aplicada.** O próximo envio detectará o conflito pela versão. |
| CONFLITO | Não aplicada |
| Mesma versão já presente | Ignorada (repetição) |

O primeiro acesso em um aparelho é um recebimento com cursor zero, paginado, exibindo o progresso.

## 7. Resolução de conflito (UC10)

Mantém a regra já aprovada:

1. O aplicativo busca a versão atual do servidor e a exibe ao lado da local.
2. Depois da escolha do produtor, consulta de novo a versão do servidor.
3. Se for mantida a versão local, envia com versão-base igual à versão exibida. O servidor só aceita se ela ainda for a atual; se não for, o conflito é reapresentado.
4. Se for adotada a versão do servidor, ela substitui a local, que passa a SINCRONIZADO.

## 8. Tratamento de erros

| Situação | Comportamento |
|---|---|
| Sem conexão ou tempo esgotado | Nova tentativa automática com intervalos crescentes: 5 s, 15 s, 45 s, 2 min, até no máximo 10 min entre tentativas. |
| Sessão vencida | Renovar a sessão e repetir. Se a renovação falhar, pedir novo login **sem apagar** pendências. |
| Acesso negado (regra de acesso por linha) | Registro REJEITADO e erro registrado para diagnóstico. Indica defeito, não uso normal. |
| Versão do aplicativo incompatível | Interromper a sincronização e pedir atualização do aplicativo. Os dados locais continuam utilizáveis offline. |
| Erro inesperado do servidor | Tratar como falha de rede (nova tentativa) e registrar para diagnóstico. |

## 9. Compatibilidade de versões

- O servidor mantém a **versão mínima aceita do aplicativo**. Lotes de versões mais antigas são recusados com um código específico.
- Toda mudança de estrutura no servidor deve continuar aceitando a versão mínima vigente. Campos novos são opcionais até que todas as versões em uso os enviem.

## 10. Registro para diagnóstico

O aplicativo registra localmente, e envia quando houver conexão:

- falhas de sincronização (tipo, código, registro afetado);
- conflitos;
- rejeições.

Nenhum dado pessoal ou financeiro vai nesse registro, só identificadores e códigos.

## 11. Pontos a confirmar na implementação

- Comportamento transacional exato das chamadas RPC via API do Supabase (PostgREST). A página de documentação correspondente não pôde ser consultada nesta revisão.
- Tamanhos de lote e intervalos (100 / 500 / 5 s): valores iniciais, a ajustar com medições no protótipo.
