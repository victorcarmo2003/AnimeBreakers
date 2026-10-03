# Arquitetura técnica — Protótipo de apresentação (v0)

Status: Rascunho

Autor: `architect`. Base: `CLAUDE.md`, `README.md` (raiz), `src/Modux/README.md`, módulos atuais de `src/`,
DEC-001 a DEC-028, `design/features.md`, `vision.md` e o escopo v0 repassado em 2026-10-03.

Revisão 2 (2026-10-03): incorpora as respostas a T-01..T-06 (DEC-021 a DEC-024, DEC-028). Mudanças
principais: dinheiro no v0; botão "Forçar" substituído por toggle de auto-skill + skill manual por slot;
coreografia **por jogador** com categoria de animação **Assist**; alvo morto devolve os pets ao dono;
placeholder R6.

Revisão 3 (2026-10-03): resolve as divergências levantadas pelo `qa-tester` em `tests/v0-plan.md`
(PT-21 a PT-25): ledger mantém quem saiu (4.5), números de dano só do próprio jogador (7.3, `Hits`
privado), cooldown conta do cast com unidade nascendo pronta (5.4), dano da skill `HitDelay` após o
próprio cast, casts espaçados por `SkillGap` (5.4), mecanismo de dev só no Studio (4.6).

Documentos irmãos:

| Documento | Conteúdo |
|---|---|
| `tech/network.md` | cada entrada Lync do v0 (set/packet, schema, `keyBy`, quem escreve/lê, frequência) |
| `tech/data.md` | Template do perfil v0, o que é provisório, migração de versão, extensões futuras |
| `tech/content-data.md` | tabelas data-driven em `src/Shared/Content` (Character, Pet, Enemy, Ability, AnimationSet, Effect, Egg, Rarity) |

Código do v0 liberado por DEC-015 (bandeira verde parcial).

---

## 0. Propostas técnicas

`PT-##` é ID local deste documento. PT-01 a PT-15 foram aceitas por DEC-028, com as exceções abaixo.
PT-16 em diante são novas desta revisão: a secretária converte em `DEC-###` (marcado "técnica") se o
usuário não vetar. ID de PT nunca é reaproveitado.

| ID | Proposta | Situação | Seção |
|---|---|---|---|
| PT-01 | Servidor "headless" para atores de combate: não existe modelo de inimigo nem de pet no servidor. Servidor guarda estado lógico; cada client cria e anima os modelos localmente. | aceita (DEC-028) | 3 |
| PT-02 | Spawn point = Part com tag `EnemySpawn` + atributo `EnemyId`. Cada Part vira um Component `EnemySpawn`, dono da vida, morte, respawn e ledger de dano. | aceita | 4.2 |
| PT-03 | State manager de combate separa **dano** (contínuo, por unidade) de **coreografia** (sequenciador). | aceita; **alterada por PT-17** (coreografia por jogador) | 5 |
| PT-04 | Sincronização de animação por beats `:timestamped()` com *seek* local. | aceita; **alterada por PT-18** (beat privado do dono) | 5.5 |
| PT-05 | Pets se movem só no client, posição derivada (formação do dono ou slot do anel do alvo). | aceita; anel agora tem posição de Assist (PT-17) | 6 |
| PT-06 | Chegada do pet ao alvo assumida após `ArriveSeconds` fixo, sem pathfinding. | aceita | 6.3 |
| PT-07 | Remover `Vital` e `Round` do template; `Counter` sai quando a primeira tela real tiver story. | aceita | 9 |
| PT-08 | Dinheiro reaproveita o campo `Coins` do perfil; `Level` e `Playtime` saem. | aceita | `data.md` |
| PT-09 | v0 usa ProfileStore em modo Mock, ligado por flag. | aceita | `data.md` |
| PT-10 | Tabela `Characters` (modelo + rig + AnimationSet) referenciada por `Pets` e `Enemies`. | aceita | `content-data.md` |
| PT-11 | Assets em `ReplicatedStorage.Assets`, `.rbxm` em `assets/roblox/` mapeados no `.rogen.json`. | aceita | 8 |
| PT-12 | Seleção de alvo por `TouchTapInWorld` (mobile) e clique sem arrasto (PC), via `OnWorldTap`. | aceita | 7.2 |
| PT-13 | Botão "Forçar skill" com cooldown global. | **substituída por PT-16** (DEC-022) | — |
| PT-14 | Tick do combate a 20 Hz; relógio único `workspace:GetServerTimeNow()`. | aceita | 5.3 |
| PT-15 | Animações só por chave, resolvidas por `AnimationSet` em dados com `Duration` declarada. | aceita; chaves novas `Assist` e `Defend` | 5.6, `content-data.md` |
| PT-16 | Skill por pet: `AutoSkill` (bool no perfil, padrão `true`). Auto ligado → servidor dispara ao fim do cooldown. Auto desligado → packet `UseSkill { Unit }` por slot, validado no servidor. Casts do mesmo jogador espaçados por `Tuning.SkillGap`. | nova | 5.4 |
| PT-17 | `Engagement` passa a ser **por jogador** (um jogador ↔ um alvo). Dano continua por unidade, agregado no inimigo. Ring de posições continua **por inimigo** (todas as unidades de todos os jogadores), para ninguém ficar em cima de ninguém. | nova | 5.2 |
| PT-18 | `Beat` vira packet **privado** (`fireClient` só para o dono). Cada client anima o inimigo segundo **a sua** sequência; o modelo do inimigo é local, então não há conflito entre clients. | nova | 5.5 |
| PT-19 | Pets de **outros** jogadores: só `Assist` em loop no slot do anel (e `Idle`/`Run` fora de combate), sem coreografia, sem VFX de skill. **Provisório** (Q-037). | nova | 5.5 |
| PT-21 | Ledger de dano **nunca apaga entrada por saída do jogador**. Quem saiu conta no denominador e não recebe (FEAT-004, DEC-021). | nova | 4.5 |
| PT-22 | Cada client mostra **só os números de dano dos próprios pets**. `Hits` vira packet privado (`fireClient` por dono). Alinha com FEAT-024 "No v0". | nova | 7.3, `network.md` |
| PT-23 | Cooldown de skill conta **a partir do cast**; a unidade nasce pronta (`SkillReadyAt = 0`); chegada ao alvo, recall e troca de alvo não reiniciam o cooldown. Skill pronta só sai depois da chegada. | nova | 5.4 |
| PT-24 | "Disparo" de skill = cast (beat `Skill`). Casts do mesmo jogador espaçados por `SkillGap`; o dano de cada skill sai `HitDelay` depois do **próprio** cast. | nova | 5.4 |
| PT-25 | Mecanismo de dev do servidor (`DevService` + `<Feature>DevService`) ativo só com `RunService:IsStudio()`, acessado pelo Command Bar via `BindableFunction`. | nova | 4.6 |
| PT-20 | `OwnedPet` já nasce com `Xp` e `Gear` (sem uso no v0) para XP e equipamentos futuros não exigirem migração de forma aninhada. Recompensa de inimigo vira tabela `Rewards` extensível. | nova | `data.md`, `content-data.md` |

---

## 1. Visão geral

```
              CLIENT (cada jogador)                                   SERVIDOR
 ┌───────────────────────────────────────────┐        ┌──────────────────────────────────────────────┐
 │ InputController ── OnWorldTap ──┐         │        │ EnemySpawn (Component, 1 por Part de spawn)  │
 │ CommandController ◄─────────────┘         │ Attack │   vida, ledger de dano, morte, respawn       │
 │   raycast nos modelos locais ─────────────┼───────►│ EnemyService  registro + Died/Spawned        │
 │   Recall / UseSkill / SetAutoSkill ───────┼───────►│ CombatService                                │
 │                                           │        │   Engagement (1 por JOGADOR engajado)        │
 │ EnemyController  ◄── set Enemies ─────────┼────────┤     dano contínuo por unidade                │
 │   modelos locais, barra de vida           │        │     skills (auto/manual), cooldowns          │
 │ PetController    ◄── set Pets ────────────┼────────┤     sequenciador → Beat (só p/ o dono)       │
 │   modelos locais, seguir / anel / Assist  │        │ PetService  unidades equipadas → set Pets    │
 │ CombatController ◄── Beat (privado) ──────┼────────┤ EconomyService  Died → divide Coins          │
 │   coreografia local, reação do inimigo    │        │ ProfileService  Coins, AutoSkill, Pets       │
 │ DamageNumberController ◄── Hits (privado) ┼────────┤                                              │
 │ ProfileController ◄── Profile/Inventory ──┼────────┤                                              │
 │ InterfaceController (Vide) HUD + telas    │        │                                              │
 └───────────────────────────────────────────┘        └──────────────────────────────────────────────┘
```

