# PROGRESSO — AgroManejo

Atualizado em: 2026-11-10

## Estado
- Proposta técnica e projeto do software: `entrega-basica/AgroManejo-Entrega-Basica.md` (PDF e DOCX gerados a partir dele por `ferramentas/gerar.sh`), com diagramas em `entrega-basica/diagramas/`.
- Especificações técnicas para o desenvolvimento: `especificacoes/` (01 sincronização, 02 mapa, 03 modelo de dados).
- Revisão de 10/11 — plataforma passa a ser o MIT App Inventor (decisão do autor), só com componentes nativos:
  - seções 1, 2, 3, 4, 5, 6 e 7 ajustadas; nova tabela de correspondência entre o modelo e o App Inventor (seção 4);
  - TinyDB no aparelho; Supabase mantido, acessado pelo componente Web;
  - mapa offline removido: sem conexão, as unidades aparecem sobre fundo neutro (RF16 reescrito; antigo UC11 removido; UC12–UC14 renumerados para UC11–UC13);
  - sincronização por Clock, só com o aplicativo aberto; ator Temporizador no diagrama de casos de uso;
  - cálculo de área e validação do polígono descritos para implementação em blocos (seção 2.3);
  - correções da revisão: UC07 estende só UC08; RNF03, RNF05 e RNF06 com métricas; LGPD citada; arquitetura (Figura 9) atualizada.
- Revisão de 05/11: escopo lavoura e pastagem, PROPRIEDADE, planejado e realizado, exclusão lógica, conta e senha, três abas, protótipo de telas.

## Pendências
- Revisão final do autor antes da entrega de 10/11/2026.
- Confirmar na fase 1 do protótipo: URL de blocos da EOX no Map (CustomUrl), formato de RequestHeaders do Web, cobertura da imagem Aerial (USGS) no RS.
- Datas das fases do protótipo (a definir no início da implementação).

## Observações
- A geração precisa de PlantUML (com graphviz), mermaid-cli, pandoc e Playwright; ver o cabeçalho de `ferramentas/gerar.sh`.
