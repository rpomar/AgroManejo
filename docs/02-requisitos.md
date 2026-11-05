# 02 — Definição dos Requisitos

| Campo | Valor |
|---|---|
| ID | AGM-REQ |
| Versão | 0.2.0 |
| Status | Proposed (aguarda aprovação do autor) |
| Data | 2026-11-03 |
| Owner | Autor do projeto (aluno) |
| Fonte de requisitos | **[P]** `PROJETO_Gerenciamento de Unidades de Manejo Rural com Tecnologia Mobile.pdf` (2 páginas) |
| Material de apoio | **[S]** `Desenvolvimento movel.pdf` — sem força de requisito |
| Referências internas | `01-descricao-do-software.md` |
| Histórico | 0.1.0 — rascunho inicial · 0.2.0 — DP06, DP07, DP09 *Accepted*; DP08 criado; RNF06 aposentado (conteúdo movido para DP05); L06, L07, PM12; critérios de teste (§5.2); coluna de verificação na matriz |

---

## §1 Convenções

| Categoria | Significado | Quem decide |
|---|---|---|
| **OF** | Requisito oficial, explícito em [P] | Professor |
| **OF-ALT** | Alternativa oficial: o enunciado oferece opções equivalentes | Professor |
| **DP** | Decisão de projeto, com status *Proposed* (em avaliação) ou *Accepted* (aprovada pelo autor) | Autor |
| **PM** | Premissa de modelagem: suposição explícita onde o enunciado é silencioso | Autor |
| **PE** | Pendente de esclarecimento junto ao professor | Professor |

- A classificação **RF/RNF** é escolha metodológica do autor; [P] p.2 pede apenas "Definição dos Requisitos".
- As listas RF e RNF contêm **somente** requisitos OF e OF-ALT. Decisões de projeto ficam em §5.
- Referências a [P] indicam página e trecho (Objetivo, item 1, item 2, item 3, Requisitos Técnicos, Critérios de Avaliação, Entregas).
- Identificadores não são reaproveitados; um ID aposentado permanece listado com nota.

---

## §2 Requisitos Funcionais

| ID | Requisito | Cat. | Origem |
|---|---|---|---|
| **RF01** | O sistema deve permitir ao produtor definir uma unidade de manejo informando **três ou mais** coordenadas geográficas. | OF | [P] p.1, item 1 |
| **RF02** | Cada coordenada deve poder ser **digitada manualmente**. | OF-ALT | [P] p.1, item 1 ("inseridos manualmente"); Objetivo ("passadas como parâmetros") — ver PE02 |
| **RF03** | Cada coordenada deve poder ser **obtida por geolocalização** do próprio dispositivo. | OF-ALT | [P] p.1, Objetivo e item 1 |
| **RF04** | Cada coordenada deve poder ser **marcada diretamente no mapa**. | OF-ALT | [P] p.1, Objetivo e item 1 |
| **RF05** | O sistema deve **delimitar a área de manejo como polígono** a partir dos pontos fornecidos ("triangulação"). | OF | [P] p.1, Objetivo e item 1 — interpretação em §4 |
| **RF06** | O sistema deve **exibir mapa** com a área delimitada da unidade. | OF | [P] p.1, Requisitos Técnicos |
| **RF07** | O sistema deve permitir **registrar atividades** em uma unidade de manejo, contendo: (a) descrição; (b) tempo estimado; (c) custo operacional (mão de obra, insumos, maquinário); (d) receitas esperadas. | OF | [P] p.1, item 2 |
| **RF08** | O sistema deve permitir **avaliar a atividade** como positiva ou negativa, com observações opcionais. | OF | [P] p.1, item 2 ("com a possibilidade de inserir observações") |
| **RF09** | O sistema deve permitir **editar as coordenadas** de uma unidade a qualquer momento; o polígono deve ser redelimitado após a edição. | OF | [P] p.2, Requisitos Técnicos |
| **RF10** | O sistema deve permitir **editar os registros de atividades** a qualquer momento, inclusive a avaliação. | OF | [P] p.2, Requisitos Técnicos |
| **RF11** | O front-end deve **funcionar offline** quando necessário: RF01–RF10 devem ser executáveis sem conectividade, com as limitações declaradas em PM07. | OF | [P] p.2 |
| **RF12** | O front-end deve **sincronizar os dados** com o back-end remoto **assim que houver conectividade**. | OF | [P] p.2 |