Regra de ouro: **o servidor decide números e ordem; o client decide pixels.** Dano, hit, cooldown,
skill, morte, respawn, divisão de dinheiro e a ordem da coreografia do jogador são do servidor. Posição
de pet, modelo, animação, teleporte visual, reação do inimigo, VFX e números flutuantes são do client.

---

## 2. Mapa de features

Uma feature = uma pasta. Caminho → DataModel segue o `.rogen.json`
(`src/<Feature>/server` → `ServerScriptService.server.<Feature>`, `src/<Feature>/client` →
`StarterPlayerScripts.client.<Feature>`, `src/Shared/<X>` → `ReplicatedStorage.shared.<X>`).

| Feature | server | client | Situação |
|---|---|---|---|
| `src/Net` | `NetService` | `NetController` | existente, sem mudança |
| `src/Player` | `PlayerService` | — | existente, sem mudança |
| `src/Profile` | `ProfileService` (Template v0, Mock, replicação dividida) | `ProfileController` (Coins, AutoSkill, Pets, Equipped) | **estender** |
| `src/Input` | — | `InputController` (+ `OnWorldTap`) | **estender** |
| `src/Content` | `ContentService` (valida tabelas no boot) | — | nova |
| `src/Shared/Content` | tabelas de dados (os dois lados) | | nova (`content-data.md`) |
| `src/Enemy` | `EnemyService`, `EnemySpawn` (Component) | `EnemyController`, `HealthBar` (Vide) | nova |
| `src/Pet` | `PetService` | `PetController` | nova |
| `src/Combat` | `CombatService` (+ `Engagement`, `Choreography`, `SkillQueue`) | `CommandController`, `CombatController`, `DamageNumberController` | nova |
| `src/Economy` | `EconomyService` | — | nova (DEC-021) |
| `src/Dev` | `DevService` (só Studio, 4.6) | — | nova (PT-25); `EnemyDevService`, `EconomyDevService`, `CombatDevService` ficam na pasta `server` da própria feature |
| `src/Rig` | — | `RigAnimator` (módulo puro, não é Controller) | nova |
| `src/Effect` | — | `EffectController` | nova |
| `src/Interface` | — | `InterfaceController`, `Screens/*`, `Components/*` (inclui `PetSlot`) | **estender** |
| `src/Vital` | | | **remover** (PT-07) |
| `src/Round` | | | **remover** (PT-07) |

Módulo com mais de um arquivo vira pasta com `init.luau` (`CombatService/init.luau`,
`CombatService/Engagement.luau`, `CombatService/Choreography.luau`, `CombatService/SkillQueue.luau`).

### 2.1 Árvore proposta

```
src/
  Content/server/ContentService.luau
  Shared/Content/
    init.luau            índice tipado + lookups (Content.Pet("PET-001"))
    Types.luau           PetDef, EnemyDef, CharacterDef, AbilityDef, AnimationSet, ...
    Characters.luau  Pets.luau  Enemies.luau  Abilities.luau
    AnimationSets.luau  Effects.luau  Eggs.luau  Rarities.luau  Tuning.luau
    Interface.luau       IDs de imagens da UI importada do Figma
  Enemy/
    server/EnemyService.luau
    server/EnemySpawn.luau            Component, Tag "EnemySpawn"
    client/EnemyController.luau
    client/HealthBar/init.luau        componente Vide (BillboardGui) + story
  Pet/
    server/PetService.luau
    client/PetController/init.luau
    client/PetController/Formation.luau
  Combat/
    server/CombatService/init.luau
    server/CombatService/Engagement.luau
    server/CombatService/Choreography.luau
    server/CombatService/SkillQueue.luau
    client/CommandController.luau
    client/CombatController/init.luau
    client/CombatController/Stage.luau     palco local: pet em cena + reação do inimigo
    client/DamageNumberController.luau
  Economy/server/EconomyService.luau
  Economy/server/EconomyDevService.luau     só Studio (4.6)
  Enemy/server/EnemyDevService.luau         só Studio (4.6)
  Combat/server/CombatDevService.luau       só Studio (4.6)
  Dev/server/DevService.luau                só Studio (4.6)
  Rig/RigAnimator/init.luau           compartilhado (shared.Rig.RigAnimator), usado só no client
  Effect/client/EffectController.luau
  Interface/client/
    InterfaceController.luau
    Screens/Hud/  Screens/Shop/  Screens/BattlePass/  Screens/Inventory/   (init.luau + .story.luau)
    Components/   botões, molduras, contadores, PetSlot (cooldown + anel verde de auto)
```

`src/Rig/RigAnimator` fica na raiz da feature, como `src/Net/Log.luau`: o rogen manda para
`ReplicatedStorage.shared.Rig`. Conferir após o primeiro `rogen build` — se o mapeamento for diferente,
mover para `src/Shared/Rig`.

---

## 3. Atores sem modelo no servidor (PT-01)

O servidor não instancia modelo de inimigo nem de pet.

Por quê:

- **Animação local por natureza.** Animação tocada pelo client num Animator que ele não possui não
  replica — então o client precisa ser dono do rig de qualquer jeito.
- **Cada jogador vê a própria luta** (DEC-023). Com o modelo do inimigo local, cada client anima o mesmo
  inimigo de um jeito diferente (reagindo aos próprios pets) sem conflito. Com modelo no servidor isso
  seria impossível.
- **Teleportes e giros cosméticos** brigariam com a replicação de `CFrame` de um modelo do servidor.
- **Custo de replicação zero para visual.** O set `Pets` muda poucas vezes por minuto.
- **Troca de asset sem tocar no servidor** (A13): o servidor só conhece `EnemyId`/`PetId`.

O que o servidor precisa de espacial é pouco e sai dos dados: posição do spawn (da Part) e posição do
personagem do jogador (já replicada pelo Roblox) para validar alcance.

Custo aceito: um client que ainda não carregou o modelo não vê o ator. Mitigação: `ContentProvider:PreloadAsync`
dos modelos e animações do v0 no `OnStart` do `EnemyController`/`PetController`.

---

## 4. Servidor

### 4.1 Prioridades de boot e dependências

Prioridade maior roda antes (Loader ordena decrescente; todos os `OnInit` antes de todos os `OnStart`).

| Módulo | Espécie | Priority | Require | Responsabilidade |
|---|---|---|---|---|
| `NetService` | Service | 1000 | — | existente: `Lync.start`, flush, `Audience`, `Ready` |
| `ContentService` | Service | 950 | — | valida referências das tabelas de `shared.Content` no `OnInit`; erro alto e claro se faltar ID, animação ou modelo |
| `PlayerService` | Service | 900 | — | existente |
| `ProfileService` | Service | 800 | `PlayerService`, `NetService` | existente, continua genérico; Template v0, Mock, `Mutate`, migração, replicação `Profile` + `Inventory` (`data.md`) |
| `EnemyService` | Service | 700 | `NetService` | registro de inimigos vivos por `Uid`, `ApplyDamage`, signals `Spawned`/`Died` |
| `EnemySpawn` | Component (Tag `EnemySpawn`) | — | `EnemyService` | uma Part de spawn = um inimigo: vida, ledger, morte, timer de respawn, `Enemies:add/update` |
| `PetService` | Service | 650 | `PlayerService`, `ProfileService`, `NetService` | monta as unidades a partir de `Equipped`, concede pets iniciais, publica set `Pets`, signals `UnitAdded`/`UnitRemoved` |
| `CombatService` | Service | 600 | `NetService`, `PlayerService`, `ProfileService`, `EnemyService`, `PetService` | responders `Attack`/`Recall`/`UseSkill`/`SetAutoSkill`, Engagements por jogador, dano, skills, cooldowns, `Hits`, `Beat` |
| `EconomyService` | Service | 550 | `EnemyService`, `ProfileService`, `NetService` | ao `Died`, divide `Rewards.Coins` pelo ledger e credita `Coins`; dispara `Reward` |
| `DevService` | Service | 990 | — | só no Studio: `ServerStorage.Dev` + registro de comandos (4.6) |
| `EnemyDevService`, `EconomyDevService`, `CombatDevService` | Service | 100 | `DevService` + o service da feature | registram comandos de dev da feature (4.6) |

