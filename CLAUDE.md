# AnimeBreakers

Jogo de Roblox com temática anime. Conceito, gênero e escopo ainda em mapeamento — ver `docs/vision.md`.

---

## Fase atual: 0 — Pré-produção

> **Bandeira verde parcial (DEC-015):** o código do Protótipo v0 (DEC-013) está liberado e roda em paralelo ao mapeamento. O resto do jogo segue a regra abaixo até a bandeira verde completa.

Estamos mapeando o jogo inteiro antes de construir. Regra da fase:

- **Nenhum código de gameplay** em `src/` até o usuário dar a **bandeira verde** (registrada em `docs/decisions.md`).
- Permitido antes da bandeira: documentação em `docs/`, protótipos técnicos pedidos explicitamente, e modelagem 3D de assets cuja ficha já esteja **Aprovada**.
- A bandeira verde exige `docs/open-questions.md` sem pergunta **bloqueante** em aberto.

Depois da bandeira, os agentes constroem sem depender do usuário: dúvida nova vira entrada em
`docs/open-questions.md` e o trabalho segue com a recomendação do agente, marcada como **Provisória**.

---

## Regras de código (invioláveis)

- **Zero comentários no código.** Nenhum `--`, `--[[ ]]`, docstring, TODO ou comentário explicativo em arquivo `.luau`/`.lua`. O código precisa se explicar por nomes claros de variáveis, funções e tipos. Explicação vai para `docs/` (Markdown), nunca para o código.
- **Não escrever `--!strict`** (nem `--!nonstrict`/`--!nocheck`). O `.luaurc` já define `"languageMode": "strict"` para o projeto inteiro.
- Ao editar um arquivo existente que tenha comentário ou `--!strict`, remova-os no mesmo trecho que tocar.
- Regra aplicada por hook (`.claude/hooks/no-comments.js`, registrado em `.claude/settings.json`): Write/Edit de `.luau`/`.lua` com `--` fora de string é bloqueado. `src/Modux` e pacotes do Wally ficam fora da checagem.
- Mensagens de commit em inglês, curtas e no padrão `feat:`/`fix:`/`refactor:`/`docs:`/`chore:`. Sem menção a IA, agente ou ferramenta de geração.
- Documentação (`docs/`, `README.md`) e agentes (`.claude/`) podem e devem ser detalhados.

---

## Fonte da verdade

`docs/` é a fonte da verdade do design. Comece por `docs/README.md`.

Ordem de autoridade quando dois documentos discordam:

1. `docs/decisions.md` (decisões do usuário, append-only)
2. documento de design com status **Aprovado**
3. documento com status **Rascunho**
4. qualquer coisa dita em conversa e não registrada — não vale até ser registrada

Ninguém além do usuário aprova. Agente propõe, secretária registra, usuário decide.

### IDs

Tudo que é referenciado entre documentos tem ID estável. Nunca reaproveite um ID apagado.

| Prefixo | O quê | Onde |
|---|---|---|
| `DEC-###` | decisão | `docs/decisions.md` |
| `Q-###` | pergunta aberta | `docs/open-questions.md` |
| `FEAT-###` | feature/mecânica | `docs/design/features.md` |
| `TASK-###` | tarefa de implementação | `docs/tasks/board.md` |
| `AST-###` | asset 3D/visual | `docs/art/asset-list.md` |
| `CHR-###` | personagem | `docs/story/characters.md` |
| `LVL-##` | fase/mapa/área | `docs/levels/LVL-##.md` |
| `ISL-##` | ilha (mapa temático) | `docs/design/islands.md` |
| `ENM-###` | inimigo | `docs/design/enemies.md` |
| `PET-###` | pet (personagem obtido em ovo) | `docs/design/pets.md` |
| `EGG-##` | ovo/caixa | `docs/design/pets.md` |
| `GP-##` | gamepass | `docs/design/monetization.md` |
| `DP-##` | developer product | `docs/design/monetization.md` |

Prefixos específicos do jogo (habilidades, inimigos, itens, etc.) são criados pela secretária conforme o
design for definido, e registrados nesta tabela.

### Status de documento

Todo documento de design começa com uma linha `Status:` — `Vazio`, `Rascunho`, `Em revisão`, `Aprovado`.
Mudar para **Aprovado** só com decisão do usuário registrada (`DEC-###`).

---

## Agentes (`.claude/agents/`)

| Agente | Papel |
|---|---|
| `secretary` | conduz o mapeamento com o usuário, mantém o GDD, decisões e perguntas abertas |
| `game-designer` | mecânicas, loop, progressão, economia, balanceamento, números |
| `narrative-writer` | lore, personagens, história, falas e textos |
| `art-director` | direção visual, style guide, fichas de asset para o modelador |
| `level-designer` | layout e fluxo de mapas/áreas, encontros, blockout |
| `modeler-3d` | modela/gera assets no Blender (MCP) e exporta para `assets/` |
| `researcher` | referências, APIs do Roblox, bibliotecas, viabilidade |
| `architect` | arquitetura técnica sobre Modux V3, contratos de rede, dados persistidos |
| `task-planner` | quebra specs aprovadas em `TASK-###` paralelizáveis |
| `backend-coder` | Services e Components do servidor |
| `frontend-coder` | Controllers do client, UI em Vide, câmera, input, VFX |
| `qa-tester` | plano de teste por feature, análise estática, validação de critérios |
| `debugger` | causa raiz de bug, correção mínima |

Fluxo e paralelismo: `docs/PIPELINE.md`.

---

## Stack técnica

Leia `README.md` (raiz) antes de escrever qualquer código. Resumo do que não pode ser esquecido:

- Framework **Modux V3** em `src/Modux` (não editar; gerados: `*/Manifest/init.luau`, `*/Modules.luau`, `shared/Libs.luau`).
- Estrutura **feature-based**: `src/<Feature>/server/` e `src/<Feature>/client/`. Feature nova = pasta nova.
- Módulo com mais de um arquivo é pasta com `init.luau`.
- Rede: **Lync**, definições em `src/Libs/Net/init.luau`. Set (`replicate`) para estado compartilhado, packet para evento/privado. `keyBy` só campo finito.
- Responder de rede só em Service/Controller dentro de `OnInit`. Componente não registra responder.
- **Charm no servidor, Vide no client.** Lync e Vide são requeridos direto, nunca em `src/Libs`.
- `LuauSolverV2`, `const` para valores imutáveis. Strict vem do `.luaurc` (sem `--!strict`).
- Ordem de build: `rogen build` → `modux generate` → `rojo serve`.
- Verificação: `modux check` e `tools/analyze.ps1` (zero erro antes de entregar).

Código, identificadores e commits em inglês. Documentação e conversa em pt-BR.

## Assets

- Fontes Blender: `assets/blender/<categoria>/AST-###_<nome>.blend`
- Exportados: `assets/models/<categoria>/AST-###_<nome>.fbx`
- Texturas: `assets/textures/`, referências visuais: `assets/reference/`
- Limites de orçamento (tris, texturas) ficam em `docs/art/style-guide.md`.
- **Asset de terceiros só entra com licença verificada** que permita uso comercial (CC0, CC-BY com crédito, compra com licença ou permissão escrita), registrada em `docs/art/credits.md`.
- **Nada de IP de anime existente**: nomes, personagens, golpes, logos e visuais reconhecíveis de obras reais não entram. Inspiração de gênero sim, cópia não.
