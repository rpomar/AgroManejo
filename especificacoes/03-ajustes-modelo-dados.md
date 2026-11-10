# Especificação 03 — Ajustes do modelo de dados

Complementa a seção 6 da proposta técnica. Lista as mudanças necessárias no modelo antes da criação das tabelas, para dar suporte à sincronização (especificação 01) e à segurança, considerando o aplicativo feito no MIT App Inventor, com armazenamento local no TinyDB.

## 1. Mudanças nas tabelas existentes

| Tabela | Mudança | Motivo |
|---|---|---|
| UNIDADE_MANEJO, VERTICE, ATIVIDADE | Acrescentar `produtor_id` em VERTICE e ATIVIDADE (UNIDADE_MANEJO já tem). | As regras de acesso por linha e as consultas de sincronização filtram direto pelo dono, sem consultar outra tabela. |
| Todas | Acrescentar `criado_em`, definido pelo servidor. | Auditoria e diagnóstico. |
| UNIDADE_MANEJO, ATIVIDADE | Manter `versao` e `atualizado_em`, ambos definidos **só** pelo servidor. | Controle de concorrência (especificação 01). |
| UNIDADE_MANEJO | `area_hectares` passa a ser **recalculada pelo servidor** (PostGIS) a cada gravação aceita. | Define a fonte da verdade da área. O valor do aparelho é provisório até a sincronização. |
| VERTICE | Sem `versao` própria; os vértices são regravados em bloco com a unidade. | O contorno é um bloco único. |
| ATIVIDADE | Custos e receita em reais com 2 casas decimais no servidor; **centavos como número inteiro** no aparelho. | Os números dos blocos do App Inventor são de ponto flutuante; somas em ponto flutuante geram diferenças de centavos. |
| VERTICE | Latitude e longitude com 6 casas decimais. | Precisão de cerca de 0,1 m, suficiente para GPS de celular. |

## 2. Regras de integridade (servidor)

- Valores monetários, tempo estimado e área: **nunca negativos**.
- `tipo` da atividade restrito a: AMOSTRAGEM_MONITORAMENTO, PLANTIO, APLICACAO_DEFENSIVO, ADUBACAO, CORRECAO_SOLO, COLHEITA, MANEJO_PASTAGEM, ROCADA, OUTRA (seção 8).
- `uso` da unidade restrito a: LAVOURA, PASTAGEM, MATA, OUTRO (seção 8).
- `avaliacao`: nula, POSITIVA ou NEGATIVA; não nula somente com `situacao_execucao` = CONCLUIDA.
- `situacao_execucao`: PLANEJADA, EM_ANDAMENTO ou CONCLUIDA; CONCLUIDA exige `data_realizada`.
- `origem` do vértice: MANUAL, GEOLOCALIZACAO ou MAPA.
- Par (`unidade_id`, `ordem`) único.
- Latitude entre −90 e 90; longitude entre −180 e 180.
- Polígono válido e com no mínimo 3 vértices, verificado na função de envio (especificação 01, seção 5).

## 3. Novas tabelas no servidor

| Tabela | Conteúdo | Uso |
|---|---|---|
| REGISTRO_ALTERACAO | número sequencial, `produtor_id`, tipo do registro, identificador do registro, nova versão, identificador da transação, data | Cursor de recebimento sem pular registros. |
| OPERACAO_PROCESSADA | identificador da operação, `produtor_id`, resultado, data | Idempotência dos envios. Pode ser limpa após 30 dias. |
| CONFIGURACAO_APP | versão mínima aceita do aplicativo | Compatibilidade de versões. |

## 4. Armazenamento no aparelho (TinyDB)

O App Inventor não tem banco relacional nativo. O aparelho usa o componente TinyDB, um armazenamento persistente de pares chave-valor, com um único espaço de nomes (`Namespace` = `agromanejo`). Cada valor é um dicionário ou uma lista, convertidos automaticamente pelo componente.

| Chave | Conteúdo | Uso |
|---|---|---|
| `propriedade` | dicionário da propriedade | Somente leitura no aparelho. |
| `unidade:<id>` | dicionário da unidade com a lista ordenada de vértices | Registro de trabalho. |
| `atividade:<id>` | dicionário da atividade | Registro de trabalho. |
| `indice:unidades` | lista dos identificadores das unidades | Listar sem percorrer todas as chaves. |
| `indice:atividades:<unidade_id>` | lista dos identificadores das atividades da unidade | Listar as atividades da unidade. |
| `indice:pendentes` | lista dos identificadores em PENDENTE | Montar o lote de envio sem percorrer tudo. |
| `meta:sincronizacao` | cursor de recebimento, data do último ciclo bem-sucedido | Retomar o recebimento de onde parou. |
| `sessao` | token de acesso, token de renovação, validade, id do produtor | Autenticação nas chamadas do componente Web. |
| `diagnostico` | lista das últimas 100 falhas: data, tipo de evento, código, id do registro | Diagnóstico de falhas, sem dados pessoais. |

Nos dicionários de unidade e atividade, acrescentar:

- `situacao`: SINCRONIZADO, PENDENTE, CONFLITO ou **REJEITADO** (novo estado; ver especificação 01, seção 3);
- `versao_base`;
- `id_operacao_pendente`;
- `motivo_rejeicao`.

Regras de gravação:

- toda gravação de registro atualiza também os índices afetados no mesmo procedimento;
- ao sair da conta, `ClearAll` apaga todas as chaves do espaço de nomes;
- durante o desenvolvimento com o AI Companion, os projetos compartilham o mesmo TinyDB; testes de persistência definitivos usam o APK instalado.

## 5. Índices

| Tabela | Índice | Motivo |
|---|---|---|
| UNIDADE_MANEJO, VERTICE, ATIVIDADE | `produtor_id` (primeira coluna do índice) | A documentação do Supabase recomenda indexar toda coluna usada em regras de acesso; sem índice, a leitura vira varredura completa. |
| VERTICE | (`unidade_id`, `ordem`), único | Contorno ordenado. |
| ATIVIDADE | `unidade_id` | Listar atividades da unidade. |
| REGISTRO_ALTERACAO | (`produtor_id`, número sequencial) | Recebimento paginado por produtor. |

## 6. Regras de acesso por linha

Seguindo o padrão recomendado pela documentação do Supabase:

- uma regra por operação (leitura, inclusão, alteração), sempre aplicada ao papel de usuário autenticado;
- condição `produtor_id` igual ao usuário autenticado, com a função de usuário avaliada uma única vez por consulta e verificação explícita de usuário não nulo;
- as gravações do aplicativo passam pela função de envio (especificação 01). As tabelas podem ficar sem permissão de gravação direta para o papel autenticado, o que reduz a superfície de ataque.

## 7. Impacto nos diagramas da proposta

Ao aprovar estes ajustes, atualizar na proposta:

- **Modelo ER:** `produtor_id` em VERTICE e ATIVIDADE, `criado_em`, e as tabelas de servidor da seção 3;
- **Diagrama de classes:**
  - `SituacaoSincronizacao` passa a ter REJEITADO;
  - uma interface comum `RegistroSincronizavel` (`id`, `versao`, `versaoBase`, `situacao`) implementada por `UnidadeManejo` e `Atividade`;
  - as operações de sincronização passam a usar esse tipo em vez de `Object`;
- **Seção 7.4:** referenciar esta especificação e a 01.
- **Seção 6:** armazenamento local no TinyDB, sem tabela de pacotes de mapa.

## 8. Decisões funcionais que afetam o modelo (decididas)

Decididas antes da criação das tabelas, porque mudam colunas e a sincronização. Já refletidas na proposta (seções 1.5, 2, 3, 4 e 6 e Figuras 2a, 2b, 5 e 8a).

| Decisão | Situação | Mudança no modelo |
|---|---|---|
| Exclusão de unidades e atividades | **Aprovada** | Coluna `excluido_em` (exclusão lógica) em UNIDADE_MANEJO e ATIVIDADE, propagada pela sincronização como alteração comum. Quando a exclusão de uma unidade é aceita, a função de envio exclui na mesma transação as atividades ainda ativas da unidade e registra cada uma em REGISTRO_ALTERACAO. Atividade nova ou alterada numa unidade excluída é REJEITADA. Exclusão contra edição feita em outro aparelho é conflito comum (UC10). Sem lixeira nesta versão. |
| Data e situação da atividade | **Aprovada** | Colunas `data_prevista` (opcional), `situacao_execucao` (PLANEJADA, EM_ANDAMENTO, CONCLUIDA; padrão PLANEJADA) e `data_realizada` (obrigatória quando CONCLUIDA). |
| Valores realizados | **Aprovada** | Colunas `custo_mao_de_obra_realizado`, `custo_insumos_realizado`, `custo_maquinario_realizado` e `receita_realizada`, opcionais e nunca negativas. O aparelho as pré-preenche com os valores previstos ao concluir. No aparelho, em centavos inteiros, como os previstos. |
| Uso da unidade e novos tipos de atividade | **Aprovada** | Coluna `uso` em UNIDADE_MANEJO (LAVOURA, PASTAGEM, MATA, OUTRO) e quatro novos valores de `tipo`: APLICACAO_DEFENSIVO, CORRECAO_SOLO, MANEJO_PASTAGEM, ROCADA. Atendem lavoura e pastagem sem novas entidades. |
| Propriedade | **Aprovada** | Nova tabela PROPRIEDADE (`id`, `produtor_id`, `nome`, `criado_em`) e coluna `propriedade_id` em UNIDADE_MANEJO, com índice. Criada pelo servidor quando a conta é confirmada (uma por produtor nesta versão) e enviada ao aparelho pelo recebimento; o aparelho não a altera. As regras de acesso continuam por `produtor_id`. |
| Perfis de equipe | **Adiada** (trabalho futuro) | Quando implementada: entidade de membros da propriedade e regras de acesso por propriedade. A tabela PROPRIEDADE já prepara essa mudança. |
| Rebanho | **Adiada** (trabalho futuro) | Entidades de animais ou lotes, pesagens, sanidade, reprodução e movimentação entre piquetes, ligadas às unidades com uso PASTAGEM. |