Nenhum Component registra responder (regra do README). `EnemySpawn` só faz `add`/`update`/`remove` no set.

`CombatService` passa a requerer `ProfileService` para ler e gravar `AutoSkill` (o responder
`SetAutoSkill` grava no perfil; o tick lê o atom). A regra "quem sabe o que é auto-skill" fica no
Combat; o Profile só guarda o bool.

### 4.2 Inimigos: `EnemySpawn` + `EnemyService` (PT-02)

**Convenção do mapa** (o usuário coloca no Studio):

| Item | Valor |
|---|---|
| Onde | qualquer lugar sob `Workspace.Map` (sugestão: `Workspace.Map.EnemySpawns`) |
| Instância | `Part` |
| Tag (CollectionService) | `EnemySpawn` |
| Atributo obrigatório | `EnemyId` (string, ex.: `"ENM-001"`) |
| Atributos opcionais | `RespawnSeconds` (number, sobrescreve o da tabela), `Label` (string, só para debug/log) |
| Propriedades | `Anchored = true`, `Transparency = 1`, `CanCollide = false`, `CanTouch = false`, `CanQuery = false` |
| Posição | a Part fica apoiada no chão; o **pé** do inimigo vai no centro da face de baixo da Part |
| Orientação | o inimigo olha para o `LookVector` da Part (só o yaw é usado) |

Por que tag e não só pasta: o Component do Modux já sobe por tag (`CollectionService`), inclusive para
Parts adicionadas depois. Por que atributo e não nome da Part: nome é editado à toa no Studio; atributo é
tipado e aparece no painel de propriedades.

**`EnemySpawn` (Component)**, no padrão do `Vital`:

- `OnInit`: lê `EnemyId`, resolve `EnemyDef` em `shared.Content`; ID inválido → `warn` e não spawna.
  Pede um `Uid` ao `EnemyService` (contador inteiro crescente, nunca reaproveitado na sessão), faz
  `Net.Enemies:add(uid, record)` e se registra no `EnemyService`.
- Estado: `Health`, `MaxHealth`, `Alive`, `Life` (contador de encarnações), `Ledger: { [Player]: number }`.
- `TakeDamage(amount, player) -> applied`: aplica `min(amount, Health)` (overkill não conta, FEAT-004),
  soma no ledger, `Enemies:update`. Chegou a 0 → `Alive = false`, avisa `EnemyService` (`Died` com o ledger
  copiado), agenda respawn.
- O ledger **não** escuta `PlayerRemoving` e nunca apaga entrada antes do respawn (PT-21, ver 4.5).
- Respawn: depois de `RespawnSeconds`, `Health = MaxHealth`, ledger zerado, `Life += 1`, `Alive = true`.
- `OnDestroy`: `Enemies:remove(uid)` e desregistra.

**`EnemyService`**: registro `Uid → EnemySpawn`, `Get(uid)`, `ApplyDamage(uid, amount, player)`,
`Position(uid)`, signals `Spawned(uid)` e `Died(uid, ledger, enemyDef)`. É a fachada que Combat e Economy
usam — ninguém fala com o Component direto.

Inimigo não ataca (Q-018, Provisório do v0). O dano é **agregado no inimigo** independentemente de
quantos jogadores atacam: vários Engagements (um por jogador) chamam o mesmo `ApplyDamage`.

### 4.3 Pets: `PetService`

Unidade (`PetUnit`) = um pet equipado de um jogador presente no servidor. Estado só em memória:

```
PetUnit = {
  Id, Owner: Player, Slot, OwnedUid, PetId, Def,
  Damage, AttackInterval, AbilityId, Cooldown,
  SkillReadyAt, Target: enemyUid?, Ring, ArriveAt, NextHitAt
}
```

- `ProfileService.Loaded` → se `Pets` estiver vazio, concede os `Tuning.StarterPets` (Provisório v0: 3 pets) e
  equipa; depois cria uma unidade por entrada de `Equipped` e faz `Net.Pets:add`.
- `SkillReadyAt` inicial = 0 (skill pronta na primeira luta).
- `PlayerRemoving` → remove as unidades (`UnitRemoved` avisa o Combat).
- `Damage` = `PetDef.Damage × mult. de level × mult. de estrela × mult. de equipamento` (v0: todos = 1).
  Calculado uma vez na criação da unidade, não a cada hit. É o ponto único onde XP/level, estrelas e
  equipamento (PT-20) entram no futuro.
- Sem modelo, sem posição. Expõe `Units(player)`, `Unit(id)`, `SetTarget(unit, uid?, ring)`,
  `SetSkillReady(unit, at)`.

### 4.4 Combate: `CombatService` (PT-03, PT-16, PT-17)

Ver seção 5 inteira. Resumo das responsabilidades:

- Responders (`OnInit`): `Attack { Enemy }`, `Recall`, `UseSkill { Unit }`, `SetAutoSkill { Enabled }`.
- Valida comandos: inimigo existe e vivo; personagem do jogador vivo; distância personagem → spawn
  ≤ `Tuning.CommandRange` (Provisório 80 studs); rate limit por jogador (`Tuning.CommandMinInterval`).
- Mantém `Engagements: { [Player]: Engagement }` e `Rings: { [enemyUid]: { [ring]: unitId } }`.
- `OnTick` a 20 Hz (PT-14): avança cada Engagement (dano, skills, coreografia), junta os hits do tick por jogador
  e manda `Hits` e beats de cada jogador só para ele (PT-18, PT-22).
- Leash a 2 Hz: dono a mais de `Tuning.LeashRange` (Provisório 120 studs) do alvo → `Recall` automático.
- `EnemyService.Died` → fecha todos os Engagements daquele inimigo; unidades voltam ao dono (DEC-024).

### 4.5 Dinheiro: `EconomyService` (DEC-021)

- Escuta `EnemyService.Died(uid, ledger, def)`.
- `parte = floor(def.Rewards.Coins × dano_do_jogador ÷ soma_do_ledger)`, mínimo 1 se dano > 0. Valor do
  v0: 100 (DEC-021, Provisório).
- **Quem saiu antes da morte (PT-21, FEAT-004 Provisório):** a entrada continua no ledger, **conta no
  denominador e não recebe**. Nada é redistribuído.
  - `soma_do_ledger` = soma de **todas** as entradas, presentes ou não.
  - Só recebe (e só ganha `Reward`) quem está presente na hora do `Died`: `player.Parent == Players`.
    O mínimo de 1 vale só para presentes.
  - Chave do ledger é a instância `Player`. Quem sai e volta é outra instância: a entrada antiga fica
    ausente (perdida) e o dano novo abre entrada nova. Sem caso especial.
  - Exemplo (D7 do plano de teste): P1 = 600, P2 = 400, P2 sai → soma 1000 → P1 recebe
    `floor(100 × 600 ÷ 1000) = 60`; os 40 não vão para ninguém.
  - Por que não apagar na saída: apagar faria P1 receber 100 (parte de P2 redistribuída), contra
    FEAT-004/DEC-021. A referência a um `Player` removido vive no máximo até o respawn (ledger zerado).
- Credita com `profile.Coins(profile.Coins() + parte)` e dispara `Reward` (packet privado) para o popup.
  A HUD mostra o saldo vindo do `Profile` (A17).
- Fica fora do Combat porque a feature vai crescer (ovos, venda, ilhas, drops de boss) e nenhuma dessas
  coisas é combate.
- Guarda em memória a última divisão por inimigo (`LastPayout(uid)`: `{ Player, Damage, Present, Share }`),
  usada pelo mecanismo de dev (4.6).
