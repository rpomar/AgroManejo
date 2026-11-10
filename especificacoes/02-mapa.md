# Especificação 02 — Mapa: fonte de imagem e uso sem conexão

Complementa as seções 1.4 e 7.2 da proposta técnica. Define a fonte da imagem de fundo do componente Map do App Inventor e o comportamento do mapa sem conexão.

## 1. Requisito que orienta a decisão

O projeto usa apenas os componentes nativos do App Inventor. O componente Map carrega as imagens de fundo pela internet e não oferece, na documentação oficial, download antecipado nem armazenamento de imagens para uso offline. O método `Save` do Map grava apenas os elementos desenhados (em GeoJSON), não as imagens.

Por isso, o que precisa estar sempre disponível no aparelho são os **dados** das unidades. A imagem de satélite é um complemento que aparece quando há conexão.

## 2. O que funciona com e sem conexão

| Elemento | Com conexão | Sem conexão |
|---|---|---|
| Contornos (Polygon), vértices (Marker), nomes e áreas | Sim | Sim, a partir do TinyDB |
| Posição do produtor (ShowUser, LocationSensor) | Sim | Sim, o GPS não depende de internet |
| Desenho e edição de unidades (TapAtPoint, GPS, digitação) | Sim | Sim |
| Imagem de satélite de fundo | Sim | Não garantida; fundo neutro |

O aplicativo não depende de cache de imagens. Se o componente guardar imagens já vistas, isso é um benefício, não um requisito.

## 3. Fontes de imagem avaliadas (termos consultados em nov/2026)

Como o uso agora é online, a restrição deixa de ser o armazenamento offline e passa a ser a permissão de uso pela internet num aplicativo.

| Fonte | Como usar no App Inventor | Observação | Atende? |
|---|---|---|---|
| **OpenStreetMap** (padrão do Map, `MapType` = Roads) | Nativo | Mapa de ruas, sem imagem de satélite. A política de uso dos servidores do OpenStreetMap admite uso moderado com atribuição e proíbe download em massa. | Sim, como camada de referência |
| **USGS** (`MapType` = Aerial) | Nativo | Imagem aérea do Serviço Geológico dos Estados Unidos. A cobertura e o detalhe no Rio Grande do Sul precisam ser verificados no protótipo. | A verificar |
| **EOX Sentinel-2 cloudless** (`MapType` = Custom, `CustomUrl`) | Nativo, por URL de blocos | Gratuito para uso **não comercial** (CC BY-NC-SA 4.0), com atribuição. Resolução de 10 m, cobertura mundial. | Sim para o protótipo |
| **Mapbox, MapTiler, Google, Esri** | `CustomUrl`, quando os termos permitem | Exigem conta e chave de acesso, e os termos limitam o uso dos blocos fora dos seus próprios SDKs. | Não nesta fase |

## 4. Decisão

1. **Imagem de fundo nesta fase: mosaico Sentinel-2 cloudless da EOX**, configurado pela propriedade `CustomUrl` do componente Map, no formato de URL de blocos `{z}/{x}/{y}` aceito pelo componente. O endereço exato do serviço de blocos da EOX é confirmado na fase 1 do protótipo. O projeto está em fase acadêmica e sem fins comerciais, o que atende à licença CC BY-NC-SA 4.0.
2. **Alternativa:** se o serviço da EOX não funcionar com o componente, usar `MapType` = Aerial (USGS), desde que a cobertura no Rio Grande do Sul seja adequada, ou Roads (OpenStreetMap), que mostra estradas e rios.

**Limitação a declarar:** imagens de 10 m mostram talhões, estradas e mudanças de cultura, mas não detalhes finos como cercas ou carreadores estreitos. A precisão do contorno vem do GPS e das coordenadas, não da imagem.

## 5. Atribuição obrigatória na tela do mapa

Exibir, de forma discreta e acessível, por exemplo num rótulo no canto do mapa ou num ícone "i":

- "© colaboradores do OpenStreetMap" (quando o fundo for Ruas);
- o texto exigido pela fonte de imagem. Para o EOX cloudless: "EOxCloudless by EOX IT Services GmbH (Contains modified Copernicus Sentinel data [ano])".

## 6. Uso comercial (pendente, só se houver)

- Contratar imagem com licença comercial e permissão de uso pelo componente Map, ou servir um mosaico Sentinel-2 processado pelo próprio projeto.
- Mapa de fundo offline exigiria extensão do App Inventor ou outra plataforma de desenvolvimento (trabalho futuro na seção 7.7 da proposta).

## Fontes consultadas

- MIT App Inventor, *Maps Components* (Map, Polygon, Marker, FeatureCollection): https://ai2a.appinventor.mit.edu/reference/components/maps.html
- MIT App Inventor, *Sensor Components* (LocationSensor): https://ai2a.appinventor.mit.edu/reference/components/sensors.html
- OSM Foundation, *Tile Usage Policy*: https://operations.osmfoundation.org/policies/tiles/
- EOX, *EOxCloudless license*: https://cloudless.eox.at/documentation/license
