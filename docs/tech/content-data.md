# Dados de conteúdo — `src/Shared/Content`

Status: Rascunho

Autor: `architect`. Destino no DataModel: `ReplicatedStorage.shared.Content` (lido pelos dois lados).
Objetivo: tudo que o contratante entrega (modelo, animação, VFX) e todo número de balanceamento entra
por **dados**. Trocar asset ou número = editar uma linha aqui (critério A13 do DEC-013, FEAT-023).

Revisão 2 (2026-10-03): `AnimationSet` com categorias Combat/Skill/Assist (DEC-023) e `Defend`/`Hit` no
inimigo; `EnemyDef.Reward` vira `Rewards` extensível (PT-20); `Tuning` sem `ForceCooldown`, com
`SkillGap`, `SkillRequestTimeout`, `AssistDistance`; tabelas futuras (itens, materiais, missões) esboçadas.

## Arquivos

```
src/Shared/Content/
  init.luau            índice: lookups tipados, herança de AnimationSet resolvida, sem lógica de jogo
  Types.luau           todos os tipos abaixo (export type)
  Rarities.luau        { [RarityKey]: RarityDef }
  Characters.luau      { [CharacterKey]: CharacterDef }
  AnimationSets.luau   { [AnimationSetKey]: AnimationSet }
  Abilities.luau       { [AbilityId]: AbilityDef }
  Effects.luau         { [EffectKey]: EffectDef }
  Pets.luau            { [PetId]: PetDef }
  Enemies.luau         { [EnemyId]: EnemyDef }
  Eggs.luau            { [EggId]: EggDef }          (formato pronto; sem uso no v0)
  Tuning.luau          constantes globais de jogo (alcances, tempos, limites, flags)
  Interface.luau       IDs das imagens da UI importada do Figma
```

Regras:

- Cada arquivo retorna uma tabela simples, tipada com o tipo de `Types.luau`. Sem função, sem `require` de
  serviço, sem estado. Só `Color3`, `Vector3`, `Enum` e literais.
- A chave da tabela **é** o ID; o campo `Id` repete a chave e o `ContentService` confere que batem.
- IDs de design (`PET-###`, `ENM-###`, `EGG-##`) seguem `CLAUDE.md`. Chaves técnicas sem prefixo de design
  (personagem visual, AnimationSet, efeito, raridade) são `PascalCase` livres.
- Habilidade usa `ABL-###` **provisório** até Q-026 fechar e a secretária registrar o prefixo.
- `init.luau` expõe lookups que falham alto: `Content.Pet(id)`, `Content.Enemy(id)`, `Content.Character(key)`,
  `Content.AnimationSet(key)` (já com herança resolvida), `Content.Ability(id)`, `Content.Effect(key)`,
  `Content.Rarity(key)`, e `Content.Tuning`.
- `ContentService` (servidor, Priority 950) valida tudo no boot (seção "Validação"). Erro de dado aparece no
  primeiro play, não no meio de uma luta.

## Diagrama de referências

```
EnemyDef ─┐                 ┌─► Rarity
          ├─► CharacterDef ─┼─► AnimationSet ─(Inherits)─► AnimationSet
PetDef ───┘        │        │        └─► AnimationDef (Id, Duration)
   │               │        └─► Effect (TeleportOut/In)
   └─► AbilityDef ─┴─► Effect
EggDef ─► PetDef (pool com peso)
```

Pet e inimigo apontam para um **personagem** (PT-10), porque os dois são "personagens de anime" e o mesmo
modelo pode aparecer dos dois lados. O personagem carrega o que é visual (modelo, rig, tamanho,
animações, efeitos); `PetDef`/`EnemyDef` carregam o que é regra (dano, vida, recompensa).

---

## Tipos

### `RarityDef`

| Campo | Tipo | Exemplo | Notas |
|---|---|---|---|
| `Id` | string | `"Common"` | chave técnica |
| `Order` | number | `1` | ordenação na UI e comparação; ordem final em Q-010 |
| `Name` | string | `"Comum"` | texto exibido |
| `Color` | Color3 | `Color3.fromRGB(180,180,180)` | cor de raridade (style guide define a final) |