- **Extensão futura** (DEC-026/027, fora do v0): a mesma divisão proporcional serve para `Rewards.PetXp`
  (XP distribuída entre as unidades engajadas do jogador) e para `Rewards.Drops` (rolagem por jogador com
  dano > 0). Ambas entram aqui, sem tocar no Combat. Formato em `content-data.md`.

### 4.6 Mecanismo de dev no Studio (PT-25)

O QA precisa chamar serviços do servidor nos casos **S** (`tests/v0-plan.md`). Os serviços do Modux não
são globais e o Command Bar não enxerga a instância viva. Solução versionada em `src/`, inerte fora do
Studio, sem acoplamento escondido:

| Módulo | Onde | Priority | Require | Responsabilidade |
|---|---|---|---|---|
| `DevService` | `src/Dev/server/DevService.luau` | 990 | — | se `RunService:IsStudio()`, cria `ServerStorage.Dev` (`BindableFunction`) no `OnInit`; `Register(name, handler)`; `OnInvoke(name, ...)` chama o handler em `pcall` e devolve o resultado (erro → `false, mensagem`). Fora do Studio não cria nada e `Register` é no-op |
| `EnemyDevService` | `src/Enemy/server/EnemyDevService.luau` | 100 | `DevService`, `EnemyService` | comandos de inimigo |
| `EconomyDevService` | `src/Economy/server/EconomyDevService.luau` | 100 | `DevService`, `EconomyService`, `ProfileService` | comandos de dinheiro |
| `CombatDevService` | `src/Combat/server/CombatDevService.luau` | 100 | `DevService`, `CombatService`, `PetService` | comandos de combate e skill |

Regras:

- Cada feature registra os próprios comandos no próprio arquivo: nenhuma task edita arquivo de outra, e a
  dependência é `Require` declarado. Service de jogo nunca requer `DevService`; só os `*DevService`.
- `Register` só no `OnInit` dos `*DevService`. Nenhum responder Lync, nenhum packet novo.
- Jogador é passado por **nome** (`"Player1"`); o handler resolve com `Players:FindFirstChild`.
- Retorno é tabela simples (números, strings, bools), para o QA imprimir no Output.
- `BindableFunction` em `ServerStorage` não é visível ao client; `IsStudio` impede que exista em produção.
- Para `FireAs` ser fiel ao pacote real, os responders do `CombatService` são finos: o callback do Lync
  chama um método público (`HandleAttack(player, data)`, `HandleRecall(player)`,
  `HandleUseSkill(player, data)`, `HandleSetAutoSkill(player, data)`) e o `FireAs` chama o mesmo método.
  Validação e rate limit são os mesmos.

Uso no Command Bar do servidor:

```
game.ServerStorage.Dev:Invoke("Damage", 1, 600, "Player1")
print(game.ServerStorage.Dev:Invoke("Ledger", 1))
```

Comandos por task:

| Task | Arquivo | Comandos |
|---|---|---|
| TASK-006 | `DevService` + `EnemyDevService` | `Enemies()` → `{ Uid, EnemyId, Health, MaxHealth, Alive, Life }`; `Damage(uid, amount, playerName)` → aplicado; `Kill(uid, playerName)`; `Ledger(uid)` → `{ Name, Damage, Present }` + `Total` |
| TASK-014 | `EconomyDevService` | `Coins(playerName)`; `SetCoins(playerName, n)`; `LastPayout(uid)` → `{ Name, Damage, Present, Share }` |
| TASK-015 | `CombatDevService` | `Units(playerName)` → `{ Id, Slot, PetId, Target, Ring, ArriveAt, NextHitAt, SkillReadyAt }`; `Engagement(playerName)` → `{ EnemyUid, Phase, Featured }`; `FireAs(playerName, packet, payload)` para `Attack` e `Recall` |
| TASK-019 | `CombatDevService` (mesmo arquivo, depois da 015) | `FireAs` aceita também `UseSkill` e `SetAutoSkill`; `Engagement` ganha `Queue`, `LastCastAt`, `PendingHits`; `SetSkillReady(playerName, unitId, at)` |

Simular saída de jogador (D7): fechar a janela do client no Clients and Servers, ou `player:Kick()` no
Command Bar do servidor. Não há comando de dev para isso.

---

## 5. State manager de combate

### 5.1 Dois relógios independentes: dano e coreografia

| Camada | Escopo | Quem decide | O que faz | Ligada à animação? |
|---|---|---|---|---|
| **Dano básico** | por unidade | servidor | cada unidade chegada causa `Damage` a cada `AttackInterval`, esteja ou não em cena | não |
| **Skill** | por unidade | servidor | cast por auto (cooldown pronto) ou por pedido manual; dano `HitDelay` após o próprio cast (PT-24) | sim: o cast **é** o beat `Skill` |
| **Coreografia** | por jogador | servidor (ordem) + client do dono (pixels) | escolhe o pet "em cena" daquele jogador, a sequência Enter → Combat1 → Combat2 → BackOff, interrupção por Skill | é só isso |
| **Assist** | por unidade fora de cena | client | loop leve perto do alvo | sem servidor |

O número de dano que sobe na tela vem da camada de dano (`Hits`), não da animação. O DPS é honesto e
a animação nunca atrasa nem acelera dano (DEC-020). A única ligação é a skill: o dano da skill sai em
`HitDelay` depois do beat `Skill`, para o número casar com o impacto.

### 5.2 `Engagement` por jogador (PT-17)

DEC-023 tornou a coreografia **por jogador**. Opções avaliadas:

| Opção | Como | Veredito |
|---|---|---|
| A. Engagement por inimigo, coreografia por jogador dentro | um objeto por inimigo com N sub-sequências | junta coisas que não interagem; complica fechar/recall |
| B. Engagement por (jogador, inimigo) | chave composta | um jogador só tem um alvo por vez (todas as unidades atacam o mesmo alvo, FEAT-006), então a chave composta é redundante |
| **C. Engagement por jogador** (escolhida) | `Engagements[player]`, com `EnemyUid` dentro | uma entrada por jogador engajado; trocar de alvo = trocar `EnemyUid` e reiniciar a sequência; recall = apagar a entrada |

O que continua **por inimigo**: vida e ledger (`EnemySpawn`) e o anel de posições (`Rings[enemyUid]`),
porque as unidades de jogadores diferentes ocupam o mesmo espaço físico em volta do mesmo inimigo.

```
Engagement = {
  Owner: Player,
  EnemyUid,
  Units: { unitId }                ordem de slot; define a vez na coreografia
  Phase: FSM                       "Open" | "Exchange" | "Skill" | "Closed"   (Libs.FSM)
  Featured: unitId?                pet em cena deste jogador
  Script: { Move }                 sequência restante do turno do Featured
  MoveEndsAt: number
  Cursor: number                   próxima posição na fila (round-robin)
  Queue: SkillQueue                unidades com skill pedida, sem repetição, em ordem de pedido
  LastCastAt: number               para Tuning.SkillGap
  PendingHits: { {at, unitId, amount, kind} }
}
```

Transições da `Phase`:

```
Open ──(há unidade chegada)──► Exchange ──(turno terminou)──► Open
  │                               │
  └──(cast)──► Skill ◄──(cast)────┘ (interrompe o turno)
                 │  ▲
                 │  └──(cast, depois de SkillGap)── nova skill corta a anterior
                 └──(fim de Skill + BackOff)──► Open
qualquer ──(inimigo morreu / recall / troca de alvo / sem unidades)──► Closed
```

### 5.3 Algoritmo por tick (20 Hz, `now = workspace:GetServerTimeNow()`)

Para cada Engagement:

1. **Chegada.** Unidade com `now < ArriveAt` não causa dano, não entra na fila, não pode usar skill.
2. **Hits básicos.** Para cada unidade chegada: enquanto `now ≥ NextHitAt`: `EnemyService:ApplyDamage`,
   empilha `Hit { Enemy, Unit, Amount = aplicado, Kind = "Basic" }`, `NextHitAt += AttackInterval`.
   Primeiro `NextHitAt = ArriveAt + AttackInterval × fração aleatória` para dessincronizar os números.
3. **Auto-skill.** Se o atom `AutoSkill` do dono é `true`: toda unidade chegada com `now ≥ SkillReadyAt`
   entra na `Queue` (se ainda não está). Em ordem de slot, então ligar o auto com várias prontas dispara
   todas em ordem de slot (DEC-022).