### §2.1 Interpretação das alternativas de entrada (RF02–RF04)

O Objetivo afirma que a aplicação "**deve ser capaz** de receber coordenadas (marcadas em um mapa, passadas como parâmetros ou obtidas por geolocalização)" ([P] p.1). Interpreta-se que **as três formas devem estar disponíveis** e que o produtor escolhe, **ponto a ponto**, qual usar; uma mesma unidade pode combinar formas diferentes (PM05).

---

## §3 Requisitos Não Funcionais

| ID | Requisito | Cat. | Origem |
|---|---|---|---|
| **RNF01** | **Back-end remoto**: os dados devem ser persistidos em um back-end remoto, acessado pelo front-end móvel. | OF | [P] p.1, Descrição da Atividade |
| **RNF02** | **Front-end móvel**: a aplicação deve operar em dispositivos móveis. | OF | [P] p.1, Descrição da Atividade |
| **RNF03** | **Usabilidade**: interface amigável e intuitiva, facilitando a inserção de dados e a navegação. | OF | [P] p.1, Requisitos Técnicos; p.2, Critérios (Usabilidade) |
| **RNF04** | **Eficiência**: otimizar o uso de bateria, armazenamento, comunicação e processamento; considerar também memória e sensores. | OF | [P] p.2, Requisitos Técnicos; p.2, Critérios (Eficiência) |
| **RNF05** | **Escalabilidade**: a solução deve prever uso concorrente por grande quantidade de usuários dispersos geograficamente, em escala global. | OF | [P] p.2, Requisitos Técnicos |
| ~~RNF06~~ | *Aposentado na v0.2.0.* "Consistência após sincronização" não é requisito do professor; passou a ser propriedade do mecanismo DP05 (§5.1, item 8). | — | — |

**Escopo de RNF05 na Entrega Básica.** Exige-se **projeto arquitetural compatível** com crescimento (back-end gerenciado e escalável, dados particionáveis por produtor, operação offline-first reduzindo carga no servidor). Infraestrutura global (múltiplas regiões, réplicas) **não** é implantada nesta fase.

**Restrições do projeto (não são requisitos do produto):**

| ID | Restrição | Origem |
|---|---|---|
| R01 | Plataforma de desenvolvimento de livre escolha (Android, iOS, multiplataforma etc.). Exercida por DP06 e DP07. | [P] p.1, item 3 |
| R02 | Estrutura de banco de dados de livre escolha (local, remoto). Exercida por DP08 (Proposed). | [P] p.1, item 3 |
| R03 | Desenvolvimento, em um primeiro momento, **individual**. | [P] p.1, Descrição da Atividade |
| R04 | Entrega Básica = projeto do software + relatório técnico; protótipo funcional somente na Entrega Avançada. | [P] p.2, Entregas |

---

## §4 Delimitação da área: conceitos, interpretação e premissas (RF05)

O enunciado usa "triangulação" em [P] p.1 duas vezes: "a partir da triangulação desses pontos, determinar a área de manejo (polígono)" e "a área será delimitada por meio da triangulação dos pontos fornecidos, formando um polígono". Três operações distintas estão envolvidas e são tratadas separadamente.

### §4.1 Sentidos do termo descartados

- **Triangulação topográfica/geodésica:** determina a posição de um ponto a partir de ângulos medidos de pontos conhecidos. Não se aplica: as coordenadas já são fornecidas.
- **Posicionamento por satélite:** o receptor GNSS calcula a posição por *trilateração* (distâncias), não triangulação, e isso ocorre dentro do próprio sensor. Não é responsabilidade da aplicação.

### §4.2 Formação do polígono (contorno)

Formar o polígono é **definir o contorno**: ligar os vértices em uma sequência e fechar a figura ligando o último ao primeiro. A formação depende da **ordem** dos vértices — os mesmos pontos em ordens diferentes produzem polígonos diferentes. O enunciado não define a ordem.

### §4.3 Triangulação geométrica

Em geometria computacional, **triangular um polígono simples** de *n* vértices é decompô-lo em *n − 2* triângulos sem sobreposição, cujos vértices são os do próprio polígono (ex.: algoritmo *ear clipping*).

- Em polígono **convexo**, basta o "leque" a partir de um vértice.
- Em polígono **côncavo**, o leque a partir de um vértice qualquer pode gerar triângulos fora da área; é necessária uma triangulação válida (ex.: *ear clipping*).
- A área do polígono é a soma das áreas dos triângulos de uma triangulação válida.

