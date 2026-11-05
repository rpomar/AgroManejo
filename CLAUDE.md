# CLAUDE.md — AgroManejo

Aplicativo Android para gestão de unidades de manejo rural (talhões). Fase atual: **proposta técnica e projeto do software** — somente documentação. Não implementar o aplicativo sem pedido explícito.

## Documento de referência
- Fonte única: `entrega-basica/AgroManejo-Entrega-Basica.md`. O `.pdf` e o `.docx` são gerados a partir dele.
- Diagramas em `entrega-basica/diagramas/`: UML em PlantUML (`.puml`), modelo ER em Mermaid (`.mmd`), imagens `.png` exportadas.
- O documento contém: descrição do software (com funcionamento do mapa, dados da atividade e navegação), requisitos (RF01–RF19, RNF01–RNF08), casos de uso (UC01–UC14), diagrama de classes (visões 2a e 2b), diagramas de sequência, modelo ER (8a negócio, 8b apoio à sincronização), relatório técnico e protótipo de telas (Figuras 10a e 10b, PlantUML Salt).
- Geração: `ferramentas/gerar.sh` (PlantUML, Mermaid com tema neutral, pandoc + `ferramentas/estilo.css` + Chromium via `ferramentas/to-pdf.js`). Gera também o PDF das especificações.
- `docs/` guarda rascunhos antigos apenas como histórico. Não atualizar.
- `especificacoes/` contém as especificações técnicas para o desenvolvimento: 01 protocolo de sincronização, 02 mapa offline (provedor e pacotes), 03 ajustes do modelo de dados (aprovada e refletida nos diagramas e na seção 6). Manter especificações e proposta coerentes.

## Decisões técnicas
- Android; React Native + Expo + TypeScript.
- SQLite no aparelho; Supabase/PostgreSQL no servidor; sincronização própria do aplicativo (versão controlada pelo servidor, conflitos resolvidos pelo produtor, sem sobrescrita silenciosa).
- Mapa: MapLibre React Native com pacotes offline da região da propriedade. Exige *development build* (não roda no Expo Go).
- Prioridade: a propriedade (dados e mapa) sempre disponível no aparelho, mesmo com maior uso de armazenamento, dados móveis e bateria.
- Escopo desta versão: lavoura e pastagem. Rebanho e perfis de equipe são trabalhos futuros.
- Modelo: Produtor 1—0..* Propriedade 1—0..* UnidadeManejo. Uma propriedade por produtor na interface, criada pelo servidor com a conta; regras de acesso por `produtor_id`.
- Unidade: nome, uso (LAVOURA, PASTAGEM, MATA, OUTRO), contorno e área.
- Atividade: tipo (9 valores), descrição, data prevista, tempo estimado, custos separados (mão de obra, insumos, maquinário), custo total calculado, receita esperada; situação (PLANEJADA, EM_ANDAMENTO, CONCLUIDA), data realizada (obrigatória ao concluir), custos e receita realizados (pré-preenchidos com os previstos); avaliação só em atividade concluída; observações.
- Exclusão lógica (`excluido_em`) de unidades e atividades, sincronizada; exclusão de unidade em cascata feita pelo servidor; exclusão contra edição é conflito comum; sem lixeira.
- Navegação: abas Mapa, Atividades (agenda) e Mais (sincronização, pacotes de mapa, conta). Indicador de sincronização no mapa. Sair com pendências pede confirmação.
- Mapa offline: camada vetorial OSM do RS; imagem EOX Sentinel-2 cloudless (uso não comercial).

## Regras de redação
- Tom de proposta técnica profissional, em linguagem simples.
- Não citar enunciado, professores, disciplina nem usar códigos administrativos (DP, PM, L, CT, BCEF) no documento.
- Manter coerência entre requisitos, casos de uso, classes, sequências e modelo ER (mesmos nomes de atores, classes, operações e atributos).
- Não acrescentar funcionalidades sem justificativa. Verificar documentação oficial antes de afirmar algo sobre tecnologias.
- Diagramas legíveis no PDF: um por página; os largos são girados 90°.

## Publicação
- Não fazer commit nem push sem autorização explícita. Não usar o BTCoachManager.
- Autor: Rafael Pomar. Entrega da documentação: 10/11/2026.