4. **Cast.** Se a `Queue` não está vazia e `now ≥ LastCastAt + Tuning.SkillGap` (Provisório 0,3 s, DEC-022):
   tira a cabeça da fila e chama `Cast(unit)`:
   - unidade ainda engajada e chegada, senão descarta;
   - emite beat `Skill` dessa unidade (só para o dono, PT-18);
   - agenda `PendingHit` em `now + Ability.HitDelay` com `Ability.Power × Damage` (dividido em `Hits` se houver);
   - `SkillReadyAt = now + Ability.Cooldown` → `PetService:SetSkillReady` → set `Pets` (UI do slot);
   - `Featured = unit`, `Script = { "BackOff" }`, `MoveEndsAt = now + duração(Skill)`, `LastCastAt = now`;
   - se havia turno em curso (outro pet em cena), ele é **interrompido** sem beat extra: o beat `Skill`
     de outra unidade já significa "corta o combate" no client (5.5);
   - `Phase → Skill`.
5. **PendingHits** vencidos → aplica dano, empilha `Hit` com `Kind = "Skill"`.
6. **Coreografia.** Quando `now ≥ MoveEndsAt`: próximo movimento do `Script` (emite beat) ou, se acabou,
   `Open`. Em `Open` com unidade chegada: `Featured = próxima da fila` (round-robin a partir de `Cursor`),
   `Script = AnimationSet.Turn` do personagem (padrão `Enter, Combat1, Combat2, BackOff`), emite o
   primeiro beat, `Exchange`.
7. **Morte.** Inimigo morreu durante o tick → todos os Engagements dele vão a `Closed`, unidades com
   `Target = nil`, pets voltam ao dono (DEC-024). `PendingHits` pendentes são descartados.

Sequência resultante, que é a da proposta ao contratante (FEAT-024): `Enter → Combat1 → Combat2 → BackOff`
no turno normal; quando a skill entra, `Skill → BackOff`. Um pet em cena por vez, por jogador.

Duração de cada movimento = `AnimationSet.Tracks[move].Duration` (PT-15). O servidor nunca carrega animação.

### 5.4 Skills: auto e manual (PT-16, PT-23, PT-24, DEC-022)

**Cooldown (PT-23), regra única:**

- A unidade nasce com `SkillReadyAt = 0` (pronta).
- O cooldown começa **no cast** (beat `Skill`): `SkillReadyAt = castAt + Ability.Cooldown`.
- O relógio corre sempre, em combate ou fora. Chegada ao alvo, `Recall`, troca de alvo e morte do alvo
  **não** reiniciam nem pausam o cooldown.
- Skill pronta só entra na fila com a unidade **chegada** (`now ≥ ArriveAt`, passo 1 de 5.3). Na prática,
  a primeira skill de uma luta sai ~`ArriveSeconds` (0,4 s) depois do `Attack`, se estiver pronta.
- Por quê: a skill aparece logo na primeira luta da apresentação (A9 visível sem esperar 8 s); trocar de
  alvo não pune nem recompensa; o servidor guarda um número por unidade. A frase de FEAT-022 "começa a
  contar quando o pet chega ao alvo" precisa sair (pendência da secretária).

**Momento do dano (PT-24), regra única:**

- "Disparo" = cast = beat `Skill`. O dano da skill sai `Ability.HitDelay` (0,4 s) depois do **próprio**
  cast, para o número casar com o impacto da animação.
- Casts do mesmo jogador ficam espaçados por `Tuning.SkillGap` (0,3 s, DEC-022), então o dano de skills
  prontas ao mesmo tempo também sai espaçado: com 3 prontas, danos em +0,4 s, +0,7 s e +1,0 s.
- O espaçamento é regra do servidor (fila), não da animação: a animação não atrasa nem adianta dano
  (DEC-020). Atraso máximo pela fila = `(N − 1) × SkillGap` (0,6 s no v0; 2,1 s com 8 pets). Como o cooldown
  conta do cast real, não há perda de DPS ao longo da luta.
- Jogadores diferentes não esperam um ao outro (fila por Engagement).
- Por que não "dano de todas na hora, só animação em fila" (texto atual de FEAT-024): os números das
  skills 2 e 3 subiriam antes das animações delas, quebrando o casamento número/impacto que A16 mostra.

| Modo | Quem pede | Validação | Efeito |
|---|---|---|---|
| Auto ligado (padrão) | o próprio tick (passo 3) | unidade chegada e cooldown pronto | entra na `Queue`; cast no passo 4 |
| Auto desligado | client: toque no slot do pet → `UseSkill { Unit }` | dono da unidade = remetente; unidade existe (= equipada); `AutoSkill == false`; `now ≥ SkillReadyAt`; unidade com alvo vivo e chegada; não está na `Queue`; rate limit | entra na `Queue`; cast no passo 4 (≤ `SkillGap` de espera) |
| Troca de modo | client: toggle → `SetAutoSkill { Enabled }` | rate limit | grava `AutoSkill` no perfil (`ProfileService`), que replica via `Profile` |

Regras:

- Pedido inválido é ignorado em silêncio (não há packet de erro). O client tem tudo para não pedir errado:
  `SkillReadyAt` no set `Pets`, `AutoSkill` no `Profile`, alvo e chegada derivados do set.
- Em modo manual, skill pronta espera o toque sem limite (DEC-022). O servidor não guarda "skill pendente
  sem pedido".
- `Recall`, troca de alvo e morte do alvo limpam a `Queue` do jogador.
- O client mostra o estado do slot só a partir de dados replicados:

| Estado do slot | Condição (client) | Visual |
|---|---|---|
| Auto | `AutoSkill == true` | anel verde girando em volta do slot (puramente visual), toque desabilitado |
| Recarga | `now < SkillReadyAt` | preenchimento radial do cooldown (`Ability.Cooldown`) |
| Pronta | `AutoSkill == false`, `now ≥ SkillReadyAt`, pet no alvo | destaque, toque habilitado |
| Indisponível | sem alvo ou pet ainda chegando | esmaecido, toque desabilitado |
| Pedido enviado | depois do toque, até `SkillReadyAt` mudar ou `Tuning.SkillRequestTimeout` (1 s) | brilho curto; evita toque duplo |

### 5.5 Sincronização e coreografia no client (PT-04, PT-18, PT-19)

**Beat privado.** `Beat { Unit, Move }` com `:timestamped()` vai só para o dono do Engagement
(`fireClient`). Ninguém mais precisa dele: os outros jogadores não veem essa coreografia (DEC-023).
`Enemy` sai do payload (o client sabe o alvo da unidade pelo set `Pets`).

Como o client do dono toca um beat (`CombatController`, palco `Stage`):

1. `late = GetServerTimeNow() - sent`. Se `late ≥ Duration` do movimento → ignora.
2. Toca a trilha do pet com *seek* `TimePosition = late`.
3. `Enter`: pet teleporta do slot do anel para a posição de golpe (frente do inimigo, distância
   `EnemyCharacter.Radius + PetCharacter.Reach`), efeitos `TeleportOut/TeleportIn` do personagem.
4. `Combat1`/`Combat2`: o modelo **local** do inimigo gira para o pet em cena e toca a reação de
   `EnemyAnimationSet.Reactions[move]` (ex.: `Combat1 → Defend`, `Combat2 → Hit`) com o mesmo seek.
5. `Skill`: para tudo que está no palco local (pet em cena anterior volta ao slot do anel por teleporte, a
   reação do inimigo para), o pet da skill teleporta para a posição de golpe e toca `Skill` + VFX
   (`CastEffect` no início, `Effect` no alvo em `HitDelay`); inimigo toca `Reactions.Skill`
   (padrão `HitHeavy`, que cai para `Hit` se o set não tiver).
6. `BackOff`: anima e teleporta de volta ao slot do anel; inimigo volta a `Idle`.
7. Pets do jogador fora de cena tocam `Assist` em loop no slot do anel (DEC-023, T-05).