**Relação com a fórmula de Gauss (shoelace).** A fórmula soma áreas **com sinal** de triângulos formados por uma origem e cada aresta; os triângulos "externos" se cancelam. Para **polígonos simples no plano** (convexos ou côncavos), ela produz o mesmo valor que a soma de uma triangulação válida. Não são, porém, equivalentes em geral:

- a shoelace **não produz** os triângulos — produz apenas o valor da área;
- em **polígonos que se autointerceptam**, a shoelace devolve um valor sem significado físico, e não existe triangulação válida;
- ambas são fórmulas **planas**; nenhuma se aplica diretamente a latitude/longitude (§4.4).

### §4.4 Cálculo geográfico da área

Latitude e longitude são **ângulos** sobre um elipsoide (WGS84), não coordenadas planas. Aplicar fórmulas planas diretamente sobre graus produz "graus quadrados", sem significado agronômico. Há duas abordagens corretas, cuja escolha será feita no relatório técnico:

1. **Projeção para um plano local** (ex.: UTM ou plano tangente local) e cálculo plano depois. Erro pequeno para áreas do porte de propriedades rurais.
2. **Cálculo esférico ou elipsoidal** direto sobre as coordenadas geográficas. Exemplo de referência: no PostGIS, `ST_Area` sobre o tipo `geography` calcula sobre o esferoide, em m² (documentação oficial do PostGIS).

### §4.5 Interpretação adotada

| Item | Interpretação | Cat. |
|---|---|---|
| Sentido de "triangulação" | Triangulação **geométrica** do polígono formado pelos pontos (§4.3). | PM |
| "Área de manejo (polígono)" | A **região** delimitada é exigida (OF). A **medida** da área (m²/ha) não é dita explicitamente. Propõe-se calculá-la e exibi-la — ver DP02. | OF + DP |
| Ordem dos vértices | A **ordem de entrada** pelo produtor define o contorno (PM01). | PM |
| Exibição dos triângulos | Não exigida explicitamente; não será exibida. | PE01 |

### §4.6 Premissas de contorno, ordenação e validade

| ID | Premissa | Cat. |
|---|---|---|
| PM01 | O contorno segue a **ordem de entrada** dos vértices; o último liga-se ao primeiro. O sistema não reordena pontos automaticamente (ex.: não usa fecho convexo). | PM |
| PM02 | Coordenadas em **graus decimais, datum WGS84**; latitude ∈ [−90, 90], longitude ∈ [−180, 180]. | PM |
| PM03 | **Polígono válido** exige: (a) ≥ 3 vértices; (b) vértices consecutivos distintos; (c) vértices não todos colineares (área > 0); (d) arestas sem autointerseção (polígono simples). Polígono inválido não é salvo como delimitação. | PM (concretizada em DP04) |
| PM04 | Uma unidade possui **um único contorno**, sem furos internos, e não cruza o antimeridiano nem os polos. | PM |
| PM05 | Uma unidade pode combinar vértices obtidos por formas diferentes (manual, GPS, mapa); a origem de cada vértice é registrada. | PM |

---

## §5 Decisões de projeto

Nenhuma decisão abaixo é requisito do professor.

