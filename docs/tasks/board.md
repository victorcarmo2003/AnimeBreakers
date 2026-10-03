# Board

Responsável: `task-planner`.

Status: `Pendente` → `Em andamento (dono)` → `Em QA` → `Feito` / `Falhou`. Status extra:
`Aguardando assets do usuário` (a task só começa quando o usuário entregar o que está listado nela).

Escopo atual: **Protótipo de apresentação (v0)**. Autorização: DEC-015 (bandeira verde parcial) e DEC-028
(PT-01..PT-15 aceitas; PT-16..PT-20 seguidas como Provisórias até a secretária registrar). Spec válida para o
v0, mesmo em Rascunho: `docs/tech/architecture.md`, `docs/tech/network.md`, `docs/tech/data.md`,
`docs/tech/content-data.md` e as FEAT com coluna v0 = Sim/Parcial em `docs/design/features.md`.
Critérios A1..A19: DEC-013, alterados/estendidos por DEC-016, DEC-018, DEC-020, DEC-021, DEC-022, DEC-023.

Gerado em 2026-10-03 a partir da seção 13 de `architecture.md` (24 passos), reagrupado para respeitar os
pontos de conflito. Atualizado em 2026-10-03 com a **Revisão 3** da arquitetura (PT-21..PT-25: ledger
mantém quem saiu, `Hits` privado, cooldown a partir do cast, dano `HitDelay` após o próprio cast, mecanismo
de dev `DevService` + `<Feature>DevService` só no Studio, arch §4.5, §4.6, §5.4, §7.3). PT-21..PT-25 seguidas
como **Provisórias** até a secretária registrar.

---

## Regras para toda task de código (DoD-C)

Toda task marcada **DoD-C** só vai para `Em QA` se cumprir, além dos critérios próprios:

1. **Zero comentários** em `.luau`/`.lua` (`--`, `--[[ ]]`, TODO). O hook `.claude/hooks/no-comments.js` bloqueia.
2. **Sem `--!strict`/`--!nonstrict`/`--!nocheck`** (o `.luaurc` já é strict). Arquivo tocado que tenha um deles: remover.
3. Sequência de build: `rogen build` → `modux generate` → `modux check` → `tools/analyze.ps1` com **0 erros**.
4. Não editar `src/Modux` nem arquivos gerados (`*/Manifest/init.luau`, `*/Modules.luau`, `shared/Libs.luau`).
5. Responder de rede só no `OnInit` de Service/Controller; Component nunca registra responder.
6. Charm no servidor, Vide no client; Lync e Vide requeridos direto.
7. Identificadores em inglês; commit `feat:`/`fix:`/`refactor:` curto, sem menção a IA/ferramenta.
8. Worktree própria por task; não tocar arquivo fora da coluna "Toca" sem avisar no board.

## Pontos de conflito (nunca em paralelo)

| Arquivo | Tasks que tocam (ordem obrigatória) |
|---|---|
| `src/Libs/Net/init.luau` | TASK-001 → TASK-002 → TASK-005 (nenhuma outra toca) |
| `src/Profile/server/ProfileService/Template.luau` | só TASK-005 |
| `src/Shared/Content/Interface.luau` | TASK-003 → TASK-009 → {TASK-013, TASK-023, TASK-024, TASK-025} **uma de cada vez**, na ordem em que os assets do usuário chegarem |
| `src/Shared/Content/AnimationSets.luau`, `Characters.luau` | TASK-003 → TASK-008 (depois só QA no A13, TASK-029) |
| `src/Combat/server/CombatService/` | TASK-015 → TASK-019 |
| `src/Combat/server/CombatDevService.luau` | TASK-015 → TASK-019 |
| `src/Dev/server/DevService.luau` | só TASK-006 (as outras só declaram `Require`) |
| `src/Shared/Content/Effects.luau` | TASK-003 → quem levar as variantes `Lite` (TASK-012 ou follow-up da TASK-003, ver Pendências) |
| `README.md` (raiz) | só TASK-001 |
| `src/Combat/client/CommandController.luau` | TASK-017 → TASK-021 |
| `src/Interface/client/InterfaceController.luau` | TASK-022 → TASK-026 |
| `.rogen.json` | só TASK-007 (e TASK-029 se o teste A13 precisar) |

---

## Tabela

