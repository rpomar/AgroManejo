#!/usr/bin/env bash
# Gera os diagramas, o PDF e o DOCX da proposta e o PDF das especificações.
# Requisitos: java + plantuml.jar (PLANTUML_JAR), graphviz, pandoc, node com playwright,
# e mermaid-cli (MMDC). Exemplo:
#   PLANTUML_JAR=~/plantuml.jar MMDC=~/node_modules/.bin/mmdc ferramentas/gerar.sh
set -euo pipefail
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
FERR="$RAIZ/ferramentas"
TMP="$(mktemp -d)"
: "${PLANTUML_JAR:?defina PLANTUML_JAR}"
: "${MMDC:?defina MMDC}"

# 1. Diagramas
cd "$RAIZ/entrega-basica/diagramas"
java -jar "$PLANTUML_JAR" -charset UTF-8 -tpng ./*.puml
CHROME="${CHROME:-$(node -e "console.log(require('playwright').chromium.executablePath())")}"
printf '{"executablePath":"%s","args":["--no-sandbox","--headless"]}' "$CHROME" > "$TMP/pptr.json"
for f in ./*.mmd; do "$MMDC" -p "$TMP/pptr.json" -t neutral -s 3 -b white -i "$f" -o "${f%.mmd}.png"; done

# 2. Proposta técnica
cd "$RAIZ/entrega-basica"
pandoc AgroManejo-Entrega-Basica.md -s --embed-resources --css "$FERR/estilo.css" -o "$TMP/proposta.html"
node "$FERR/to-pdf.js" "$TMP/proposta.html" AgroManejo-Entrega-Basica.pdf "AgroManejo — Proposta técnica"
pandoc AgroManejo-Entrega-Basica.md -o AgroManejo-Entrega-Basica.docx

# 3. Especificações (capa + uma especificação por bloco, cada uma começando em nova página)
cd "$RAIZ/especificacoes"
{
  printf -- '---\ntitle: "AgroManejo"\nsubtitle: "Especificações técnicas para o desenvolvimento"\ndate: "Novembro de 2026"\nlang: pt-BR\n---\n'
  for f in 01-*.md 02-*.md 03-*.md; do
    printf '\n\n'
    # o título de cada especificação vira h1 (nova página); as seções viram h2
    sed -e 's/^## /### /' -e 's/^# /## /' -e '0,/^## /s//# /' "$f"
  done
} > "$TMP/especificacoes.md"
pandoc "$TMP/especificacoes.md" -s --embed-resources --css "$FERR/estilo.css" -o "$TMP/espec.html"
node "$FERR/to-pdf.js" "$TMP/espec.html" AgroManejo-Especificacoes-Tecnicas.pdf "AgroManejo — Especificações técnicas"

rm -rf "$TMP"
echo "Gerado: entrega-basica/AgroManejo-Entrega-Basica.{pdf,docx} e especificacoes/AgroManejo-Especificacoes-Tecnicas.pdf"