| ID | Decisão | Status | Justificativa | Requisitos atendidos |
|---|---|---|---|---|
| **DP01** | **Identificação do produtor** (conta autenticada) para associar dados ao dono. | Proposed | Com back-end remoto compartilhado por muitos usuários (RNF01, RNF05), cada dado precisa de um dono para que a sincronização envie a cada aparelho apenas os dados do respectivo produtor. **Não** é exigência de [P]. Limitação: L04. | RNF01, RNF05, RF12 |
| **DP02** | **Calcular e exibir a medida da área** (m² e ha) com método geográfico (§4.4). | Proposed | Interpretação de "determinar a área" ([P] p.1); custo baixo e valor agronômico direto. | RF05, RF06 |
| **DP03** | **Listar** unidades do produtor e atividades de cada unidade. | Proposed | Necessário para selecionar o que editar (RF09, RF10) e visualizar (RF06). Funcionalidade derivada, não adicional. | RF06, RF09, RF10 |
| **DP04** | **Validar** o polígono conforme PM03 antes de salvar, informando o problema ao produtor. | Proposed | Evita áreas sem significado (§4.3) e melhora a usabilidade (RNF03). | RF05, RF09, RNF03 |
| **DP05** | **Sincronização offline-first** — §5.1. | Proposed | SQLite e Supabase não sincronizam automaticamente; o mecanismo precisa ser projetado. | RF11, RF12, RNF04, RNF05 |
| **DP06** | **Plataforma: somente Android.** Não haverá versão iOS. | **Accepted** | Escolha permitida por [P] p.1, item 3 (R01). Concentra o esforço de desenvolvimento e teste em uma única plataforma. | RNF02, R01 |
| **DP07** | **Framework: React Native + Expo + TypeScript.** Ambiente: VS Code com Claude Code. Android Studio **não obrigatório** na configuração inicial; previsto para o emulador e para compilações locais. | **Accepted** | Teste imediato em celular físico pelo Expo Go, sem Android Studio; TypeScript reduz erros de tipo e tem curva acessível; módulos Expo para mapa, localização e SQLite. Com Android exclusivo, Kotlin nativo ([S] slides 4–11) é alternativa relevante; a comparação completa estará no relatório técnico. | RNF02, RNF03, R01 |
| **DP08** | **Persistência: SQLite local + Supabase (PostgreSQL) remoto.** | Proposed | Permanece em avaliação até a definição conjunta da persistência remota e da sincronização (DP05). Justificativa no relatório técnico. | RNF01, RF11, R02 |
| **DP09** | **Estratégia de testes em cinco níveis** (T1–T5) com critérios verificáveis — §5.2. Ferramentas concretas a definir no relatório técnico. | **Accepted** (estratégia) | Garante evidência objetiva dos requisitos, em especial offline, sincronização e eficiência. Execução na Entrega Avançada. | Todos — ver §8 |

### §5.1 DP05 — Mecanismo de sincronização proposto

**Mecanismo:**

1. **Local-first:** toda leitura e escrita do aplicativo ocorre no SQLite local; a interface não depende da rede.
2. **Identificadores globais:** cada registro recebe um UUID gerado no próprio aparelho, evitando colisão entre aparelhos sem consultar o servidor.
3. **Marcação de pendência:** cada registro guarda `atualizado_em` e um indicador de **pendente de envio**.
4. **Gatilhos:** a sincronização é disparada quando a conectividade é restabelecida e quando o aplicativo é aberto com conexão.
5. **Ordem:** primeiro **envia** (push) as pendências em lote; depois **recebe** (pull) o que mudou no servidor desde a última sincronização.
6. **Conflitos:** regra "**última alteração vence**" (*last-write-wins*) por registro.
7. **Cursor de recebimento:** usa o carimbo de tempo do **servidor**, evitando depender do relógio do aparelho.
8. **Propriedade esperada — consistência eventual:** após uma sincronização concluída sem novas alterações, os dados locais e remotos de um produtor convergem para o mesmo estado. *(Conteúdo do antigo RNF06.)*

**Limitações declaradas:**

| ID | Limitação |
|---|---|
| L01 | *Last-write-wins* pode **descartar silenciosamente** uma edição concorrente feita em outro aparelho. Aceitável para uso tipicamente individual (R03, um produtor). |
| L02 | O relógio do aparelho pode estar incorreto e afetar a decisão de conflito; mitigado parcialmente pelo cursor do servidor. |
| L03 | Como não há exclusão de registros (não exigida), não são necessários marcadores de exclusão; se a exclusão for incluída no futuro, o mecanismo precisará de *tombstones*. |
| L04 | O primeiro acesso (DP01) requer conectividade. |
| L05 | A implementação concreta (código próprio ou biblioteca de sincronização) **não** é escolhida nesta fase; fica vinculada à decisão DP08. |
| L06 | **Compatibilidade com o Expo Go.** O Expo Go contém um conjunto fixo de módulos nativos. Uma solução de sincronização que use apenas módulos já incluídos (ex.: `expo-sqlite`) e código TypeScript funciona no Expo Go; uma que dependa de **módulo nativo não incluído** exige um *development build* (compilado via EAS Build ou localmente com Android Studio). A compatibilidade de cada candidata deve ser verificada em sua documentação oficial no momento da escolha, pois afeta o nível de teste T1. |

### §5.2 DP09 — Estratégia de testes e critérios verificáveis