| ID | Título | Dono | Onda | Depende de | Toca | Spec | Status |
|---|---|---|---|---|---|---|---|
| TASK-001 | Remover features Vital e Round (+ entradas `Vitals`/`Round` do Net, README raiz) | backend-coder | 0 | — | `src/Vital/`, `src/Round/`, `src/Libs/Net/init.luau`, `README.md` | PT-07, arch §9 | Em andamento (usuário removeu `src/Vital` e `src/Round`; falta tirar `Vitals`/`Round` do Net, regenerar e atualizar README raiz) |
| TASK-002 | Net v0: novas entradas Lync | backend-coder | 0 | TASK-001 | `src/Libs/Net/init.luau` | `network.md` | Pendente |
| TASK-003 | `src/Shared/Content`: tipos, lookups e tabelas do v0 | backend-coder | 0 | — | `src/Shared/Content/*` | `content-data.md`, PT-10, PT-15, PT-20 | Em QA (commit 612ddd0 em branch de worktree, aguardando merge na main) |
| TASK-007 | Assets placeholder R6, efeitos e mapa de dev | frontend-coder | 0 | — | `assets/roblox/`, `.rogen.json` | arch §8, PT-11, FEAT-023, DEC-019 | Em QA (commit 9563359 em branch de worktree, aguardando merge na main) |
| TASK-027 | Plano de teste do v0 (A1–A19) | qa-tester | 0 | — | `docs/tests/v0-plan.md` | DEC-013 + alterações | Feito (`docs/tests/v0-plan.md`) |
| TASK-004 | `ContentService`: validação das tabelas no boot | backend-coder | 1 | TASK-003, TASK-007 | `src/Content/server/ContentService.luau` | `content-data.md` "Validação" | Pendente |
| TASK-005 | Perfil v0: Template, Mock, Mutate, Migrations, replicação dividida, ProfileController | backend-coder | 1 | TASK-002, TASK-003 | `src/Profile/**`, `src/Libs/Net/init.luau` (só `Profile`) | `data.md`, PT-08, PT-09, PT-16, PT-20 | Pendente |
| TASK-006 | `EnemyService` + Component `EnemySpawn` + `DevService` + `EnemyDevService` | backend-coder | 1 | TASK-002, TASK-003, TASK-007 | `src/Enemy/server/*`, `src/Dev/server/DevService.luau` | arch §4.2, §4.6, PT-02, PT-21, PT-25, FEAT-002 | Pendente |
| TASK-008 | `RigAnimator` + IDs de animação placeholder | frontend-coder | 1 | TASK-003, TASK-007 | `src/Rig/RigAnimator/`, `src/Shared/Content/AnimationSets.luau` | arch §5.6, PT-15 | Pendente |
| TASK-009 | UI base: componentes Vide genéricos + convenção `Interface.luau` | frontend-coder | 1 | TASK-003 | `src/Interface/client/Components/*`, `src/Shared/Content/Interface.luau` | FEAT-015, DEC-017, arch §7.4 | Pendente |
| TASK-010 | `PetService`: unidades, StarterPets, set `Pets` | backend-coder | 2 | TASK-005 | `src/Pet/server/PetService.luau` | arch §4.3, `data.md` | Pendente |
| TASK-011 | `EnemyController` + `HealthBar` (Vide) | frontend-coder | 2 | TASK-006, TASK-007, TASK-008 | `src/Enemy/client/*` | arch §3, §7.1, FEAT-002 | Pendente |
| TASK-012 | `EffectController` (pool, limite, `Lite`) | frontend-coder | 2 | TASK-003, TASK-007 | `src/Effect/client/EffectController.luau` | arch §7.1, §10, `content-data.md` EffectDef | Pendente |
| TASK-013 | Tela `Hud` em Vide com story (dados falsos) | frontend-coder | 2 | TASK-009 | `src/Interface/client/Screens/Hud/`, `Components/PetSlot/`, `Interface.luau`, remove `Components/Counter` | FEAT-015, FEAT-025, DEC-017, DEC-018, DEC-022 | Aguardando assets do usuário |
| TASK-014 | `EconomyService`: divisão de `Rewards.Coins` + packet `Reward` + `EconomyDevService` | backend-coder | 2 | TASK-005, TASK-006 | `src/Economy/server/EconomyService.luau`, `EconomyDevService.luau` | arch §4.5, §4.6, PT-21, PT-25, FEAT-004, DEC-011, DEC-021 | Pendente |
| TASK-023 | Tela `Inventory` (só visual) | frontend-coder | 2 | TASK-009 | `src/Interface/client/Screens/Inventory/`, `Interface.luau` | FEAT-012, DEC-018 | Aguardando assets do usuário |
| TASK-024 | Tela `Shop` (só visual) | frontend-coder | 2 | TASK-009 | `src/Interface/client/Screens/Shop/`, `Interface.luau` | FEAT-026, DEC-018 | Aguardando assets do usuário |
| TASK-025 | Tela `BattlePass` (só visual) | frontend-coder | 2 | TASK-009 | `src/Interface/client/Screens/BattlePass/`, `Interface.luau` | FEAT-027, DEC-018 | Aguardando assets do usuário |
| TASK-015 | `CombatService` parte 1: Attack/Recall (`Handle*`), Engagement por jogador, dano básico, `Hits` privado, leash, morte + `CombatDevService` | backend-coder | 3 | TASK-006, TASK-010 | `src/Combat/server/CombatService/` (`init`, `Engagement`), `src/Combat/server/CombatDevService.luau` | arch §4.4, §4.6, §5.2, §5.3 (1, 2, 7), PT-14, PT-17, PT-22, PT-25, FEAT-006/007/021, DEC-024 | Pendente |
| TASK-016 | `PetController` + `Formation`: seguir, anel, `Assist`, teleporte, `BulkMoveTo` | frontend-coder | 3 | TASK-010, TASK-011, TASK-012 | `src/Pet/client/PetController/` | arch §6, PT-05, PT-19 | Pendente |
| TASK-017 | `InputController.OnWorldTap` + `CommandController` (Attack/Recall) | frontend-coder | 3 | TASK-011 | `src/Input/client/InputController.luau`, `src/Combat/client/CommandController.luau` | arch §7.2, PT-12, FEAT-007, FEAT-017, FEAT-021 | Pendente |
| TASK-018 | `DamageNumberController` | frontend-coder | 4 | TASK-011, TASK-015, TASK-016 | `src/Combat/client/DamageNumberController.luau` | arch §7.3, PT-22, FEAT-020 | Pendente |
| TASK-019 | `CombatService` parte 2: coreografia, SkillQueue, auto/manual, `Beat` privado | backend-coder | 4 | TASK-005, TASK-015 | `src/Combat/server/CombatService/` (`init`, `Engagement`, `Choreography`, `SkillQueue`), `src/Combat/server/CombatDevService.luau` | arch §4.6, §5.2–5.5, PT-16, PT-18, PT-23, PT-24, PT-25, FEAT-022/024/025, DEC-020/022/023 | Pendente |
| TASK-028 | QA do núcleo servidor (gate da Fase 1) | qa-tester | 4 | TASK-004, TASK-006, TASK-014, TASK-015, TASK-027 | `docs/tests/` | A1, A3, A6, A11, A17 (lado servidor) | Pendente |
| TASK-020 | `CombatController` + `Stage`: palco local do dono | frontend-coder | 5 | TASK-012, TASK-016, TASK-019 | `src/Combat/client/CombatController/` | arch §5.5, PT-04, PT-18, PT-19, FEAT-024 | Pendente |
| TASK-021 | `CommandController`: UseSkill, SetAutoSkill, `SlotState` | frontend-coder | 5 | TASK-017, TASK-019 | `src/Combat/client/CommandController.luau` | arch §5.4, PT-16, FEAT-025, DEC-022 | Pendente |
| TASK-022 | `InterfaceController` + HUD ligada aos controllers reais | frontend-coder | 6 | TASK-013, TASK-014, TASK-021 | `src/Interface/client/InterfaceController.luau`, `Screens/Hud/` | arch §7.4, FEAT-015, FEAT-004, FEAT-021, FEAT-025 | Aguardando assets do usuário (via TASK-013) |
| TASK-026 | Abrir/fechar Inventário, Loja e Battle Pass a partir da HUD | frontend-coder | 7 | TASK-022, TASK-023, TASK-024, TASK-025 | `src/Interface/client/InterfaceController.luau`, `Screens/Hud/` | FEAT-015, DEC-018 | Aguardando assets do usuário (via 023–025) |
| TASK-029 | QA completo do v0 (A1–A19) | qa-tester | 8 | todas as anteriores (001–028) | `docs/tests/` | DEC-013 + alterações | Pendente |
| TASK-030 | Ajustes de orçamento (LOD, limites de VFX e números) conforme medição | frontend-coder | 9 | TASK-029 | `src/Pet/client/`, `src/Enemy/client/`, `src/Effect/client/`, `src/Combat/client/DamageNumberController.luau`, `src/Shared/Content/Tuning.luau` | arch §10, A12 | Pendente |

Total: 30 tasks (10 backend-coder, 17 frontend-coder, 3 qa-tester). Falha de QA gera `TASK-031+` de
correção, nunca reabre ID.

---

## Próximas paralelizáveis

### Primeira onda (Onda 0) — pode começar AGORA

| Agente | Tasks | Observação |
|---|---|---|
| backend-coder (sessão 1) | **TASK-001** (terminar), depois **TASK-002** | sequenciais: as duas tocam `src/Libs/Net/init.luau`; TASK-001 também atualiza `README.md` raiz |
| qa-tester | QA de **TASK-003** e **TASK-007** | commits 612ddd0 e 9563359 em branches de worktree; merge na main após aprovação |
| — | TASK-027 | Feito (`docs/tests/v0-plan.md`) |

Onda 1 libera assim: TASK-008 e TASK-009 quando TASK-003/007 estiverem `Feito` (merge na main);
TASK-004 idem; TASK-005 e TASK-006 também precisam da TASK-002.

### Ondas seguintes (liberam quando as dependências ficam `Feito`)