**O inimigo com 2+ jogadores atacando** (proposta do v0, PT-18): cada client anima o inimigo segundo a
**própria** sequência. O modelo é local (PT-01), então o jogador A vê o inimigo defendendo os golpes do
pet de A, e o jogador B vê o mesmo inimigo defendendo os golpes do pet de B, ao mesmo tempo, sem
conflito. O que é compartilhado é só o que vem do servidor: vida (`Enemies.Health`), morte e respawn. Os
números de dano são de cada um (PT-22, 7.3). Critério A19 coberto.

- Client que não está atacando aquele inimigo: o inimigo toca `Idle` (e `Death`/`Spawn` pelo set). Quem
  luta ali aparece pela barra de vida caindo e pelos pets do outro jogador em `Assist` no anel (PT-19).

**Pets de outros jogadores** (PT-19, **Provisório**, Q-037): no client de A, os pets de B ficam no slot do
anel deles tocando `Assist` em loop enquanto B está engajado; fora de combate, `Idle`/`Run` seguindo B.
Sem coreografia, sem teleporte, sem VFX de skill. Motivos: não exige tráfego (o set `Pets` já tem `Target`
e `Ring`), não disputa o palco do jogador local, e corta custo de VFX no client. Se o usuário quiser ver
skills dos outros, o caminho é um packet `SkillCast { Unit }` para a `Audience` (≈ 1 por skill), sem
mudar o resto.

Por que **reliable**: um `Skill` perdido deixa um combo tocando por cima de uma skill; um `BackOff`
perdido deixa o pet parado na frente do inimigo. Volume baixo demais para justificar perda.

### 5.6 Animação por dados (PT-15)

- Código só conhece chaves:
  - pet: `Idle`, `Run` (locomoção), `Assist` (suporte, loop), `Enter`, `Combat1`, `Combat2`, `BackOff`
    (combate), `Skill`;
  - inimigo: `Idle`, `Defend`, `Hit`, `HitHeavy` (opcional), `Death`, `Spawn`.
- `RigAnimator` (client) recebe um rig (Model com `AnimationController` + `Animator`) e um `AnimationSet`,
  carrega trilhas sob demanda, guarda cache por rig, e expõe `Play(key, { Seek, Fade })`, `Stop(key)`,
  `StopGroup(group)` com grupos `Locomotion`, `Support`, `Combat`, `Reaction`.
- Placeholder: R6 (DEC-019, DEC-028), animações feitas no Animation Editor. Trocar pelo contratante =
  trocar `Id` e `Duration` em `AnimationSets.luau`.

Risco ainda aberto (T-02 → Q-036 a): no Roblox uma animação só toca se o asset pertence ao mesmo dono
da experiência (usuário ou grupo).

---

## 6. Movimento de pet (PT-05, PT-06)

### 6.1 Onde roda

Só no client (`PetController`), para todos os pets de todos os jogadores, com posição **derivada** do
estado replicado. O servidor nunca manda posição de pet.

| Estado | Posição derivada no client | Animação |
|---|---|---|
| `Target = nil` | formação atrás do personagem do dono: `HRP.CFrame * offset(slot)`, lerp exponencial | `Run` se distância > 1 stud, senão `Idle` |
| `Target = uid`, fora de cena | slot `Ring` do anel do inimigo: ângulo `ring × 2π / max(N, 6)`, raio `EnemyCharacter.Radius + Tuning.AssistDistance` (Provisório 6 studs, FEAT-024); olhando para o inimigo | `Assist` (loop) |
| `Target = uid`, em cena (só pets do jogador local) | posição de golpe, controlada pelo `CombatController` durante `Enter`..`BackOff`/`Skill` | movimento do beat |

O `PetController` cede a posição de uma unidade ao `CombatController` enquanto ela está em cena
(`Stage:Owns(unitId)`), e retoma no `BackOff`, no corte por skill ou quando o alvo some.

### 6.2 Implementação

- Modelos de pet ancorados (`HumanoidRootPart.Anchored = true`, resto soldado por Motor6D), sem Humanoid,
  `CanCollide = false`, `CanQuery = false`, `CanTouch = false`.
- Um `OnTick` a 60 Hz no `PetController` calcula todos os alvos e aplica com `workspace:BulkMoveTo` nas
  raízes (um único call por frame).
- Altura: raycast para o chão a 10 Hz por pet (não por frame), cacheado.
- Transição seguir → anel e anel → seguir: teleporte (efeito `TeleportOut` + `TeleportIn`) se a distância
  for > `Tuning.TeleportThreshold` (Provisório 25 studs); senão corre.
- Personagem do dono morto/sem `HumanoidRootPart`: pets congelam no lugar até o respawn.
- Alvo morre (`Enemies.Alive = false`) → o servidor zera `Target`; o client volta à formação (DEC-024).

### 6.3 Chegada no servidor (PT-06)

O servidor não sabe onde o pet está. Ao receber `Attack`, considera a unidade "chegada" em
`now + Tuning.ArriveSeconds` (Provisório 0,4 s) — o tempo do teleporte visual. Sem pathfinding, sem
validação de posição de pet (não há o que trapacear: o pet não tem colisão nem hitbox).

### 6.4 Hitbox

Não existe hitbox de golpe no servidor. O combate é **por alvo travado**: dano vai para o inimigo do
Engagement, não para o que um volume toca. A única validação espacial é alcance (`CommandRange`,
`LeashRange`) entre o personagem do jogador e a posição do spawn. Dano em área (futuro) escolhe alvos
secundários por distância entre posições de spawn no `EnemyService`, ainda sem física.

---

## 7. Client

### 7.1 Prioridades

| Módulo | Espécie | Priority | Require | Responsabilidade |
|---|---|---|---|---|
| `NetController` | Controller | 1000 | — | existente |
| `InputController` | Controller | 900 | — | existente + `OnWorldTap(callback(screenPos))` (PT-12) |
| `ProfileController` | Controller | 800 | — | `Coins`, `AutoSkill`, `Pets`, `Equipped` em `Vide.source`; escuta `Profile`, `Inventory`, `Reward` |
| `EffectController` | Controller | 760 | — | spawna VFX por chave de `Effects` (pool por chave, limite global) |
| `EnemyController` | Controller | 750 | `EffectController` | set `Enemies` → modelos locais em `Workspace.Visuals.Enemies`, `RigAnimator`, Idle/Death/Spawn, barra de vida (Vide `HealthBar`), `Pick(model) → uid`, `Rig(uid)`, `Health(uid)` source |
| `PetController` | Controller | 700 | `EnemyController`, `EffectController` | set `Pets` → modelos locais em `Workspace.Visuals.Pets`, movimento e Assist (seção 6), `Rig(unitId)`, `MyUnits` source (com `SkillReadyAt`, `Target`, chegada estimada) |
| `CombatController` | Controller | 650 | `EnemyController`, `PetController`, `EffectController` | escuta `Beat` (privado) e toca o palco local (5.5): pet em cena, reação do inimigo, teleportes, VFX de skill |
| `DamageNumberController` | Controller | 640 | `EnemyController`, `PetController` | escuta `Hits` (privado: só os próprios), mostra números (FEAT-020, PT-22) |
| `CommandController` | Controller | 600 | `InputController`, `EnemyController`, `PetController`, `ProfileController` | tap → raycast → `Attack`/`Recall`; `UseSkill(unitId)` (recusa local se auto ligado ou não pronta); `SetAutoSkill(bool)`; `SlotState(unitId)` source para a UI |
| `InterfaceController` | Controller | 500 | `ProfileController`, `CommandController`, `EnemyController`, `PetController`, `InputController` | `Vide.mount` do ScreenGui no `OnStart`; `Screen` source; troca o contexto do Input para `Menu` quando uma tela cobre o jogo |

Responders de rede só no `OnInit` de Controller. Sets lidos com `onAdded/onChanged/onRemoved` como o
`VitalController` faz hoje.

### 7.2 Seleção de alvo (PT-12)

- Mobile: `UserInputService.TouchTapInWorld(position, processedByUI)` — ignora se `processedByUI`.
- PC: `InputBegan` de `MouseButton1` sem `gameProcessed`, confirmado no `InputEnded` se o mouse andou
  < 6 px.
- `CommandController` faz `ViewportPointToRay` + `Raycast` com filtro `Include = { Workspace.Visuals.Enemies }`.
- Cada modelo de inimigo ganha uma Part `PickBox` invisível (`CharacterDef.PickSize`) com `CanQuery = true`.
- Mesmo alvo atual → `Recall` (toggle, Q-030 Provisório). HUD tem botão "Parar".