Template Provisório (DEC-005): `Common`, `Uncommon`, `Rare`, `Legendary`, `Epic`, `Mythic` (ordem como dita
pelo usuário; Q-010 pode inverter Legendary/Epic — só muda `Order`).

### `CharacterDef` (visual)

| Campo | Tipo | Exemplo | Notas |
|---|---|---|---|
| `Id` | string | `"DummyR6Red"` | |
| `Model` | string | `"DummyR6Red"` | nome em `ReplicatedStorage.Assets.Characters` |
| `Rig` | `"R6" \| "Custom"` | `"R6"` | só informativo/validação; o código não depende de nome de membro |
| `AnimationSet` | string | `"PetR6"` | |
| `Scale` | number | `1` | `Model:ScaleTo` no client |
| `Radius` | number | `1.5` | raio "do corpo" em studs: anel em volta do inimigo, distância de golpe |
| `Height` | number | `5` | altura do topo: barra de vida, números de dano |
| `Reach` | number | `2` | distância extra do golpe corpo a corpo |
| `PickSize` | Vector3? | `Vector3.new(6, 7, 6)` | caixa de toque (inimigo); padrão derivado de `Radius`/`Height` |
| `Effects` | `{ TeleportOut: string?, TeleportIn: string?, Assist: string? }` | `{ TeleportOut = "BlinkOut" }` | teleportes temáticos por personagem; ausente → efeito padrão de `Tuning`. `Assist` opcional (VFX leve do loop de assistência) |

### `AnimationDef`

| Campo | Tipo | Exemplo | Notas |
|---|---|---|---|
| `Id` | string | `"rbxassetid://1234567890"` | asset publicado pelo dono do jogo (Q-036 a) |
| `Duration` | number | `0.9` | segundos. **O servidor sequencia por este valor** (PT-15). Tem de bater com o comprimento real da animação ÷ `Speed` |
| `Speed` | number? | `1` | |
| `Looped` | boolean? | `false` | `Idle`/`Run` = true |
| `Fade` | number? | `0.1` | fade-in/out |
| `Priority` | `Enum.AnimationPriority`? | `Enum.AnimationPriority.Action` | padrão por grupo |
| `Placeholder` | boolean? | `true` | animação provisória; `ContentService` lista quantas faltam trocar |

### `AnimationSet`

| Campo | Tipo | Exemplo | Notas |
|---|---|---|---|
| `Id` | string | `"PetR6"` | |
| `Kind` | `"Pet" \| "Enemy"` | `"Pet"` | define as chaves obrigatórias |
| `Inherits` | string? | `"PetR6"` | herda tudo e sobrescreve só o que declarar. Personagem novo em R6 só precisa trocar `Combat1`/`Combat2`/`Skill`/`Assist` |
| `Tracks` | `{ [TrackKey]: AnimationDef }` | | |
| `Turn` | `{ Move }`? | `{ "Enter", "Combat1", "Combat2", "BackOff" }` | só `Kind = "Pet"`: o roteiro de um turno normal (`architecture.md` 5.3). Padrão em `Tuning.DefaultTurn`. Só pode conter `Enter`, `Combat1`, `Combat2`, `BackOff`; precisa terminar em `BackOff`. `Skill` nunca entra no `Turn`: é o servidor que interrompe o turno com `Skill → BackOff` |
| `Reactions` | `{ [Move]: TrackKey }`? | `{ Combat1 = "Defend", Combat2 = "Hit", Skill = "HitHeavy" }` | só `Kind = "Enemy"`: o que o rig que apanha toca, **no client do jogador que ataca**, para cada movimento do pet em cena dele (PT-18). Movimento sem entrada → nenhuma reação |

Categorias de animação de pet (DEC-023) e chaves de `Tracks`:

| Kind | Categoria (DEC-023) | Chaves | Grupo no `RigAnimator` | Quando toca |
|---|---|---|---|---|
| `Pet` | — | `Idle`, `Run` (loop) | Locomotion | seguindo o dono |
| `Pet` | Combate | `Enter`, `Combat1`, `Combat2`, `BackOff` (one-shot; `Duration` > 0) | Combat | pet em cena do jogador local, por beat |
| `Pet` | Skill | `Skill` (one-shot; `Duration` > 0) | Combat | beat `Skill` (interrompe o turno) |
| `Pet` | Assistência | `Assist` (loop, **obrigatória**) | Support | fora de cena com alvo: pets do próprio jogador e de todos os outros (PT-19) |
| `Enemy` | — | `Idle` (loop) | Locomotion | sem o jogador local atacando |
| `Enemy` | reação | `Defend`, `Hit` (obrigatórias), `HitHeavy` (opcional → cai para `Hit`) | Reaction | via `Reactions`, no palco local |
| `Enemy` | ciclo de vida | `Death`, `Spawn` (one-shot) | Reaction | `Alive` muda no set `Enemies` (todos os clients) |

`Assist` é "ataque à distância/suporte, loop leve" (DEC-023): o contratante entrega como animação em loop
com ciclo curto (sugestão 1–2 s), sem deslocamento da raiz (o pet fica no slot do anel). O `Duration`
de `Assist` só serve para validação (não é sequenciado pelo servidor). Se `Assist` vier com VFX próprio
(projétil, aura), ele entra em `CharacterDef.Effects.Assist` e o `EffectController` dispara no
`KeyframeMarker` `"Assist"` da trilha — somente para pets do jogador local, por orçamento.

`Move` (enum compartilhado com a rede, `network.md` `Beat.Move`): `Enter`, `Combat1`, `Combat2`, `Skill`, `BackOff`.
`Assist`, `Idle`, `Run` não são `Move`: são estados derivados no client, sem beat.
Adicionar um movimento novo = mudar o enum no Net + este documento (decisão do arquiteto).

### `AbilityDef`

| Campo | Tipo | Exemplo | Notas |
|---|---|---|---|
| `Id` | string | `"ABL-001"` | prefixo provisório (Q-026) |
| `Name` | string | `"Golpe Relâmpago"` | |
| `Kind` | `"Strike"` | `"Strike"` | v0: só alvo único. Futuro: `"Area"` (alvos por distância de spawn), `"MultiHit"` |
| `Power` | number | `5` | dano = `Power × Damage efetivo do pet` (escala com level/estrela de graça). v0: pet de 10 → 50 (FEAT-022) |
| `Hits` | number? | `1` | dano dividido em N números na tela, espaçados por `HitSpacing` |
| `HitSpacing` | number? | `0.1` | |
| `HitDelay` | number | `0.4` | segundos do início da animação `Skill` até o primeiro dano (casa número com impacto) |
| `Cooldown` | number | `8` | segundos, **por pet** (DEC-022; FEAT-022 Provisório). Começa no cast (beat `Skill`) |
| `Effect` | string? | `"SkillBurst"` | VFX no alvo, em `HitDelay` |
| `CastEffect` | string? | `"SkillCharge"` | VFX no pet, no início |

### `EffectDef`

| Campo | Tipo | Exemplo | Notas |
|---|---|---|---|
| `Id` | string | `"BlinkOut"` | |
| `Asset` | string | `"BlinkOut"` | nome em `ReplicatedStorage.Assets.Effects` |
| `Lite` | string? | `"BlinkOutLite"` | variante para qualidade gráfica baixa (mobile) |
| `Lifetime` | number | `0.6` | segundos até devolver ao pool |
| `Anchor` | `"Root" \| "Overhead" \| "Ground"` | `"Root"` | onde prende no rig |

Formato do asset de efeito (pedido ao contratante, Q-025): um `Model` ou `Attachment` com `ParticleEmitter`/
`Beam`/`Trail` desligados; o `EffectController` liga com `:Emit(n)` usando o atributo `EmitCount` de cada
emissor. ≤ 100 partículas por efeito em mobile (`architecture.md` seção 10).

### `PetDef` (regra)