| Onda | backend-coder | frontend-coder | qa-tester |
|---|---|---|---|
| 1 | TASK-004 ∥ TASK-005 ∥ TASK-006 | TASK-008 ∥ TASK-009 | — |
| 2 | TASK-010 ∥ TASK-014 | TASK-011 ∥ TASK-012; TASK-013/023/024/025 quando os assets chegarem (uma por vez) | — |
| 3 | TASK-015 | TASK-016 ∥ TASK-017 | — |
| 4 | TASK-019 | TASK-018 | TASK-028 |
| 5 | — | TASK-020 ∥ TASK-021 | — |
| 6 | — | TASK-022 | — |
| 7 | — | TASK-026 | — |
| 8 | — | — | TASK-029 |
| 9 | (correções) | TASK-030 | — |

Caminho crítico (sem UI): 001 → 002 → 005 → 010 → 015 → 019 → 020/021 → 022 → 029.
Caminho crítico com UI: depende da data de entrega dos assets da HUD (TASK-013).

---

## Pendências registradas

| # | Pendência | Onde resolver | Origem |
|---|---|---|---|
| P1 | `README.md` raiz ainda descreve as features Vital e Round. | TASK-001 (escopo ampliado: atualizar README raiz) | revisão 2026-10-03 |
| P2 | Erro de tipo em `src/Profile/server/ProfileService/init.luau:22` (`ProfileStore.New`). Causa provável: `wally.lock` divergente (arquivo modificado no working tree). | TASK-005: conferir `wally.lock`/versão do ProfileStore antes de mexer no Perfil; `tools/analyze.ps1` = 0 no arquivo | análise estática 2026-10-03 |
| P3 | Variantes `Lite` dos efeitos (`BlinkOut`, `BlinkIn`, `SkillBurst`, `SkillCharge`) precisam entrar em `src/Shared/Content/Effects.luau` (campo da EffectDef em `content-data.md`). | TASK-012 (critério 2 depende disso) ou follow-up da TASK-003 se o QA da 003 pedir; quem pegar primeiro, uma de cada vez (conflito em `Effects.luau`) | QA TASK-003/TASK-007 |
| P4 | Resolvida: PT-21..PT-25 registradas em DEC-036; FEAT-004/022/024 alinhados. | secretária | DEC-036 |

---

## Dependências externas (usuário)

| O quê | Bloqueia | Fallback enquanto não chega |
|---|---|---|
| HUD principal: PNGs + JSON ("Figma to JSON") + foto de referência (DEC-017) | TASK-013 → TASK-022 → TASK-026, A10, A14 manual pela HUD | nenhum para a tela; backend e controllers seguem; QA usa Command Bar/story |
| Inventário: PNGs + JSON + foto | TASK-023 | — |
| Loja: PNGs + JSON + foto | TASK-024 | — |
| Battle Pass: PNGs + JSON + foto | TASK-025 | — |
| Upload das imagens da UI no Roblox pelo dono do jogo e IDs (Q-036) | TASK-013, 023, 024, 025 (IDs em `Interface.luau`) | IDs `rbxassetid://0` + `Placeholder` até o upload |
| Mapa de teste numa baseplate com Parts `EnemySpawn` (DEC-014) | não bloqueia | mapa de dev de TASK-007 |
| Animações placeholder publicadas pelo dono do jogo (Q-036 a) para as chaves de combate | não bloqueia | animações R6 de propriedade da Roblox reaproveitadas (TASK-008) |
| Modelos/animações do contratante | só A13 "de verdade" | A13 testado com um segundo placeholder (TASK-029) |

---

## Detalhe das tasks

### TASK-001 — Remover features Vital e Round

- Dono: backend-coder. Onda 0. Depende de: —. Spec: PT-07, `architecture.md` §9.
- Toca: `src/Vital/` (apagar), `src/Round/` (apagar), `src/Libs/Net/init.luau` (só remover `Vitals` e `Round`), `README.md` raiz (pendência P1).
- Status: **Em andamento**. O usuário já removeu `src/Vital` e `src/Round` (deleções staged). Falta: tirar `Vitals`/`Round` do Net, regenerar (`rogen build` → `modux generate`) e atualizar o README raiz.
- Não toca `Profile` (o packet `Profile` muda na TASK-005).
- Critérios de aceite:
  1. Pastas `src/Vital` e `src/Round` não existem; nenhum `require`/referência a `Vital`, `VitalService`, `VitalController`, `RoundService`, `RoundController`, `Net.Vitals`, `Net.Round` no `src/` (grep vazio, fora de `src/Modux`).
  2. `src/Libs/Net/init.luau` sem `Vitals`/`Round`; demais entradas inalteradas.
  3. Arquivos gerados regenerados (`Manifest`/`Modules.luau` sem Vital/Round).
  4. `README.md` raiz sem descrição das features Vital e Round (exemplos trocados ou removidos).
  5. Play solo no Studio: sem erro no Output de servidor e client no boot.
  6. **DoD-C**.

### TASK-002 — Net v0: novas entradas Lync

- Dono: backend-coder. Onda 0. Depende de: TASK-001. Spec: `network.md` (esboço do `init.luau`).
- Toca: `src/Libs/Net/init.luau`.
- Adiciona: `ContentId`, `Inventory`, `Reward`, `Enemies`, `Pets`, `Attack`, `Recall`, `UseSkill`, `SetAutoSkill`, `Beat` (`:timestamped()`), `Hits`. **Não** muda `Profile` (fica para a TASK-005, junto com quem o usa). Nada de `ForceSkills`/`ForceCooldown`.
- Critérios de aceite:
  1. Schemas idênticos ao esboço de `network.md` (nomes, tipos, limites, enums `Move` e `Kind`).
  2. `Lync.start()` roda sem erro de schema no Studio (servidor e client).
  3. Os 3 pontos a confirmar de `network.md` foram testados no Studio e o resultado registrado em `network.md` (seção "Pontos a confirmar"): `Lync.vec3()` sem argumento; `optional` + `Lync.none` em `update`; `:timestamped()` com `fireClient`. Se algum falhar, aplicar a alternativa documentada (ex.: `At = Lync.f64()` no `Beat`) e registrar.
  4. **DoD-C**.

### TASK-003 — `src/Shared/Content`