### 7.3 Números de dano (FEAT-020)

- Pool de `BillboardGui` adornado num `Attachment` no topo do modelo do inimigo (`CharacterDef.Height`).
- Sobe ~2 studs em 0,8 s com fade, offset horizontal aleatório; `Kind = Skill` maior e com outra cor.
- **Cada client mostra só os números dos próprios pets** (PT-22, FEAT-024 "No v0"). O servidor manda
  `Hits` só para o dono das unidades (`network.md`); o client não filtra e não existe cor "neutra".
- Por quê: segue o design (FEAT-024) e a lógica de "cada um vê a própria luta" (DEC-023); evita tela
  poluída no mobile com vários jogadores no mesmo inimigo; banda cai de O(jogadores) para O(1) por client.
  Se o usuário quiser ver os números dos outros (Q-037), volta a ser broadcast com cor neutra, sem mudar
  o schema.
- Limite 10 por inimigo e 40 no total (mobile); acima disso recicla o mais antigo.
- Instâncias + `TweenService`, não árvore Vide por número: efeito efêmero de alta frequência.

### 7.4 UI (Vide, FEAT-015)

- Importação (DEC-017): PNG por elemento + JSON de estrutura + foto de referência. IDs das imagens em
  `src/Shared/Content/Interface.luau`, nunca no componente.
- Cada tela: `src/Interface/client/Screens/<Tela>/init.luau` + `<Tela>.story.luau` (UI Labs).
- `Hud` funcional (DEC-018, DEC-021, DEC-022):
  - contador de dinheiro (`ProfileController.Coins`) e popup "+N" (`LastReward`);
  - botão Parar;
  - toggle Auto-skill (`ProfileController.AutoSkill` → `CommandController:SetAutoSkill`);
  - uma `PetSlot` por pet equipado: ícone, cooldown radial, anel verde girando quando auto, toque →
    `CommandController:UseSkill(unitId)`; estados da tabela em 5.4;
  - atalhos para as outras telas.
- `Shop`, `BattlePass`, `Inventory`: só visuais no v0.
- Barra de vida do inimigo: componente Vide `HealthBar` num `BillboardGui` por inimigo.

---

## 8. Assets e rigs (PT-11)

| Item | Convenção |
|---|---|
| Local no DataModel | `ReplicatedStorage.Assets.Characters.<ModelKey>`, `ReplicatedStorage.Assets.Effects.<EffectKey>` |
| No repositório | `assets/roblox/Characters/<ModelKey>.rbxm`, `assets/roblox/Effects/<EffectKey>.rbxm`, mapeados no `.rogen.json` |
| Rig | R6 (maioria) ou custom (bosses), DEC-019. Sempre `AnimationController` + `Animator`, **sem Humanoid** |
| Raiz | `HumanoidRootPart` como `PrimaryPart`, `WorldPivot` no pé (centro da base), frente = `-Z` |
| Partes | todas `CanCollide = false`, `CanTouch = false`, `CanQuery = false`, `Massless = true`; a raiz `Anchored` |
| Placeholder v0 | **R6** (T-04 resolvida, DEC-028): R6 do contratante se chegar a tempo, senão R6 "Dummy" do Studio sem Humanoid, com AnimationController (Q-027) |

O código nunca faz `FindFirstChild("Left Arm")`: só raiz, pivot, `Animator` e `Attachment`s opcionais
(`Overhead`, `Hand`) declarados em `CharacterDef`. Isso é o que deixa boss custom rig entrar sem código.

---

## 9. Reaproveitar ou remover do template (PT-07)

| Módulo | Destino | Motivo |
|---|---|---|
| `NetService`/`NetController`, `Log` | mantém | base da rede |
| `PlayerService` | mantém | signals de jogador/personagem |
| `ProfileService`/`ProfileController` | **estende** | Template v0, Mock, replicação dividida, `AutoSkill` (`data.md`) |
| `InputController` | **estende** | `OnWorldTap` |
| `Libs/FSM` | usa | `Phase` do Engagement |
| `Libs/Signal`, `Libs/Promise`, `Charm` | usa | signals de serviço, estado reativo do perfil |
| `Vital` + `VitalService` + `VitalController` + set `Vitals` | **remove** | vida de jogador; o jogo não tem dano no jogador (Q-018 rec.). O padrão Component + Service é copiado no `EnemySpawn`. |
| `Round` + `RoundService` + `RoundController` + packet `Round` | **remove** | não há rodada |
| `Counter` (Interface) | remove depois | fica até a primeira tela real ter story |
| `src/ModuxTypes/*` de Vital/Round | somem no `modux generate` | gerados |

---

## 10. Orçamento (v0 e teto do jogo completo)

| Item | v0 | Teto proposto (jogo completo) | Como garantir |
|---|---|---|---|
| Jogadores por servidor | 2 (teste) | 12 (Q-020 rec.) | `MaxPlayers` do place |
| Pets equipados por jogador | 3 | 8 | `EquipSlots` no perfil |
| Unidades de pet no servidor | 6 | 96 | servidor só tem tabela por unidade |
| Inimigos vivos por servidor | 1–5 | 40 por ilha carregada | `EnemySpawn` por Part; tick só nos Engagements ativos |
| Engagements simultâneos | ≤ 2 | 12 (1 por jogador) | por construção (PT-17) |
| Rigs animados visíveis no client | ~10 | 50 (mobile) | LOD: pets de outros jogadores ocultos > 150 studs; inimigos > 200 studs sem animação, > 300 studs sem modelo |
| Rigs em coreografia por client | 2 (pet em cena + inimigo) | 2 | só o palco local; pets dos outros só em `Assist` (PT-19) |
| Tris por personagem | — | ver `art/style-guide.md` | — |
| VFX de skill simultâneos | 2 | 6 por client | só skills do próprio jogador geram VFX (PT-19); `EffectController` recusa acima do limite; variante `Lite` em qualidade baixa |
| Partículas por VFX | — | ≤ 100 (mobile) | regra para o contratante (Q-036 b) |
| Números de dano | 10/inimigo | 10/inimigo, 40 total | pool |
| Tick de combate (servidor) | 20 Hz | 20 Hz | `OnTick(..., 20)` |
| Replicação de rede por client | < 1 KB/s | < 5 KB/s no pior caso (ver `network.md`) | Lync: 32 KB/s de orçamento por client |
| Comandos client → servidor | — | ≤ 10/s por jogador | rate limit no `CombatService` |

---

## 11. Fluxos de dados

### 11.1 Entrar no servidor

```
PlayerService.PlayerAdded → ProfileService:Load (Mock no v0) → Loaded
  → PetService: concede StarterPets se vazio → cria unidades → Pets:add (todos veem)
NetController.OnStart → Ready → NetService.ClientReady
  → ProfileService:Replicate (Profile { Coins, AutoSkill } + Inventory)
Sets Enemies/Pets chegam sozinhos ao client (onAdded) → EnemyController/PetController criam modelos
```

### 11.2 Atacar

```
toque no inimigo → InputController.OnWorldTap → CommandController raycast → Attack { Enemy = uid }
  → CombatService valida → Engagements[player] criado/trocado → unidades: Target, Ring, ArriveAt
  → Pets:update (Target, Ring) → todos os clients: pets vão ao anel e tocam Assist
tick 20 Hz → dano básico de todas as unidades (Hits de cada jogador só para ele)
          → coreografia do jogador (Beat Enter/Combat1/Combat2/BackOff só para o dono)
  → EnemySpawn:TakeDamage → Enemies:update (Health)
  → client do dono: CombatController anima pet em cena + reação do inimigo local
  → dono: DamageNumberController mostra os próprios Hits; todos: HealthBar lê Health
```

### 11.3 Skill

```
auto ligado:  tick vê SkillReadyAt ≤ now → Queue
auto desligado: toque no PetSlot → CommandController:UseSkill(unit) → UseSkill { Unit } → valida → Queue
tick: Queue + SkillGap → Cast → Beat Skill (dono) + PendingHit(HitDelay) + Pets:update (SkillReadyAt)
  → client do dono: corta o pet em cena, teleporta o pet da skill, Skill + VFX, inimigo HitHeavy
  → HitDelay depois do próprio cast: Hits { Kind = Skill } para o dono → Beat BackOff no fim da Skill
toggle: SetAutoSkill { Enabled } → profile.AutoSkill → Profile (packet) → HUD (anel verde)
```