| Campo | Tipo | Exemplo | Notas |
|---|---|---|---|
| `Id` | string | `"PET-001"` | |
| `Name` | string | `"Pet Placeholder Vermelho"` | sem IP de anime real (`CLAUDE.md`, Q-005) |
| `Character` | string | `"DummyR6Red"` | |
| `Rarity` | string | `"Common"` | |
| `Damage` | number | `10` | dano base por golpe (FEAT-006 Provisório) |
| `AttackInterval` | number | `1.0` | segundos entre golpes |
| `Ability` | string | `"ABL-001"` | |
| `SellValue` | number? | — | FEAT-010, sem uso no v0 |

### `EnemyDef` (regra)

| Campo | Tipo | Exemplo | Notas |
|---|---|---|---|
| `Id` | string | `"ENM-001"` | vai no atributo `EnemyId` da Part de spawn |
| `Name` | string | `"Boneco de Treino"` | |
| `Character` | string | `"DummyR6Grey"` | boss = personagem com `Rig = "Custom"`, mesma tabela |
| `Health` | number | `1000` | FEAT-002 Provisório |
| `Rewards` | `RewardDef` | `{ Coins = 100 }` | dividido por dano (FEAT-004, DEC-011, DEC-021). Ver abaixo |
| `RespawnSeconds` | number | `5` | atributo `RespawnSeconds` da Part sobrescreve |
| `Boss` | boolean? | `false` | só apresentação (barra maior) no v0; no futuro marca alvo de missão (DEC-026) |

### `RewardDef`

| Campo | Tipo | v0 | Notas |
|---|---|---|---|
| `Coins` | number | `100` (DEC-021, Provisório) | dividido pelo ledger no `EconomyService` |
| `PetXp` | number? | — | **futuro** (DEC-027): XP total, dividida como as moedas; a parte do jogador vai para as unidades engajadas dele |
| `Drops` | string? | — | **futuro** (DEC-026): chave em `DropTables`; rolado por jogador com dano > 0 |

`ContentService` aceita `PetXp`/`Drops` ausentes. Boss = inimigo com `Rewards` maiores e `Drops`; não há
tipo separado.

### `EggDef` (sem uso no v0)

| Campo | Tipo | Exemplo | Notas |
|---|---|---|---|
| `Id` | string | `"EGG-01"` | |
| `Name` | string | | |
| `Price` | number | | Q-012 |
| `Island` | string? | `"ISL-01"` | |
| `Pool` | `{ { Pet: string, Weight: number } }` | `{ { Pet = "PET-001", Weight = 70 } }` | chance = peso ÷ soma. Peso, não porcentagem: adicionar pet não obriga a recalcular os outros. A UI exibe a porcentagem calculada (regra do Roblox para itens aleatórios pagos, FEAT-018) |

### `Tuning`

| Campo | v0 | Uso |
|---|---|---|
| `StarterPets` | `{ "PET-001", "PET-002", "PET-003" }` | concedidos se o perfil não tem pets |
| `PersistProfiles` | `false` | `false` = ProfileStore Mock (PT-09) |
| `CombatTickRate` | `20` | Hz do `CombatService` |
| `CommandRange` | `80` | studs, personagem → inimigo, para aceitar `Attack` |
| `LeashRange` | `120` | studs; além disso, recall automático |
| `ArriveSeconds` | `0.4` | atraso até a unidade começar a causar dano (PT-06) |
| `DefaultAutoSkill` | `true` | valor do Template `AutoSkill` (DEC-022); documentado aqui, lido pelo Template |
| `SkillGap` | `0.3` | segundos mínimos entre casts do mesmo jogador (DEC-022) |
| `SkillRequestTimeout` | `1` | segundos do estado "pedido enviado" no `PetSlot` |
| `AssistDistance` | `6` | studs da borda do inimigo até o slot do anel (FEAT-024) |
| `CommandMinInterval` | `0.1` | rate limit de comandos (`Attack`, `Recall`, `UseSkill`, `SetAutoSkill`) |
| `TeleportThreshold` | `25` | studs; acima disso o pet teleporta em vez de correr |
| `PetFollowSpeed` | `24` | studs/s seguindo o dono |
| `DefaultTurn` | `{ "Enter", "Combat1", "Combat2", "BackOff" }` | roteiro padrão do turno |
| `DefaultTeleportOut`/`In` | `"BlinkOut"`/`"BlinkIn"` | efeito padrão de teleporte |
| `DamageNumbers` | `{ PerEnemy = 10, Total = 40, Rise = 2, Lifetime = 0.8 }` | FEAT-020 |
| `Lod` | `{ OtherPetsHide = 150, EnemyFreeze = 200, EnemyHide = 300 }` | studs (seção 10 da arquitetura) |
| `MaxSkillEffects` | `6` | VFX de skill simultâneos por client (só do jogador local, PT-19) |