- Dono: backend-coder. Onda 0. Depende de: —. Spec: `content-data.md`, PT-10, PT-15, PT-20.
- Status: **Em QA** (commit 612ddd0 em branch de worktree, aguardando merge na main). Variantes `Lite` em `Effects.luau`: pendência P3.
- Toca: `src/Shared/Content/init.luau`, `Types.luau`, `Rarities.luau`, `Characters.luau`, `AnimationSets.luau`, `Abilities.luau`, `Effects.luau`, `Pets.luau`, `Enemies.luau`, `Eggs.luau`, `Tuning.luau`, `Interface.luau` (`{ Images = {} }`). Arquivos de dado puro; exceção aceita ao limite de ~5 arquivos.
- Conteúdo v0: 1 inimigo `ENM-001` (vida 1000, `Rewards = { Coins = 100 }`, respawn 5 s), 3 pets `PET-001..003` (dano 10, intervalo 1,0 s, `ABL-001`), 1 habilidade `ABL-001` (Power 5, HitDelay 0,4, Cooldown 8), AnimationSets `PetR6` (com `Assist`) e `EnemyR6` (com `Defend`/`Hit`/`HitHeavy`, `Reactions`), personagens `DummyR6Red`/`DummyR6Blue`/`DummyR6Green`/`DummyR6Grey`, efeitos `BlinkOut`, `BlinkIn`, `SkillBurst`, `SkillCharge`, 6 raridades Provisórias (DEC-005), `Tuning` completo da tabela de `content-data.md`. IDs de animação `rbxassetid://0` + `Placeholder = true` (preenchidos na TASK-008). Nomes sem IP de anime (DEC-025).
- Critérios de aceite:
  1. `Content.Pet`, `Enemy`, `Character`, `AnimationSet` (herança resolvida), `Ability`, `Effect`, `Rarity`, `Tuning` existem, tipados com `Types.luau`, e falham alto (`error`) com ID inexistente.
  2. `Content.AnimationSet("PetR6Blue")` (ou equivalente que herde) retorna trilhas herdadas + sobrescritas.
  3. Tabelas sem função, sem `require` de serviço, sem estado; chave = `Id`.
  4. Enum `Move` em `Types.luau` igual ao de `Beat.Move` em `network.md`.
  5. Require de `ReplicatedStorage.shared.Content` funciona no servidor e no client (conferir mapeamento do rogen).
  6. **DoD-C**.

### TASK-004 — `ContentService`

- Dono: backend-coder. Onda 1. Depende de: TASK-003, TASK-007. Spec: `content-data.md` "Validação"; arch §4.1 (Priority 950).
- Toca: `src/Content/server/ContentService.luau`.
- Critérios de aceite:
  1. Boot com os dados do v0: nenhum erro; aviso com a contagem de trilhas `Placeholder`.
  2. Cada regra de erro da seção "Validação" foi provada quebrando o dado de propósito numa cópia local (chave ≠ Id, referência quebrada, ciclo de `Inherits`, `Assist` ausente/sem `Looped`, `Turn` sem terminar em `BackOff`, `Reactions` inválida, `Model` ausente em `ReplicatedStorage.Assets`, número negativo, `SkillGap < 0`) e a mensagem cita arquivo + ID. Lista dos casos testados no relatório da task.
  3. `HitHeavy` ausente é resolvido para `Hit` antes da checagem.
  4. Base de A13: trocar `Model` de um personagem para um nome inexistente para o boot com mensagem clara.
  5. **DoD-C**.

### TASK-005 — Perfil v0

- Dono: backend-coder. Onda 1. Depende de: TASK-002, TASK-003. Spec: `data.md`, PT-08, PT-09, PT-16, PT-20.
- Toca: `src/Profile/server/ProfileService/Template.luau`, `init.luau`, `Migrations.luau` (novo), `src/Profile/client/ProfileController.luau`, `src/Libs/Net/init.luau` (só o struct `Profile` → `{ Coins = vlq, AutoSkill = bool }`). **Única** task que toca o Template.
- Antes de começar: resolver a pendência P2 (erro de tipo em `ProfileService/init.luau:22`, `ProfileStore.New`; conferir `wally.lock` e a versão instalada do ProfileStore).
- Critérios de aceite:
  0. `tools/analyze.ps1` sem o erro de `ProfileService/init.luau:22`; causa registrada no relatório (se for `wally.lock`, dizer qual versão ficou).
  1. Template = `data.md` (Version 1, Coins 0, AutoSkill true, Pets {}, Equipped {}, NextPetUid 1, EquipSlots 3); `export type OwnedPet` com `Pet`, `Level`, `Stars`, `Xp`, `Gear`. `Level`/`Playtime` removidos do Template, do Net e do client.
  2. `Content.Tuning.PersistProfiles = false` → sessão em `Store.Mock`; trocar para `true` usa o store real sem outra mudança.
  3. `Bind` itera chaves do Template (campo salvo obsoleto não vira atom).
  4. `Mutate(player, field, fn)` clona, aplica e grava; mudar `Pets` notifica o effect.
  5. Replicação dividida: mudar `Coins` dispara só `Profile`; mudar `Pets`/`Equipped` dispara só `Inventory`; `ClientReady` envia os dois.
  6. `Migrations.luau` existe (lista vazia na versão 1); `Version` ausente vira 1; `Version > CURRENT_VERSION` → kick sem gravar (testado com dado forjado no Mock).
  7. `ProfileController` expõe sources `Coins`, `AutoSkill`, `Pets`, `Equipped`, `Ready`, `LastReward` (escuta `Profile`, `Inventory`, `Reward`).
  8. **DoD-C**.

### TASK-006 — `EnemyService` + `EnemySpawn`

- Dono: backend-coder. Onda 1. Depende de: TASK-002, TASK-003, TASK-007 (mapa de dev para testar). Spec: arch §4.2, §4.6, PT-02, PT-21, PT-25, FEAT-002, FEAT-004 (ledger).
- Toca: `src/Enemy/server/EnemyService.luau`, `src/Enemy/server/EnemySpawn.luau`, `src/Enemy/server/EnemyDevService.luau` (novo), `src/Dev/server/DevService.luau` (novo, feature nova `src/Dev`). Única task que cria/edita `DevService`.
- Critérios de aceite:
  0. Ledger **não** escuta `PlayerRemoving` e nunca apaga entrada antes do respawn (PT-21).
  1. Part com tag `EnemySpawn` + `EnemyId = "ENM-001"` → `Net.Enemies:add` com `Position` (centro da face de baixo), `Yaw` (do `LookVector`), vida cheia, `Alive = true`, `Life = 1`. `EnemyId` inválido → `warn`, sem spawn. (A1, lado servidor)
  2. `EnemyService:ApplyDamage(uid, n, player)` pelo Command Bar reduz `Health`, soma no ledger e devolve o aplicado; overkill não conta.
  3. Vida 0 → `Alive = false`, signal `Died(uid, ledger copiado, def)`; após `RespawnSeconds` (atributo da Part sobrescreve a tabela) → vida cheia, ledger zerado, `Life + 1`. (A3, lado servidor)
  4. `Uid` crescente, nunca reaproveitado; `OnDestroy` remove do set e do registro.
  5. Nenhum responder de rede no Component; transmissão só para `NetService.Audience`.
  6. `DevService` (Priority 990, arch §4.6): com `RunService:IsStudio()` cria `ServerStorage.Dev` (`BindableFunction`) no `OnInit`; `Register(name, handler)`; `OnInvoke(name, ...)` chama o handler em `pcall` (erro → `false, mensagem`). Fora do Studio não cria nada e `Register` é no-op (provado forçando `IsStudio` falso numa cópia local ou por leitura do código no relatório).
  7. `EnemyDevService` (Priority 100, `Require` `DevService` + `EnemyService`, `Register` só no `OnInit`): `Enemies()`, `Damage(uid, amount, playerName)`, `Kill(uid, playerName)`, `Ledger(uid)` → `{ Name, Damage, Present }` + `Total`; jogador por nome via `Players:FindFirstChild`; retorno só com tabelas simples. `game.ServerStorage.Dev:Invoke("Damage", 1, 600, "Player1")` funciona no Command Bar.
  8. `EnemyService` não requer `DevService`; nenhum responder Lync nem packet novo.
  9. **DoD-C**.