### 11.4 Morte e recompensa

```
Health = 0 → EnemySpawn: Alive = false → Enemies:update → EnemyService.Died(uid, ledger, def)
  → CombatService fecha os Engagements do inimigo → unidades Target = nil → pets voltam ao dono (DEC-024)
  → EconomyService divide Rewards.Coins (denominador = ledger inteiro, paga só presentes, PT-21)
  → profile.Coins(+parte) → Profile (packet) + Reward (packet)
  → client: Death anim, modelo some; HUD atualiza Coins; popup "+N"
RespawnSeconds depois → Alive = true, Health cheia, Life + 1 → client: Spawn anim
```

---

## 12. Dúvidas técnicas para o usuário

Todas as da revisão 1 estão resolvidas (DEC-028):

| ID | Dúvida | Resolução |
|---|---|---|
| T-01 | Dinheiro entra no v0? | **Resolvida**: entra (DEC-021). `EconomyService` registrado; HUD mostra Coins. |
| T-02 | Animações do contratante publicadas pelo dono do jogo? | **Movida** para Q-036 (a), que é do usuário/contratante. Não bloqueia o v0 (placeholders são publicados por nós). |
| T-03 | "Forçar skill" ignora o cooldown? | **Resolvida/substituída**: sem botão Forçar; toggle Auto-skill + skill manual por slot (DEC-022, PT-16). |
| T-04 | Placeholder R6 ou R15? | **Resolvida**: R6 (DEC-019, DEC-028). |
| T-05 | Pets fora de cena: guarda ou golpes de fundo? | **Resolvida**: animação `Assist` em loop (DEC-023). |
| T-06 | Alvo morto: volta ao dono ou procura outro? | **Resolvida**: volta ao dono (DEC-024). |

Sem dúvida técnica nova bloqueante. Pendências que dependem de terceiros e não travam o código:
Q-036 (dono das animações, formato de VFX) e Q-037 (pets de outros jogadores — PT-19 Provisório).

---

## 13. Ordem de implementação do v0

Passos pequenos, base primeiro. `∥` = pode correr em paralelo com os outros da mesma onda.
Trilhas: **B** backend, **F** frontend (controllers, rigs, VFX), **U** UI (Vide/Figma), **A** arquiteto.
Cada passo termina com `modux check` + `tools/analyze.ps1` em zero erro.

### Onda 0 — base (sequencial, bloqueia o resto)

1. **A** — Atualizar `src/Libs/Net/init.luau` com todas as entradas do v0 de `network.md` (inclui
   `UseSkill`, `SetAutoSkill`, `Beat` privado; sem `ForceSkills`/`ForceCooldown`) e remover `Vitals` e `Round`.
2. **B** — Remover as features `Vital` e `Round`; `rogen build` + `modux generate`; projeto em zero erro.
3. **B** — `src/Shared/Content`: `Types.luau`, `init.luau` (lookups) e tabelas com 1 inimigo, 3 pets,
   1 habilidade, 2 AnimationSets (R6 pet com `Assist`, R6 inimigo com `Defend`/`Hit`), efeitos placeholder
   (`content-data.md`). `ContentService` validando.

### Onda 1 — núcleo (∥ entre trilhas)

4. **B ∥** — `ProfileService`: Template v0 (com `AutoSkill`, `OwnedPet.Xp`/`Gear`), Mock, `Mutate`,
   `Migrations`, `Bind` pelo Template, replicação dividida `Profile`/`Inventory` (`data.md`).
   `ProfileController` com as sources novas.
5. **B ∥** — `EnemyService` + `EnemySpawn` (vida, ledger, morte, respawn, set `Enemies`) + `DevService` e
   `EnemyDevService` (4.6). Testável pelo Command Bar do servidor (`ServerStorage.Dev`).
6. **F ∥** — Assets placeholder: R6 sem Humanoid em `assets/roblox/Characters`, entrada no `.rogen.json`,
   animações placeholder publicadas (pet: Idle, Run, Assist, Enter, Combat1, Combat2, Skill, BackOff;
   inimigo: Idle, Defend, Hit, HitHeavy, Death, Spawn). Mapa baseplate com 1–3 Parts `EnemySpawn`.
7. **F ∥** — `RigAnimator` (carregar por chave, cache, Play com seek, `StopGroup` por grupo).
8. **U ∥** — Pipeline de importação do Figma: subir PNGs, preencher `Content/Interface.luau`, componentes
   base (botão de imagem, painel) com stories.

### Onda 2 — atores (∥)

9. **B** — `PetService`: unidades a partir de `Equipped`, StarterPets, set `Pets` (com `SkillReadyAt`).
   Depende de 4.
10. **F ∥** — `EnemyController`: modelos locais, Idle/Death/Spawn, `PickBox`, `HealthBar` (Vide). Depende de 5, 6, 7.
11. **F ∥** — `EffectController`: pool por chave, limite global, variante `Lite`. Depende de 6.
12. **U ∥** — Tela `Hud` com dados falsos na story: Coins + popup, Parar, toggle Auto-skill, `PetSlot`
    (5 estados de 5.4, anel verde girando), atalhos. Depende de 8.

### Onda 3 — combate

13. **B** — `CombatService` parte 1: responders `Attack`/`Recall`, validação, rate limit, `Engagements`
    por jogador, `Rings` por inimigo, **dano básico** e `Hits`, leash, fechamento na morte com volta ao
    dono. Depende de 5, 9.
14. **F ∥** — `PetController`: modelos, formação seguindo o dono, anel no alvo com `Assist` em loop
    (para pets de todos os jogadores, PT-19), teleporte por distância, `BulkMoveTo`. Depende de 9, 10, 11.
15. **F ∥** — `InputController.OnWorldTap` + `CommandController` (raycast, Attack/Recall toggle). Depende de 10.
16. **F ∥** — `DamageNumberController`. Depende de 10, 13.
17. **B ∥** — `EconomyService` (divisão de `Rewards.Coins`, crédito em `Coins`, packet `Reward`). Depende de 4, 5.

### Onda 4 — luta ensaiada e skills

18. **B** — `CombatService` parte 2: `Choreography` por jogador (round-robin, `Turn` por dados, FSM
    `Phase`), `SkillQueue` + `SkillGap`, auto-skill pelo atom `AutoSkill`, responders `UseSkill` e
    `SetAutoSkill` com validação, `PendingHits`/`HitDelay`, interrupção por Skill, `Beat` privado.
    Depende de 13.
19. **F** — `CombatController` + `Stage`: beats → pet em cena com seek, reação local do inimigo
    (`Reactions`), teleportes Enter/BackOff, corte por Skill, VFX de skill, devolução ao `Assist`.
    Depende de 14, 18.
20. **F ∥** — `CommandController`: `UseSkill`, `SetAutoSkill`, `SlotState` source. Depende de 15, 18.
21. **U ∥** — `InterfaceController` montando tudo; HUD ligada aos controllers reais (Coins, Parar,
    Auto-skill, PetSlots). Depende de 12, 17, 20.
22. **U ∥** — Telas `Shop`, `BattlePass`, `Inventory` só visuais, com stories e abrir/fechar. Depende de 8.

### Onda 5 — validação

23. **QA** — Plano de teste A1–A19 (`docs/tests/`): 2 clients no Studio no mesmo inimigo (A11, A19), auto
    ligado/desligado (A9, A14), Assist dos pets fora de cena (A18), dinheiro proporcional (A17), emulador
    mobile (A12), troca de 1 modelo e 1 animação por dados (A13).
24. **F/B** — Ajustes de orçamento (LOD, limites de VFX e números) conforme medição do passo 23.

Paralelismo máximo: depois da Onda 0, as trilhas B, F e U andam juntas. Pontos de conflito: só o passo 1
mexe em `src/Libs/Net/init.luau` (dono: arquiteto); só o passo 4 mexe em `src/Profile`; passos 13 e 18
são sequenciais no mesmo `CombatService`.