Todos os valores de `Tuning` são **Provisórios**; o `game-designer` pode mexer sem passar pelo arquiteto,
exceto `CombatTickRate` e `Lod` (impacto de performance).

### `Interface`

```
{ Images: { [ImageKey]: string } }       ex.: Images.HudCoinIcon = "rbxassetid://..."
```

Chave = `<Tela><Elemento>` em PascalCase, igual ao nome do PNG exportado do Figma
(`Hud_CoinIcon.png` → `HudCoinIcon`). O componente Vide nunca tem ID de imagem literal.

---

## Exemplo mínimo do v0

Esboço de conteúdo (as tabelas reais seguem as regras de código: sem comentários).

```lua
Characters = {
	DummyR6Red = {
		Id = "DummyR6Red", Model = "DummyR6Red", Rig = "R6", AnimationSet = "PetR6",
		Scale = 1, Radius = 1.5, Height = 5, Reach = 2, Effects = {},
	},
	DummyR6Grey = {
		Id = "DummyR6Grey", Model = "DummyR6Grey", Rig = "R6", AnimationSet = "EnemyR6",
		Scale = 1.4, Radius = 2, Height = 7, Reach = 0, PickSize = Vector3.new(7, 9, 7), Effects = {},
	},
}

AnimationSets = {
	PetR6 = {
		Id = "PetR6", Kind = "Pet",
		Turn = { "Enter", "Combat1", "Combat2", "BackOff" },
		Tracks = {
			Idle = { Id = "rbxassetid://0", Duration = 2, Looped = true, Placeholder = true },
			Run = { Id = "rbxassetid://0", Duration = 0.8, Looped = true, Placeholder = true },
			Assist = { Id = "rbxassetid://0", Duration = 1.5, Looped = true, Placeholder = true },
			Enter = { Id = "rbxassetid://0", Duration = 0.25, Placeholder = true },
			Combat1 = { Id = "rbxassetid://0", Duration = 0.8, Placeholder = true },
			Combat2 = { Id = "rbxassetid://0", Duration = 0.8, Placeholder = true },
			Skill = { Id = "rbxassetid://0", Duration = 1.2, Placeholder = true },
			BackOff = { Id = "rbxassetid://0", Duration = 0.5, Placeholder = true },
		},
	},
	PetR6Blue = { Id = "PetR6Blue", Kind = "Pet", Inherits = "PetR6", Tracks = {
		Combat1 = { Id = "rbxassetid://0", Duration = 0.6, Placeholder = true },
	} },
	EnemyR6 = {
		Id = "EnemyR6", Kind = "Enemy",
		Reactions = { Combat1 = "Defend", Combat2 = "Hit", Skill = "HitHeavy", BackOff = "Hit" },
		Tracks = { Idle = ..., Defend = ..., Hit = ..., HitHeavy = ..., Death = ..., Spawn = ... },
	},
}

Abilities = {
	["ABL-001"] = { Id = "ABL-001", Name = "Golpe Carregado", Kind = "Strike",
		Power = 5, HitDelay = 0.4, Cooldown = 8, Effect = "SkillBurst" },
}

Pets = {
	["PET-001"] = { Id = "PET-001", Name = "Placeholder Vermelho", Character = "DummyR6Red",
		Rarity = "Common", Damage = 10, AttackInterval = 1.0, Ability = "ABL-001" },
}

Enemies = {
	["ENM-001"] = { Id = "ENM-001", Name = "Boneco de Treino", Character = "DummyR6Grey",
		Health = 1000, Rewards = { Coins = 100 }, RespawnSeconds = 5 },
}
```

Durações do exemplo seguem os alvos de FEAT-024 (Combat 0,8 s, Skill 1,2 s, BackOff 0,5 s).