Os testes são **executados na Entrega Avançada**; aqui ficam definidos o que se verifica e como se decide aprovado/reprovado. Um critério não executado ou inconclusivo conta como **não atendido**.

| Nível | Ambiente | Propósito |
|---|---|---|
| T1 | Celular Android físico com Expo Go | Fluxos funcionais e sensores reais (GPS) |
| T2 | Emulador do Android Studio | Versões/telas de Android, localização simulada, alternância de rede |
| T3 | Testes automatizados (sem aparelho) | Lógica de negócio: geometria, área, validação, repositórios, sincronização |
| T4 | Aparelho físico ou emulador | Offline, persistência e sincronização |
| T5 | APK instalado sem Expo Go | Comportamento do aplicativo real |

#### Funcionais (T1, T2)

| ID | Critério verificável | Req. |
|---|---|---|
| CT-FUN-01 | Uma unidade com ≥ 3 vértices é criada usando, na mesma unidade, ao menos um vértice digitado, um obtido por GPS e um marcado no mapa; a origem de cada vértice fica registrada. | RF01–RF04, PM05 |
| CT-FUN-02 | O polígono da unidade é exibido no mapa com os vértices na ordem de entrada. | RF05, RF06, PM01 |
| CT-FUN-03 | Uma atividade é registrada com descrição, tempo estimado, custo operacional e receita esperada, e os quatro valores são exibidos sem alteração ao reabri-la. | RF07 |
| CT-FUN-04 | Uma atividade é avaliada como positiva e depois alterada para negativa com observação; o valor final é o exibido. | RF08, RF10 |
| CT-FUN-05 | Após editar um vértice, o polígono exibido e a área (DP02) são recalculados. | RF09, DP02 |

#### Geometria e área (T3)

| ID | Critério verificável | Req. |
|---|---|---|
| CT-GEO-01 | São **rejeitados**, com motivo identificado: menos de 3 vértices; vértices consecutivos iguais; vértices colineares; arestas que se cruzam; latitude ou longitude fora da faixa. | DP04, PM02, PM03 |
| CT-GEO-02 | Para polígonos de referência (ao menos um convexo e um côncavo), a área calculada difere da área de referência independente (ex.: PostGIS `ST_Area` em `geography`) em no máximo a **tolerância relativa** definida no relatório técnico (proposta inicial: 0,5%). | RF05, DP02, §4.4 |
| CT-GEO-03 | Inverter o sentido dos vértices (horário ↔ anti-horário) não altera a área calculada. | DP02 |
| CT-GEO-04 | Os mesmos pontos em ordens diferentes geram contornos diferentes; a ordem que produz autointerseção é rejeitada. | PM01, PM03 |

#### Offline e persistência (T4)

| ID | Critério verificável | Req. |
|---|---|---|
| CT-OFF-01 | Com o aparelho **em modo avião**, CT-FUN-01 (exceto marcação no mapa sem cache, PM07), CT-FUN-03, CT-FUN-04 e CT-FUN-05 são executados sem mensagem de erro de rede e sem bloqueio da interface. | RF11, PM07 |
| CT-OFF-02 | Após criar dados offline, **encerrar o aplicativo** e reabri-lo, todos os dados continuam presentes e iguais. | RF11, DP08 |
| CT-OFF-03 | Após **reiniciar o aparelho**, os dados criados offline continuam presentes. | RF11, DP08 |

#### Sincronização (T4)

| ID | Critério verificável | Req. |
|---|---|---|
| CT-SYNC-01 | Ao desativar o modo avião, as pendências são enviadas **sem ação do produtor**; ao final, o número de registros pendentes é zero e o back-end contém os mesmos valores que o aparelho. | RF12, DP05 (itens 3–5) |
| CT-SYNC-02 | Um registro criado em outro aparelho do mesmo produtor aparece localmente após a sincronização. | RF12, DP05 (item 5) |
| CT-SYNC-03 | O mesmo registro editado offline em dois aparelhos e depois sincronizado nos dois resulta, nos dois aparelhos e no back-end, na versão com a alteração mais recente (comportamento documentado em L01). | DP05 (itens 6–8), L01 |
| CT-SYNC-04 | Interromper a conexão durante um envio e repeti-lo **não duplica** registros no back-end. | DP05 (item 2) |
| CT-SYNC-05 | Um produtor não recebe dados de outro produtor. | DP01, RNF05 |

#### Eficiência (T4, T5)

