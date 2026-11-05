# Especificação 02 — Mapa offline: provedor e estratégia de pacotes

Complementa as seções 1.4 e 7.2 da proposta técnica. Objetivo: garantir que o mapa da propriedade esteja **sempre** disponível no aparelho, sem violar os termos de uso das fontes de imagem.

## 1. Requisito que orienta a decisão

A imagem de fundo precisa ficar armazenada no aparelho **por tempo indeterminado** e ser baixada **antecipadamente** para a região da propriedade, antes de o produtor visitá-la. Isso elimina qualquer fonte que só permita cache temporário ou proíba download antecipado.

## 2. Avaliação dos provedores (termos consultados em nov/2026)

| Fonte | O que os termos dizem | Atende? |
|---|---|---|
| **Servidores de mapa do OpenStreetMap** (tile.openstreetmap.org) | "Offline use is not permitted on tile.openstreetmap.org." O download antecipado de regiões é proibido. A política recomenda servidor próprio ou provedor que permita uso offline. | **Não** |
| **Mapbox** | Cache no aparelho permitido, mas "limited to thirty (30) days on the same device", dentro dos limites dos SDKs da própria Mapbox, e populado diretamente pela API. | **Não** (cache expira; sem download antecipado garantido) |
| **MapTiler Cloud** | Só cache pessoal temporário. "It is prohibited to batch or excessive bulk download of map tiles." | **Não** |
| **MapTiler (dados para servidor próprio)** | Plano padrão: um aplicativo interno, até 500 usuários ativos por mês, sem uso B2B/B2C. Uso para consumidores exige contrato personalizado. | Só com **contrato** |
| **Esri World Imagery** | Uso offline documentado apenas pelos SDKs nativos da Esri, com conta ArcGIS. O MapLibre não aparece como opção para uso offline. | **Não** com MapLibre |
| **Google Maps Platform** | Termos não puderam ser lidos (a página exige JavaScript). | **Não verificado**; não recomendado sem leitura jurídica |
| **EOX Sentinel-2 cloudless** | Gratuito para uso **não comercial** (CC BY-NC-SA 4.0). Uso comercial com licença paga da EOX. Resolução de 10 m. | Sim para o **protótipo**; comercial com licença |
| **Dados abertos processados pelo projeto** (OpenStreetMap para ruas e rótulos; imagens Copernicus Sentinel-2) | Os dados podem ser processados e servidos pelo próprio projeto, cumprindo as regras de atribuição de cada licença. | **Sim**, com servidor próprio |
| **Imagens do próprio produtor** (drone) | O produtor é dono da imagem. | **Sim** (trabalho futuro) |

## 3. Decisão recomendada

**Servir os pacotes de mapa a partir de infraestrutura própria, com dados abertos, em duas camadas:**

1. **Camada de referência (vetorial):** estradas, rios, limites e nomes, gerados a partir de dados do OpenStreetMap para a área de atuação. São leves, nítidos em qualquer zoom e livres para uso offline quando servidos pelo próprio projeto, com a atribuição "© colaboradores do OpenStreetMap".
2. **Camada de imagem (satélite):**
   - **protótipo:** mosaico Sentinel-2 cloudless da EOX, uso não comercial, com a atribuição exigida;
   - **produção:** mosaico Sentinel-2 processado pelo projeto a partir dos dados Copernicus, sem licença paga, ou uma fonte comercial de maior resolução contratada com cláusula expressa de uso offline.

**Hospedagem:** os arquivos de blocos ficam no armazenamento de arquivos do próprio Supabase ou em uma CDN, em formato que o MapLibre lê diretamente. O `OfflineManager` do MapLibre baixa deles os pacotes.

**Limitação a declarar:** imagens de 10 m mostram talhões, estradas e mudanças de cultura, mas não detalhes finos como cercas ou carreadores estreitos. A precisão do contorno vem do GPS e das coordenadas, não da imagem. Para detalhe fino, o caminho é a imagem de drone (trabalho futuro).

## 4. Estratégia de pacotes

**Um pacote por grupo de unidades próximas**, e não um retângulo único para toda a propriedade.

- **Agrupamento:** unidades cujos contornos estejam a menos de 2 km entre si formam um grupo.
- **Região do pacote:** o retângulo que envolve o grupo, mais uma margem de 500 m.
- **Níveis de zoom:**
  - imagem de satélite de 10 m: do zoom 10 (visão geral) ao **15**. Acima disso a imagem não ganha detalhe; o mapa amplia o último nível disponível;
  - camada vetorial: do zoom 10 ao 14, ampliada acima disso sem perda de nitidez.
- **Por que não um único retângulo:** talhões distantes (por exemplo, 15 km) gerariam uma região enorme sem interesse, multiplicando espaço e dados móveis.

**Ordem de grandeza do tamanho.** Na latitude do Rio Grande do Sul (cerca de 30° S), um bloco no zoom 15 cobre cerca de 1 km de lado. Uma propriedade de 5 km × 5 km com margem precisa de algumas dezenas de blocos nesse nível, e de menos nos níveis abaixo. A conta é mostrada para dar a escala; o tamanho real em megabytes depende do formato e da compressão e deve ser medido no protótipo.

**Gestão dos pacotes no aparelho:**

| Evento | Ação |
|---|---|
| Unidade criada ou contorno alterado | Recalcular os grupos; baixar só as regiões novas ou ampliadas. |
| Antes de cada download | Estimar o número de blocos e o tamanho; conferir o espaço livre; avisar o produtor se não houver espaço. |
| Limite de blocos | Configurar o limite de blocos do `OfflineManager` (`setTileCountLimit`) com folga para a maior propriedade esperada, respeitando os termos da fonte. |
| Pacote sem unidades | Remover após a sincronização confirmar que nenhuma unidade o usa. |
| Atualização da imagem | Novo mosaico publicado pelo servidor; atualizar com Wi-Fi ou quando o produtor pedir. |

## 5. Atribuição obrigatória na tela do mapa

Exibir, de forma discreta e acessível, por exemplo em um ícone "i":

- "© colaboradores do OpenStreetMap" (camada vetorial);
- o texto exigido pela fonte de imagem. Para o EOX cloudless: "EOxCloudless by EOX IT Services GmbH (Contains modified Copernicus Sentinel data [ano])".

## 6. Decisões pendentes

1. Confirmar a área de atuação inicial (estado ou região) para gerar a camada vetorial.
2. Para produção: processar o próprio mosaico Sentinel-2 ou contratar imagem comercial de maior resolução com cláusula de uso offline.
3. Se o Google ou outro provedor comercial for considerado, ler os termos completos antes de qualquer uso offline.

## Fontes consultadas

- OSM Foundation, *Tile Usage Policy*: https://operations.osmfoundation.org/policies/tiles/
- Mapbox, *Product Terms* (20/10/2026), seção 2.8.1.
- MapTiler, *Cloud Terms*: https://www.maptiler.com/terms/cloud/ — e *Server & Data Terms*: https://www.maptiler.com/terms/server-data/
- Esri, *Offline mapping apps*: https://developers.arcgis.com/documentation/offline-mapping-apps/
- EOX, *EOxCloudless license*: https://cloudless.eox.at/documentation/license
- MapLibre React Native, *OfflineManager*: https://maplibre.org/maplibre-react-native/docs/modules/offline-manager