### TASK-007 — Assets placeholder e mapa de dev

- Dono: frontend-coder. Onda 0. Depende de: —. Spec: arch §8, PT-11, FEAT-023, DEC-019, DEC-014.
- Status: **Em QA** (commit 9563359 em branch de worktree, aguardando merge na main).
- Toca: `assets/roblox/Characters/*.rbxm` (`DummyR6Red`, `DummyR6Blue`, `DummyR6Green`, `DummyR6Grey`), `assets/roblox/Effects/*.rbxm` (`BlinkOut`, `BlinkIn`, `SkillBurst`, `SkillCharge` + variantes `Lite` se aplicável), `assets/roblox/DevMap.rbxm` (baseplate + `Workspace.Map.EnemySpawns` com 1–3 Parts), `.rogen.json`.
- Critérios de aceite:
  1. Cada personagem: R6, **sem Humanoid**, `AnimationController` + `Animator`, `PrimaryPart = HumanoidRootPart`, `WorldPivot` no pé, frente `-Z`, todas as partes `CanCollide/CanTouch/CanQuery = false`, `Massless = true`, raiz `Anchored`.
  2. Efeitos: emissores desligados com atributo `EmitCount`, ≤ 100 partículas cada.
  3. Após `rogen build`: modelos em `ReplicatedStorage.Assets.Characters`, efeitos em `ReplicatedStorage.Assets.Effects`, mapa de dev em `Workspace.Map`.
  4. Parts de spawn seguem a convenção de arch §4.2 (tag, atributo `EnemyId`, invisível, sem colisão, `CanQuery = false`). O mapa de dev é substituível pelo mapa do usuário sem mudar código.
  5. Nenhum asset de terceiros sem licença; nada de IP de anime.
  6. Sem código Luau novo (se houver script de build, **DoD-C**).

### TASK-008 — `RigAnimator` + IDs placeholder

- Dono: frontend-coder. Onda 1. Depende de: TASK-003, TASK-007. Spec: arch §5.6, PT-15, `content-data.md` AnimationDef/AnimationSet.
- Toca: `src/Rig/RigAnimator/init.luau`, `src/Shared/Content/AnimationSets.luau`.
- Critérios de aceite:
  1. `RigAnimator.new(rig, animationSet)` carrega trilhas sob demanda no `Animator`, cache por rig; `Play(key, { Seek, Fade })`, `Stop(key)`, `StopGroup(group)` com grupos `Locomotion`, `Support`, `Combat`, `Reaction`.
  2. Código não referencia nome de membro do rig (só raiz, pivot, `Animator`, `Attachment` declarado).
  3. `AnimationSets.luau` com IDs reais tocáveis para todas as chaves (pet: Idle, Run, Assist, Enter, Combat1, Combat2, Skill, BackOff; inimigo: Idle, Defend, Hit, HitHeavy, Death, Spawn), usando animações R6 de propriedade da Roblox quando não houver placeholder publicado pelo dono; `Placeholder = true`; `Duration` = comprimento real ÷ `Speed` (± 0,05 s).
  4. Story ou script de dev no Studio toca cada chave num dummy e confirma `Seek` (`TimePosition` inicial).
  5. Mapeamento do rogen conferido (`shared.Rig.RigAnimator`); se diferente, mover para `src/Shared/Rig` e registrar em `architecture.md` §2.1.
  6. **DoD-C**.

### TASK-009 — UI base

- Dono: frontend-coder. Onda 1. Depende de: TASK-003. Spec: FEAT-015, DEC-017, arch §7.4.
- Toca: `src/Interface/client/Components/` (ex.: `ImageButton/`, `Panel/`, `Modal/`, cada um com `init.luau` + `.story.luau`), `src/Shared/Content/Interface.luau`.
- Não depende dos assets do usuário: componentes genéricos parametrizados por chave de imagem.
- Critérios de aceite:
  1. Componentes recebem chave de `Content.Interface.Images` (nunca ID literal) e caem num visual neutro se a chave não existe ainda.
  2. Botão responde a toque e clique, com área mínima de toque mobile (≥ 44 px lógicos) e feedback de pressionado.
  3. `Modal`/`Panel` com abrir/fechar por source, sem lógica de sistema.
  4. Stories no UI Labs (`Interface.storybook.luau`) renderizam sem erro.
  5. Convenção `<Tela><Elemento>` documentada no próprio `Interface.luau` só por chaves de exemplo (sem comentário).
  6. **DoD-C**.

### TASK-010 — `PetService`

- Dono: backend-coder. Onda 2. Depende de: TASK-005. Spec: arch §4.3, `data.md` "Pets iniciais", PT-20.
- Toca: `src/Pet/server/PetService.luau`.
- Critérios de aceite:
  1. `ProfileService.Loaded` com `Pets` vazio → concede `Tuning.StarterPets` via `NewOwnedPet` (Level 1, Stars 1, Xp 0, Gear {}) e preenche `Equipped` num único `Update`.
  2. Uma `PetUnit` por entrada de `Equipped`; `Net.Pets:add` com `Owner` (UserId, aceita negativo), `Slot`, `Pet`, `Ring = 0`, `SkillReadyAt = 0`; `Damage` calculado uma vez (multiplicadores = 1).
  3. API `Units(player)`, `Unit(id)`, `SetTarget(unit, uid?, ring)` (limpa com `Lync.none`), `SetSkillReady(unit, at)`; signals `UnitAdded`/`UnitRemoved`.
  4. `PlayerRemoving` remove as unidades do set e do registro. Id de unidade crescente, nunca o UserId.
  5. Dois jogadores no Studio: set `Pets` com 6 unidades visível nos dois clients.
  6. **DoD-C**.

### TASK-011 — `EnemyController` + `HealthBar`

- Dono: frontend-coder. Onda 2. Depende de: TASK-006, TASK-007, TASK-008. Spec: arch §3, §7.1, FEAT-002.
- Toca: `src/Enemy/client/EnemyController.luau`, `src/Enemy/client/HealthBar/init.luau` (+ `.story.luau`).
- Critérios de aceite:
  1. `onAdded` do set → modelo local clonado de `ReplicatedStorage.Assets.Characters` em `Workspace.Visuals.Enemies`, posicionado por `Position` + `Yaw` pelo pivô no pé; `Idle` em loop. (A1)
  2. `PickBox` invisível (`CharacterDef.PickSize`) com `CanQuery = true`; `Pick(model) → uid`, `Rig(uid)`, `Health(uid)` source.
  3. `HealthBar` Vide em `BillboardGui` acima do modelo (`CharacterDef.Height`) cai a cada `update` de `Health`. (A2)
  4. `Alive = false` → `Death` e o modelo some; `Alive = true` com `Life` novo → `Spawn` no mesmo lugar, barra cheia. (A3)
  5. `PreloadAsync` dos modelos e animações no `OnStart`.
  6. **DoD-C**.

### TASK-012 — `EffectController`