## Validação (`ContentService`, no boot do servidor)

Erro (para o boot) se:

- chave ≠ `Id`;
- referência quebrada: `Pet.Character`, `Pet.Rarity`, `Pet.Ability`, `Enemy.Character`,
  `Character.AnimationSet`, `AnimationSet.Inherits` (e ciclo de herança), `Ability.Effect`,
  `Character.Effects.*`, `Egg.Pool[].Pet`, `Tuning.StarterPets[]`;
- `AnimationSet` (depois da herança) sem chave obrigatória do seu `Kind` (pet: inclui `Assist`; inimigo:
  inclui `Defend` e `Hit`);
- `Duration ≤ 0` em trilha de grupo Combat/Reaction;
- `Assist`, `Idle` ou `Run` sem `Looped = true`;
- `Turn` com movimento fora de `Enter`/`Combat1`/`Combat2`/`BackOff`, ou que não termina em `BackOff`;
  `Reactions` com chave fora do enum `Move` ou apontando para trilha inexistente (`HitHeavy` ausente é
  resolvido para `Hit` antes da checagem);
- `Character.Model` ou `Effect.Asset` ausente em `ReplicatedStorage.Assets`;
- número negativo em `Damage`, `AttackInterval`, `Health`, `Rewards.*`, `Cooldown`, `Weight`;
- `Tuning.SkillGap` < 0 ou `Tuning.DefaultTurn` inválido pelas mesmas regras de `Turn`.

Aviso (não para) se:

- há trilha com `Placeholder = true` — imprime a contagem ("12 animações placeholder"), que vira checklist
  da troca de assets;
- `Duration` declarada difere do comprimento real da animação em mais de 0,05 s (checagem feita no client,
  em debug, via `AnimationTrack.Length` depois do load) — avisa para corrigir o dado.

## Como trocar um asset do contratante (A13)

1. Inserir o `.rbxm` do modelo em `assets/roblox/Characters/<Nome>.rbxm` (conferir: AnimationController +
   Animator, sem Humanoid, `PrimaryPart` = `HumanoidRootPart`, pivot no pé).
2. Publicar as animações pela conta/grupo dono do jogo; anotar IDs e comprimentos.
3. Editar `Characters.luau` (`Model`, `Radius`, `Height`) e `AnimationSets.luau` (`Id`, `Duration`,
   tirar `Placeholder`).
4. `rogen build` → `modux generate` → play. `ContentService` acusa qualquer referência quebrada.

Nenhum `.luau` de Service/Controller muda.

## Tabelas futuras (fora do v0, DEC-026/027)

Formato esboçado só para o modelo de dados nascer extensível. Cada uma entra com decisão própria; os
campos dependem de Q-009, Q-038, Q-039, Q-040.

| Arquivo | Chave | Campos prováveis | Usado por |
|---|---|---|---|
| `XpCurve.luau` | — | `{ MaxLevel, XpToNext: { number } }` ou fórmula por parâmetros | `PetService` (level a partir de `OwnedPet.Xp`) |
| `Items.luau` | `ITM-###` (prefixo a registrar) | `Id`, `Name`, `Slot` (slot de equipamento), `Rarity`, `Stats = { DamageMult }` | `PetService` (multiplicador), Inventário |
| `Materials.luau` | chave técnica (`Gem`, `Stardust`, ...) | `Id`, `Name`, `Icon` (chave em `Interface`) | upgrade/merge (FEAT-031) |
| `DropTables.luau` | chave técnica | `{ Rolls, Entries = { { Kind = "Item" \| "Material", Id, Count, Weight } } }` (peso, como `EggDef.Pool`) | `EconomyService` via `Rewards.Drops` |
| `Missions.luau` | `MSN-###` (prefixo a registrar) | `Id`, `Order`, `Goal = { Kind = "DefeatEnemy", Enemy = "ENM-###", Count }`, `Rewards: RewardDef` | serviço de missões (FEAT-029) |

`PetDef` ganha no futuro só `GearSlots: { string }?` (quais slots o pet tem, Q-038); o resto do
progresso mora no perfil.