| ID | Critério verificável | Req. |
|---|---|---|
| CT-EF-01 | **Sensores:** o GPS é ativado somente durante a captura de um vértice; o aplicativo solicita apenas permissão de localização **durante o uso** e não usa localização em segundo plano (verificável nas permissões do Android e no indicador de localização). | RNF04 |
| CT-EF-02 | **Comunicação:** sem conectividade, o aplicativo não faz tentativas periódicas de rede; com conectividade, a sincronização envia **somente registros pendentes**, agrupados em lote (verificável por registro de requisições). | RNF04, DP05 |
| CT-EF-03 | **Bateria, processamento e memória:** em uma sessão roteirizada de uso (criar unidade, capturar vértices, registrar atividades, sincronizar), consumo de CPU, memória e energia é medido com as ferramentas do Android (ex.: Profiler do Android Studio) e comparado a **limites numéricos a definir** no relatório técnico. | RNF04 |
| CT-EF-04 | **Armazenamento:** o tamanho do banco local é medido para um volume de referência (ex.: 50 unidades e 500 atividades) e registrado frente a um limite a definir no relatório técnico. | RNF04 |

#### Usabilidade e escalabilidade

| ID | Critério verificável | Req. |
|---|---|---|
| CT-USA-01 | Uma pessoa sem treinamento conclui a tarefa "cadastrar uma unidade com 4 vértices e registrar uma atividade" sem ajuda externa. | RNF03 |
| CT-ESC-01 | **Na Entrega Básica:** revisão da arquitetura confirma back-end gerenciado escalável, dados particionados por produtor e operação offline-first. Teste de carga **não** faz parte do escopo. | RNF05 |

#### APK final (T5)

| ID | Critério verificável | Req. |
|---|---|---|
| CT-APK-01 | O APK é instalado e aberto em celular Android **sem o Expo Go** instalado. | RNF02, DP06 |
| CT-APK-02 | No APK, o mapa de fundo e o polígono são exibidos (provedor de mapas configurado conforme L07). | RF06, L07 |
| CT-APK-03 | CT-OFF-01, CT-OFF-02 e CT-SYNC-01 são repetidos no APK com o mesmo resultado. | RF11, RF12 |

**Limitação da estratégia:**

| ID | Limitação |
|---|---|
| L07 | **Geração do APK e provedor de mapas.** (a) **EAS Build** (serviço em nuvem do Expo): perfil de build com `android.buildType = "apk"`; exige conta Expo. (b) **Compilação local**: `npx expo run:android --variant release` com Android Studio/Android SDK e JDK instalados; gera build *release* instalável, **não assinada para publicação em loja**. (c) **Provedor de mapas**: no Expo Go, o mapa funciona sem configuração adicional; no APK, a configuração depende do provedor escolhido. Se for **Google Maps** (via `react-native-maps`), é necessária chave de API do Google Cloud com o *Maps SDK for Android* ativado, informada em `androidGoogleMapsApiKey`, restrita ao nome do pacote e à impressão SHA-1 do certificado, e mantida fora do código-fonte. Outro provedor exigirá a configuração própria. **O provedor de mapas ainda não foi escolhido.** |

---

## §6 Premissas gerais

| ID | Premissa | Cat. |
|---|---|---|
| PM06 | Um produtor pode ter **várias** unidades de manejo ("unidades", no plural, em [P] p.1, Objetivo). Cada atividade pertence a **uma** unidade. | PM |
| PM07 | Offline: entrada manual, GPS e dados já salvos funcionam sem rede; a **imagem de fundo do mapa** depende de cache e pode não estar disponível em área nunca visitada com conexão. A marcação no mapa (RF04) e a exibição (RF06) ficam então limitadas. | PM |
| PM08 | Tempo estimado em **horas**; valores monetários em **reais (R$)**. | PM |
| PM09 | Custo operacional registrado como **valor único**; mão de obra, insumos e maquinário são entendidos como exemplos do que compõe o custo. | PM (ver PE03) |
| PM10 | A avaliação é **opcional** no registro e pode ser feita ou alterada depois (RF10). Não se introduz "status" da atividade. | PM |
| PM11 | Descrição da atividade é **texto livre**; os exemplos do enunciado (amostragem/monitoramento, plantio, colheita, adubação) podem ser oferecidos como sugestões. | PM |
| PM12 | **Versão mínima do Android: provisória.** Em 2026-11-03, o Expo SDK mais recente (58) suporta Android 7 ou superior. A versão mínima será confirmada quando for fixada a versão do Expo SDK efetivamente adotada na implementação. | PM |