- Dono: frontend-coder. Onda 2. Depende de: TASK-003, TASK-007. Spec: arch §7.1, §10, `content-data.md` EffectDef.
- Toca: `src/Effect/client/EffectController.luau`; se a pendência P3 ainda estiver aberta, também `src/Shared/Content/Effects.luau` (só os campos `Lite` dos 4 efeitos, apontando para as variantes da TASK-007).
- Critérios de aceite:
  1. `Play(effectKey, rig | cframe)` resolve por `Content.Effect`, usa pool por chave, prende em `Root`/`Overhead`/`Ground`, devolve ao pool após `Lifetime`.
  2. Usa a variante `Lite` com qualidade gráfica baixa.
  3. Recusa acima de `Tuning.MaxSkillEffects` sem erro.
  4. Nenhum nome de asset literal no código.
  5. **DoD-C**.

### TASK-013 — Tela `Hud` (story)

- Dono: frontend-coder. Onda 2. Depende de: TASK-009 + **assets do usuário: PNGs, JSON e foto de referência da HUD** (e IDs de upload, Q-036). Spec: FEAT-015, FEAT-025, DEC-017, DEC-018, DEC-021, DEC-022, arch §5.4 (estados do slot).
- Toca: `src/Interface/client/Screens/Hud/` (`init.luau` + `Hud.story.luau`), `src/Interface/client/Components/PetSlot/` (`init.luau` + story), `src/Shared/Content/Interface.luau`; apaga `Components/Counter`.
- Status: **Aguardando assets do usuário**.
- Critérios de aceite:
  1. Story com dados falsos mostra: contador de Coins + popup "+N", botão Parar, toggle Auto-skill, 3 `PetSlot`, atalhos para Inventário/Loja/Battle Pass.
  2. `PetSlot` mostra os 5 estados da tabela de arch §5.4 (Auto com anel verde girando e toque desabilitado; Recarga com preenchimento radial; Pronta; Indisponível; Pedido enviado), cada um selecionável na story.
  3. Peça que não existe no Figma (Parar, toggle, slots, Coins) entra no estilo das outras e fica listada como **Provisório** no relatório da task.
  4. Comparação lado a lado com a foto de referência anexada ao relatório; usuário revisa (A10, visual).
  5. Layout legível em 1280×720 e em perfil de celular do emulador.
  6. **DoD-C**.

### TASK-014 — `EconomyService`

- Dono: backend-coder. Onda 2. Depende de: TASK-005, TASK-006. Spec: arch §4.5 (PT-21), §4.6 (PT-25), FEAT-004, DEC-011, DEC-021.
- Toca: `src/Economy/server/EconomyService.luau`, `src/Economy/server/EconomyDevService.luau` (novo).
- Critérios de aceite:
  1. Em `Died(uid, ledger, def)`: `parte = floor(Rewards.Coins × dano ÷ soma)`, mínimo 1 se dano > 0 (só presentes).
  2. **Denominador = todo o ledger**, inclusive entradas de jogadores que saíram (PT-21). **Pagamento só a jogadores presentes** (`player.Parent == Players`); a parte de quem saiu não é redistribuída. Caso D7 do plano: P1 600, P2 400, P2 sai → P1 recebe 60.
  3. Credita em `profile.Coins` e envia `Reward { Enemy, Coins }` só para cada jogador presente com dano > 0.
  4. `LastPayout(uid)` em memória: `{ Player, Damage, Present, Share }`.
  5. `EconomyDevService` (Priority 100, `Require` `DevService`, `EconomyService`, `ProfileService`; `Register` só no `OnInit`): `Coins(playerName)`, `SetCoins(playerName, n)`, `LastPayout(uid)` → `{ Name, Damage, Present, Share }`. `EconomyService` não requer `DevService`.
  6. Teste pelo Command Bar com 2 jogadores (`Dev:Invoke("Damage", ...)` 700/300 sobre 1000): +70 e +30. (A17, lado servidor)
  7. Nenhuma dependência do `CombatService`.
  8. **DoD-C**.

### TASK-015 — `CombatService` parte 1

- Dono: backend-coder. Onda 3. Depende de: TASK-006, TASK-010. Spec: arch §4.4, §4.6, §5.2, §5.3 passos 1, 2 e 7, PT-14, PT-17, PT-22, PT-25, FEAT-006, FEAT-007, FEAT-021, DEC-024.
- Toca: `src/Combat/server/CombatService/init.luau`, `Engagement.luau`, `src/Combat/server/CombatDevService.luau` (novo).
- Critérios de aceite:
  1. Responders `Attack { Enemy }` e `Recall` no `OnInit`, **finos**: o callback do Lync só chama os métodos públicos `HandleAttack(player, data)` e `HandleRecall(player)`, que fazem validação e rate limit (arch §4.6). Validação: inimigo existe e vivo, personagem vivo, distância ≤ `CommandRange`, rate limit `CommandMinInterval`; inválido ignorado em silêncio.
  2. `Engagements[player]` (um por jogador); `Attack` no alvo atual = `Recall` (Q-030 Provisório); outro alvo troca o alvo de todas as unidades.
  3. `Rings[enemyUid]` aloca slots sem sobreposição entre unidades de jogadores diferentes; `PetService:SetTarget` atualiza `Target`/`Ring`.
  4. Tick a `Tuning.CombatTickRate` com `GetServerTimeNow()`: nada de dano antes de `ArriveAt`; depois, cada unidade causa `Damage` a cada `AttackInterval` (com fase aleatória inicial). Com 3 pets: ~30 de dano/s. (A6, A15 parte de dano)
  5. Hits do tick agrupados **por jogador** e enviados **só ao dono** das unidades (`fireClient`, PT-22, `network.md`), um envio por jogador por tick, só se houver hit, com `Kind = "Basic"`. Nenhum broadcast de `Hits`.
  6. Leash a 2 Hz (`LeashRange`) → recall automático. Morte do alvo → todos os Engagements do inimigo fechados, `Target = nil` (DEC-024). Saída do jogador limpa o Engagement.
  7. Dois jogadores no mesmo inimigo: vida cai pela soma dos dois, sem erro; cada client recebe só os próprios `Hits`. (A11, lado servidor)
  8. `CombatDevService` (Priority 100, `Require` `DevService`, `CombatService`, `PetService`; `Register` só no `OnInit`): `Units(playerName)` → `{ Id, Slot, PetId, Target, Ring, ArriveAt, NextHitAt, SkillReadyAt }`; `Engagement(playerName)` → `{ EnemyUid, Phase, Featured }`; `FireAs(playerName, packet, payload)` para `Attack` e `Recall`, chamando os mesmos `Handle*` (mesma validação e rate limit). `CombatService` não requer `DevService`.
  9. **DoD-C**.

### TASK-016 — `PetController` + `Formation`

- Dono: frontend-coder. Onda 3. Depende de: TASK-010, TASK-011, TASK-012. Spec: arch §6, PT-05, PT-06, PT-19.
- Toca: `src/Pet/client/PetController/init.luau`, `Formation.luau`.
- Critérios de aceite:
  1. Modelos locais em `Workspace.Visuals.Pets` para todas as unidades de todos os jogadores.
  2. Sem alvo: formação atrás do dono com lerp; `Run` > 1 stud, senão `Idle`. Dono sem `HumanoidRootPart` → pets congelam.
  3. Com alvo: slot do anel (`ring × 2π / max(N, 6)`, raio `Radius + AssistDistance`), olhando o inimigo, `Assist` em loop — para pets do jogador local e dos outros (PT-19). (A4, A18 lado posição)
  4. Distância > `TeleportThreshold` → teleporte com `TeleportOut/In` (efeito do personagem ou padrão de `Tuning`), senão corre.
  5. Um `OnTick` a 60 Hz com um único `workspace:BulkMoveTo`; raycast de chão a 10 Hz por pet com cache.
  6. API `Rig(unitId)`, `MyUnits` source; cede a posição via `Stage:Owns(unitId)` (contrato com TASK-020; até lá, sempre falso).
  7. Alvo morre → volta à formação (DEC-024, A5 lado visual).
  8. **DoD-C**.

