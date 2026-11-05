# Especificação 03 — Ajustes do modelo de dados

Complementa a seção 6 da proposta técnica. Lista as mudanças necessárias no modelo antes da criação das tabelas, para dar suporte à sincronização (especificação 01), ao mapa offline (especificação 02) e à segurança.

## 1. Mudanças nas tabelas existentes

| Tabela | Mudança | Motivo |
|---|---|---|
| UNIDADE_MANEJO, VERTICE, ATIVIDADE | Acrescentar `produtor_id` em VERTICE e ATIVIDADE (UNIDADE_MANEJO já tem). | As regras de acesso por linha e as consultas de sincronização filtram direto pelo dono, sem consultar outra tabela. |
| Todas | Acrescentar `criado_em`, definido pelo servidor. | Auditoria e diagnóstico. |
| UNIDADE_MANEJO, ATIVIDADE | Manter `versao` e `atualizado_em`, ambos definidos **só** pelo servidor. | Controle de concorrência (especificação 01). |
| UNIDADE_MANEJO | `area_hectares` passa a ser **recalculada pelo servidor** (PostGIS) a cada gravação aceita. | Define a fonte da verdade da área. O valor do aparelho é provisório até a sincronização. |
| VERTICE | Sem `versao` própria; os vértices são regravados em bloco com a unidade. | O contorno é um bloco único. |
| ATIVIDADE | Custos e receita em reais com 2 casas decimais no servidor; **centavos como número inteiro** no aparelho. | O SQLite não tem tipo decimal exato; somas em ponto flutuante geram diferenças de centavos. |
| VERTICE | Latitude e longitude com 6 casas decimais. | Precisão de cerca de 0,1 m, suficiente para GPS de celular. |

## 2. Regras de integridade (servidor)

- Valores monetários, tempo estimado e área: **nunca negativos**.
- `tipo` da atividade restrito a: AMOSTRAGEM_MONITORAMENTO, PLANTIO, COLHEITA, ADUBACAO, OUTRA.
- `avaliacao`: nula, POSITIVA ou NEGATIVA.
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

## 4. Novas tabelas no aparelho (somente locais)

| Tabela | Conteúdo | Uso |
|---|---|---|
| META_SINCRONIZACAO | cursor de recebimento, data do último ciclo bem-sucedido | Retomar o recebimento de onde parou. |
| PACOTE_MAPA | identificador, região (limites), zoom mínimo e máximo, tamanho em bytes, data do download, unidades cobertas | Gestão dos pacotes offline (especificação 02). |
| REGISTRO_DIAGNOSTICO | data, tipo de evento, código, identificador do registro afetado | Diagnóstico de falhas, sem dados pessoais. |

Nas tabelas locais UNIDADE_MANEJO e ATIVIDADE, acrescentar:

- `situacao`: SINCRONIZADO, PENDENTE, CONFLITO ou **REJEITADO** (novo estado; ver especificação 01, seção 3);
- `versao_base`;
- `id_operacao_pendente`;
- `motivo_rejeicao`.

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

## 8. Decisões funcionais que afetam o modelo (pendentes)

São opcionais, mas é melhor decidir **antes** de criar as tabelas, porque mudam colunas e a sincronização.

| Decisão | Mudança no modelo, se aprovada |
|---|---|
| Exclusão de unidades e atividades | Coluna `excluido_em` (exclusão lógica), propagada pela sincronização como alteração comum. |
| Data e situação da atividade | Colunas `data_prevista` e `situacao_execucao` (PLANEJADA, EM_ANDAMENTO, CONCLUIDA). |
| Valores realizados | Colunas de custo realizado por item e receita realizada, ao lado dos previstos. |
| Perfis de equipe | Nova entidade de membros da propriedade e regras de acesso por propriedade, não só por produtor. É a mudança de maior impacto. |