---

## §7 Pendências de esclarecimento (para o professor)

| ID | Pergunta | Premissa adotada enquanto pendente |
|---|---|---|
| PE01 | "Triangulação" significa apenas formar o polígono e calcular sua área, ou deve-se exibir os triângulos? | PM01, §4.5 |
| PE02 | "Passadas como parâmetros" ([P] p.1, Objetivo) significa digitação manual ou também importação (arquivo, outra aplicação)? | Digitação manual (RF02) |
| PE03 | Custo operacional é valor único ou discriminado por mão de obra, insumos e maquinário? | PM09 |
| PE04 | O sistema deve permitir exclusão de unidades e atividades? | Não incluída |
| PE05 | Identificação/autenticação do produtor é esperada? | DP01 (decisão de projeto) |
| PE06 | O mapa de fundo deve funcionar offline? | PM07 |

---

## §8 Matriz de rastreabilidade

Colunas preenchidas progressivamente: casos de uso (etapa 03), classes (04), sequências (05), entidades (06). "Componente" refere-se à arquitetura de `01-descricao-do-software.md` §5.1. "Verificação" refere-se aos critérios de §5.2.

| Req. | Cat. | Caso de uso | Classes | Sequências | Entidades | Componente | Verificação |
|---|---|---|---|---|---|---|---|
| RF01 | OF | — | — | — | — | Telas · Repositórios · SQLite | CT-FUN-01 |
| RF02 | OF-ALT | — | — | — | — | Telas | CT-FUN-01 |
| RF03 | OF-ALT | — | — | — | — | Serviço de localização | CT-FUN-01, CT-EF-01 |
| RF04 | OF-ALT | — | — | — | — | Telas (mapa) | CT-FUN-01 |
| RF05 | OF | — | — | — | — | Serviço de geometria | CT-FUN-02, CT-GEO-02 |
| RF06 | OF | — | — | — | — | Telas (mapa) | CT-FUN-02, CT-APK-02 |
| RF07 | OF | — | — | — | — | Telas · Repositórios · SQLite | CT-FUN-03 |
| RF08 | OF | — | — | — | — | Telas · Repositórios · SQLite | CT-FUN-04 |
| RF09 | OF | — | — | — | — | Telas · Serviço de geometria · Repositórios | CT-FUN-05 |
| RF10 | OF | — | — | — | — | Telas · Repositórios | CT-FUN-04 |
| RF11 | OF | — | — | — | — | SQLite local | CT-OFF-01–03, CT-APK-03 |
| RF12 | OF | — | — | — | — | Serviço de sincronização · Back-end | CT-SYNC-01–02, CT-APK-03 |
| RNF01 | OF | — | — | — | — | Back-end (Supabase/PostgreSQL) | CT-SYNC-01 |
| RNF02 | OF | — | — | — | — | Aplicativo Android (RN/Expo) | CT-APK-01 |
| RNF03 | OF | — | — | — | — | Telas | CT-USA-01 |
| RNF04 | OF | — | — | — | — | Serviço de localização · Serviço de sincronização | CT-EF-01–04 |
| RNF05 | OF | — | — | — | — | Back-end · Serviço de sincronização | CT-ESC-01, CT-SYNC-05 |
| DP01 | DP | — | — | — | — | Back-end (identificação) | CT-SYNC-05 |
| DP02 | DP | — | — | — | — | Serviço de geometria | CT-GEO-02–03, CT-FUN-05 |
| DP03 | DP | — | — | — | — | Telas · Repositórios | CT-FUN-04, CT-FUN-05 |
| DP04 | DP | — | — | — | — | Serviço de geometria | CT-GEO-01, CT-GEO-04 |
| DP05 | DP | — | — | — | — | Serviço de sincronização | CT-SYNC-01–05, CT-EF-02 |
| DP06 | DP | — | — | — | — | Aplicativo Android | CT-APK-01 |
| DP07 | DP | — | — | — | — | Aplicativo Android (RN/Expo) | T1–T5 |
| DP08 | DP | — | — | — | — | SQLite local · Back-end | CT-OFF-02–03, CT-SYNC-01 |
| DP09 | DP | — | — | — | — | — | (define os critérios) |
