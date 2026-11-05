// Converte o HTML gerado pelo pandoc em PDF A4, com rodapé "<titulo> · página/total".
// Uso: node to-pdf.js entrada.html saida.pdf "AgroManejo — Proposta técnica"
const { chromium } = require('playwright');
const path = require('path');

(async () => {
  const [entrada, saida, rodape] = process.argv.slice(2);
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto('file://' + path.resolve(entrada), { waitUntil: 'networkidle' });
  await page.pdf({
    path: saida,
    format: 'A4',
    preferCSSPageSize: true,
    displayHeaderFooter: true,
    headerTemplate: '<span></span>',
    footerTemplate:
      '<div style="width:100%;text-align:center;font-family:Inter,Arial,sans-serif;font-size:7.5pt;color:#444;">' +
      (rodape || 'AgroManejo') +
      ' · <span class="pageNumber"></span>/<span class="totalPages"></span></div>',
  });
  await browser.close();
})();