### TASK-017 — `OnWorldTap` + `CommandController` (Attack/Recall)

- Dono: frontend-coder. Onda 3. Depende de: TASK-011. Spec: arch §7.2, PT-12, FEAT-007, FEAT-017, FEAT-021.
- Toca: `src/Input/client/InputController.luau`, `src/Combat/client/CommandController.luau`.
- Critérios de aceite:
  1. `InputController.OnWorldTap(callback(screenPos))`: mobile via `TouchTapInWorld` (ignora `processedByUI`); PC via `MouseButton1` sem `gameProcessed`, confirmado no `InputEnded` com movimento < 6 px.
  2. `CommandController`: raycast `Include = { Workspace.Visuals.Enemies }` → `EnemyController:Pick` → `Attack { Enemy }`; mesmo alvo → `Recall`; método `Recall()` público para o botão Parar.
  3. Funciona com clique (PC) e toque (emulador mobile). (A4, A5)
  4. Arrastar a câmera não dispara comando.
  5. **DoD-C**.

### TASK-018 — `DamageNumberController`

- Dono: frontend-coder. Onda 4. Depende de: TASK-011, TASK-015, TASK-016. Spec: arch §7.3, PT-22, FEAT-020.
- Toca: `src/Combat/client/DamageNumberController.luau`.
- Critérios de aceite:
  1. Cada entrada de `Hits` mostra o `Amount` num `BillboardGui` acima do inimigo (`CharacterDef.Height`), subindo ~2 studs em 0,8 s com fade e offset horizontal aleatório. (A7)
  2. `Kind = "Skill"` maior e de outra cor. **Sem cor neutra** e sem resolução de dono: o packet `Hits` já chega só com os hits dos próprios pets (PT-22); o client não filtra. Dois clients no mesmo inimigo: cada um vê só os próprios números.
  3. Pool; limite `Tuning.DamageNumbers.PerEnemy` (10) e `Total` (40), reciclando o mais antigo.
  4. Instâncias + `TweenService`, sem árvore Vide por número.
  5. **DoD-C**.

### TASK-019 — `CombatService` parte 2

- Dono: backend-coder. Onda 4. Depende de: TASK-005, TASK-015. Spec: arch §4.6, §5.2–5.5, PT-16, PT-18, PT-23, PT-24, PT-25, FEAT-022, FEAT-024, FEAT-025, DEC-020, DEC-022, DEC-023. FEAT-022/FEAT-024 já alinhados com PT-23/PT-24 (DEC-036).
- Toca: `src/Combat/server/CombatService/init.luau`, `Engagement.luau`, `Choreography.luau` (novo), `SkillQueue.luau` (novo), `src/Combat/server/CombatDevService.luau` (estende o da TASK-015).
- Critérios de aceite:
  1. `Phase` via `Libs.FSM` com as transições de arch §5.2.
  2. Coreografia por jogador: round-robin a partir de `Cursor`, `Turn` do AnimationSet (padrão `Tuning.DefaultTurn`), duração de cada movimento = `Duration` da trilha; um `Featured` por jogador. (A15)
  3. `Beat { Unit, Move }` `:timestamped()` (ou `At`, conforme TASK-002) enviado só ao dono. (A19 lado servidor)
  4. Auto-skill: com `AutoSkill == true`, unidades chegadas com cooldown pronto entram na fila em ordem de slot; casts espaçados por `SkillGap`. (A9)
  5. Responder `UseSkill { Unit }` com todas as validações de arch §5.4 (dono, existe, `AutoSkill == false`, cooldown, alvo vivo e chegada, não enfileirada, rate limit); inválido ignorado. (A14 lado servidor)
  6. Responder `SetAutoSkill { Enabled }` grava `AutoSkill` via `ProfileService` e o `Profile` replica.
  7. Responders finos: callbacks chamam `HandleUseSkill(player, data)` e `HandleSetAutoSkill(player, data)` (arch §4.6).
  8. Cooldown (PT-23): unidade nasce com `SkillReadyAt = 0`; cooldown conta **a partir do cast** (`SkillReadyAt = castAt + Cooldown` no set); chegada, `Recall`, troca de alvo e morte do alvo **não** reiniciam nem pausam o cooldown; skill pronta só entra na fila com a unidade chegada (`now ≥ ArriveAt`).
  9. Cast (PT-24): beat `Skill`; dano `Power × Damage` (`Kind = "Skill"`) sai **0,4 s (`HitDelay`) após o próprio cast**; casts do mesmo jogador espaçados por `SkillGap` **0,3 s** (3 prontas → danos em +0,4, +0,7, +1,0 s, ±1 tick); interrompe o turno em curso sem beat extra, depois `BackOff`. Jogadores diferentes não esperam um ao outro. (A16, A9)
  10. `Recall`, troca de alvo e morte limpam a fila e descartam `PendingHits`.
  11. `CombatDevService` estendido: `FireAs` aceita também `UseSkill` e `SetAutoSkill` (via `Handle*`); `Engagement` ganha `Queue`, `LastCastAt`, `PendingHits`; novo `SetSkillReady(playerName, unitId, at)`.
  12. **DoD-C**.

### TASK-020 — `CombatController` + `Stage`

- Dono: frontend-coder. Onda 5. Depende de: TASK-012, TASK-016, TASK-019. Spec: arch §5.5, PT-04, PT-18, PT-19, FEAT-024.
- Toca: `src/Combat/client/CombatController/init.luau`, `Stage.luau`.
- Critérios de aceite:
  1. Beat com `late ≥ Duration` ignorado; senão toca com `Seek = late`.
  2. `Enter`: pet teleporta do anel para a posição de golpe (`Radius + Reach`) com `TeleportOut/In`; `Combat1/2`: inimigo local gira para o pet e toca `Reactions[move]`; `BackOff`: volta ao anel, inimigo `Idle`. (A8, A15)
  3. `Skill`: corta o pet em cena anterior (volta ao anel), pet da skill entra, toca `Skill` + `CastEffect` e `Effect` em `HitDelay`; inimigo `HitHeavy` (cai para `Hit`). (A16)
  4. Pets fora de cena do jogador local em `Assist`. (A18)
  5. `Stage:Owns(unitId)` integrado ao `PetController`.
  6. Dois clients no mesmo inimigo: cada um vê só a própria sequência; pets do outro só em `Assist`; sem VFX de skill alheio. (A19)
  7. **DoD-C**.

### TASK-021 — `CommandController`: skills

