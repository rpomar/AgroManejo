# PROGRESSO — AgroManejo

Atualizado em: 2026-11-05

## Estado
- Proposta técnica e projeto do software: `entrega-basica/AgroManejo-Entrega-Basica.md` (PDF e DOCX gerados a partir dele por `ferramentas/gerar.sh`), com diagramas em `entrega-basica/diagramas/`.
- Especificações técnicas para o desenvolvimento: `especificacoes/` (01 sincronização, 02 mapa offline, 03 modelo de dados).
- Revisão de 05/11 (decisões tomadas em sessão de perguntas e respostas com o autor), aplicada à proposta, às especificações e aos diagramas:
  - escopo: lavoura e pastagem; rebanho e perfis de equipe como trabalhos futuros;
  - entidade PROPRIEDADE; uso da unidade; quatro novos tipos de atividade;
  - planejado e realizado na atividade (data prevista, situação, data e valores realizados); avaliação só após concluir;
  - exclusão lógica (RF17, UC12); criação de conta e recuperação de senha (UC13, UC14);
  - navegação em três abas, indicador de sincronização, saída com pendências;
  - mapa offline: RS inteiro, imagem EOX (uso não comercial);
  - nova seção 8, Protótipo de telas (Figuras 10a e 10b); Figura 5 com planejar, executar e avaliar; fases 1–6 do protótipo na seção 7.7;
  - autor preenchido na capa.

## Pendências
- Revisão final do autor antes da entrega de 10/11/2026.
- Datas das fases do protótipo (a definir no início da implementação).
- Produção comercial (se houver): fonte de imagem com uso offline permitido (especificação 02).

## Observações
- `docs/` guarda rascunhos antigos apenas como histórico.
- A geração precisa de PlantUML (com graphviz), mermaid-cli, pandoc e Playwright; ver o cabeçalho de `ferramentas/gerar.sh`.
