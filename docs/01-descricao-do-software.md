# 01 — Descrição do Software

| Campo | Valor |
|---|---|
| ID | AGM-DESC |
| Versão | 0.2.0 |
| Status | Proposed (aguarda aprovação do autor) |
| Data | 2026-11-03 |
| Owner | Autor do projeto (aluno) |
| Fonte de requisitos | `PROJETO_Gerenciamento de Unidades de Manejo Rural com Tecnologia Mobile.pdf` (doravante **[P]**) |
| Material de apoio | `Desenvolvimento movel.pdf` (doravante **[S]**), sem força de requisito |
| Referências internas | `02-requisitos.md` |
| Histórico | 0.1.0 — rascunho inicial · 0.2.0 — plataforma Android e framework aprovados (DP06, DP07); estratégia de testes (DP09) |

Convenção de classificação usada em todos os documentos (detalhada em `02-requisitos.md` §1):
**OF** requisito oficial · **OF-ALT** alternativa oficial de entrada · **DP** decisão de projeto (*Proposed* ou *Accepted*) · **PM** premissa de modelagem · **PE** pendente de esclarecimento.

---

## §1 Propósito

O **AgroManejo** é um aplicativo móvel destinado a **produtores rurais** para gerenciar atividades agropecuárias em **unidades de manejo definidas geograficamente** ([P] p.1, Objetivo).

O produtor delimita cada unidade por meio de coordenadas geográficas, visualiza o polígono resultante em um mapa e registra, para cada unidade, as atividades previstas com seus tempos, custos, receitas e avaliação ([P] p.1, itens 1 e 2).

## §2 Usuários

| Ator | Descrição | Origem |
|---|---|---|
| Produtor rural | Usuário final; define unidades de manejo e registra atividades. | OF — [P] p.1 |
| Back-end remoto | Sistema externo que armazena os dados e participa da sincronização. | OF — [P] p.1 (Descrição), p.2 |

Não há outros perfis de usuário (administrador, técnico etc.) no enunciado; nenhum é acrescentado.

## §3 Funcionalidades

### §3.1 Exigidas pelo enunciado (OF)

1. **Definir unidade de manejo** por três ou mais coordenadas geográficas ([P] p.1, item 1).
2. **Delimitar a área** como polígono a partir dos pontos — o enunciado usa o termo "triangulação" ([P] p.1). A interpretação técnica está em `02-requisitos.md` §4.
3. **Visualizar a área delimitada em mapa** ([P] p.1, Requisitos Técnicos).
4. **Registrar atividades** na unidade: descrição, tempo estimado, custo operacional, receitas esperadas ([P] p.1, item 2).
5. **Avaliar a atividade** como positiva ou negativa, com observações ([P] p.1, item 2).
6. **Editar coordenadas e registros de atividades** a qualquer momento ([P] p.2).
7. **Funcionar offline** quando necessário e **sincronizar** os dados quando houver conectividade ([P] p.2).

### §3.2 Alternativas oficiais de entrada de coordenadas (OF-ALT)

Cada vértice pode ser obtido por uma de três formas ([P] p.1, Objetivo e item 1):
**(a)** digitação manual; **(b)** geolocalização do próprio dispositivo; **(c)** marcação direta no mapa.

### §3.3 Decisões de projeto que complementam o enunciado (DP)

Não são exigências do professor; são decisões justificadas em `02-requisitos.md` §5:

- *Proposed:* identificação do produtor (DP01), cálculo e exibição da medida da área (DP02), listagem de unidades e atividades (DP03), validação geométrica do polígono (DP04), mecanismo de sincronização (DP05), persistência local e remota (DP08).
- *Accepted:* plataforma Android (DP06), React Native + Expo + TypeScript (DP07), estratégia de testes (DP09).

## §4 Contexto de uso

- Uso em campo, em **celulares Android** (DP06), frequentemente **sem conectividade** ou com conexão instável — motivo do requisito offline ([P] p.2).
- Dispositivos com **restrições de bateria, armazenamento, comunicação e processamento** ([P] p.2).
- Público potencialmente **grande e geograficamente disperso** ([P] p.2).
- Produtor sem formação técnica — exige **interface amigável e intuitiva** ([P] p.1).

## §5 Visão geral da solução

### §5.1 Arquitetura

```
┌──────────── Aplicativo Android (React Native + Expo + TS) ───┐
│ Telas: unidades · mapa/polígono · atividades                 │
│ Serviços: localização · geometria (polígono/área) · sincron. │
│ Repositórios ──► SQLite local (dados do app + pendências)    │
└───────────────────────────┬──────────────────────────────────┘
                            │ HTTPS, somente com conectividade
                            │ envio de pendências → recebimento de alterações
┌───────────────────────────▼──────────────────────────────────┐
│ Back-end remoto: PostgreSQL gerenciado (Supabase)            │
│ API REST · identificação do produtor · regras de acesso      │
└──────────────────────────────────────────────────────────────┘
```

| Camada | Tecnologia | Status | Papel |
|---|---|---|---|
| Plataforma | Android (sem versão iOS) | **Accepted** (DP06) | Ambiente de execução |
| Front-end | React Native + Expo + TypeScript | **Accepted** (DP07) | Aplicativo móvel |
| Dados locais | SQLite no dispositivo | Proposed (DP08) | Permite operar offline |
| Back-end remoto | Supabase (PostgreSQL gerenciado) | Proposed (DP08) | Persistência central, API e acesso por produtor |
| Sincronização | Mecanismo próprio do projeto ou biblioteca ainda não escolhida | Proposed (DP05) | Reconciliar dados locais e remotos |

**Ressalva sobre sincronização.** SQLite e Supabase **não se sincronizam automaticamente**. O mecanismo proposto e suas limitações estão em `02-requisitos.md` §5.1 (DP05).

### §5.2 Ambiente de desenvolvimento e testes

- Desenvolvimento em **VS Code com Claude Code** (DP07).
- Testes iniciais em **celular Android físico com Expo Go**; testes complementares no **emulador do Android Studio**; testes automatizados de lógica; testes de offline e sincronização; teste final com **APK independente do Expo Go** (DP09).
- O **Android Studio não é obrigatório** na configuração inicial; é previsto para o emulador e para compilações locais (DP07).

Critérios verificáveis de cada nível: `02-requisitos.md` §5.2.

## §6 Escopo da Entrega Básica

**Incluído:** projeto do software — descrição, requisitos, casos de uso, diagrama de classes, diagramas de sequência, modelo ER e relatório técnico ([P] p.2, Entregas).

**Excluído nesta fase:** código, instalação de dependências, configuração do ambiente mobile, banco de dados implantado, APIs, implementação da sincronização e **execução** dos testes. O protótipo funcional e os testes pertencem à **Entrega Avançada** ([P] p.2).

**Fora do projeto:** versão iOS (DP06).

**Não incluído como funcionalidade** (não consta do enunciado): exclusão de registros, histórico de alterações, relatórios financeiros, compartilhamento entre produtores, notificações.