- Dono: frontend-coder. Onda 5. Depende de: TASK-017, TASK-019. Spec: arch §5.4, PT-16, FEAT-025, DEC-022.
- Toca: `src/Combat/client/CommandController.luau`.
- Critérios de aceite:
  1. `UseSkill(unitId)` recusa localmente se auto ligado, em recarga, sem alvo ou pet chegando; senão envia `UseSkill { Unit }`.
  2. `SetAutoSkill(bool)` escreve otimista em `ProfileController.AutoSkill` e envia `SetAutoSkill { Enabled }`; o `Profile` seguinte corrige.
  3. `SlotState(unitId)` source com os 5 estados de arch §5.4, derivados só de dados replicados; "Pedido enviado" dura até `SkillReadyAt` mudar ou `SkillRequestTimeout`.
  4. Testável sem HUD por script de dev/Command Bar do client.
  5. **DoD-C**.

### TASK-022 — `InterfaceController` + HUD real

- Dono: frontend-coder. Onda 6. Depende de: TASK-013, TASK-014, TASK-021. Spec: arch §7.4, FEAT-015, FEAT-004, FEAT-021, FEAT-025.
- Toca: `src/Interface/client/InterfaceController.luau` (novo), `src/Interface/client/Screens/Hud/`.
- Status: **Aguardando assets do usuário** (herdado de TASK-013).
- Critérios de aceite:
  1. `Vide.mount` do ScreenGui no `OnStart`; source `Screen`; contexto do Input vai para `Menu` quando uma tela cobre o jogo (usa API existente do `InputController`).
  2. Contador de Coins lê `ProfileController.Coins`; popup "+N" por `LastReward`. (A17)
  3. Botão Parar → `CommandController:Recall()`. (A5)
  4. Toggle → `CommandController:SetAutoSkill`; anel verde nos slots quando ligado e toque desabilitado. (A9)
  5. Um `PetSlot` por pet equipado, estado por `SlotState`; toque com auto desligado e skill pronta usa a skill daquele pet; slot em recarga não responde. (A14)
  6. Funciona por toque no emulador mobile. (A10 parte HUD)
  7. **DoD-C**.

### TASK-023 / TASK-024 / TASK-025 — Telas só visuais

- Dono: frontend-coder. Onda 2 (quando os assets chegarem). Depende de: TASK-009 + **assets do usuário: PNGs, JSON e foto de referência** da tela (e IDs de upload). Spec: FEAT-012 (Inventory), FEAT-026 (Shop), FEAT-027 (BattlePass), DEC-017, DEC-018.
- Toca: `src/Interface/client/Screens/<Tela>/` (`init.luau` + `<Tela>.story.luau`) e `src/Shared/Content/Interface.luau`. **Uma de cada vez** (conflito em `Interface.luau`, também com TASK-013).
- Status: **Aguardando assets do usuário**.
- Critérios de aceite (cada):
  1. Story renderiza a tela fiel à foto de referência; comparação anexada ao relatório; usuário revisa. (A10, visual)
  2. Abre e fecha por source (prop `Open`), botão de fechar responde a toque e clique.
  3. Nenhuma lógica de sistema (sem equipar, comprar, resgatar); dados de exemplo só na story.
  4. IDs de imagem só em `Interface.luau`.
  5. **DoD-C**.

### TASK-026 — Ligar telas visuais à HUD

- Dono: frontend-coder. Onda 7. Depende de: TASK-022, TASK-023, TASK-024, TASK-025. Spec: FEAT-015, DEC-018.
- Toca: `src/Interface/client/InterfaceController.luau`, `src/Interface/client/Screens/Hud/`.
- Status: **Aguardando assets do usuário** (herdado).
- Critérios de aceite:
  1. Atalhos da HUD abrem Inventário, Loja e Battle Pass; fechar volta à HUD; só uma tela aberta por vez.
  2. Com tela aberta, toque no mundo não comanda pets (contexto `Menu`).
  3. As 4 telas por toque no emulador mobile. (A10 completo)
  4. **DoD-C**.

### TASK-027 — Plano de teste do v0

- Dono: qa-tester. Onda 0. Depende de: —. Spec: DEC-013, DEC-016, DEC-018, DEC-020, DEC-021, DEC-022, DEC-023, `architecture.md`.
- Toca: `docs/tests/v0-plan.md`.
- Status: **Feito** (`docs/tests/v0-plan.md`).
- Critérios de aceite:
  1. Um caso por critério A1–A19 com passos, dados, resultado esperado e a task que o entrega (mapa critério → TASK).
  2. Casos de borda Provisórios: overkill, mínimo 1 moeda, jogador sai antes da morte, toggle com skills prontas (0,3 s entre casts), `UseSkill` forjado (unidade de outro jogador, auto ligado, em recarga).
  3. Casos de migração de perfil (versão ausente, versão maior que a atual).
  4. Checklist estática por task: grep de `--` e `--!strict` em `.luau`, `tools/analyze.ps1` = 0, `modux check`.
  5. Roteiro de 2 clients no Studio (A11, A19), emulador mobile (A12) e troca de asset por dados (A13).

### TASK-028 — QA do núcleo servidor

- Dono: qa-tester. Onda 4. Depende de: TASK-004, TASK-006, TASK-014, TASK-015, TASK-027. Spec: plano TASK-027.
- Toca: `docs/tests/` (relatório).
- Critérios de aceite:
  1. Executa os casos de servidor de A1, A3, A6, A11, A17 (via Command Bar e 2 clients, sem depender de UI).
  2. Análise estática das tasks 001–006, 010, 014, 015 (DoD-C).
  3. Resultado no board: tasks aprovadas → `Feito`; falha → `Falhou` + task de correção nova pedida ao `task-planner`.

### TASK-029 — QA completo do v0

- Dono: qa-tester. Onda 8. Depende de: TASK-001 a TASK-028. Spec: plano TASK-027.
- Toca: `docs/tests/` (relatório); para A13, troca temporária de 1 modelo e 1 animação em `Characters.luau`/`AnimationSets.luau`/`assets/roblox` (revertida ao fim).
- Critérios de aceite:
  1. A1–A19 executados e marcados passou/falhou com evidência (print/vídeo/log).
  2. A12 medido: FPS no emulador mobile com 1 inimigo + pets de 2 jogadores; números entregues à TASK-030.
  3. A13: troca de 1 modelo e 1 animação só por dados/arquivo, sem mudar Service/Controller.
  4. Cada falha vira task de correção nova (TASK-031+) com dono e critério reproduzível.

### TASK-030 — Ajustes de orçamento

- Dono: frontend-coder. Onda 9. Depende de: TASK-029. Spec: arch §10, A12.
- Toca: `src/Pet/client/`, `src/Enemy/client/`, `src/Effect/client/`, `src/Combat/client/DamageNumberController.luau`, `src/Shared/Content/Tuning.luau` (só `Lod`/limites, com aval do `architect`).
- Critérios de aceite:
  1. LOD de arch §10 ativo (pets de outros ocultos > 150 studs; inimigo sem animação > 200, sem modelo > 300).
  2. A12 refeito e aprovado pelo `qa-tester` com os números da TASK-029 como base.
  3. **DoD-C**.

---

## Retorno do QA

Ao receber retorno do `qa-tester`: task aprovada → `Feito`; reprovada → `Falhou` e o `task-planner` cria
`TASK-031+` de correção (dono, dependência na task original, critério que falhou como critério de aceite).
