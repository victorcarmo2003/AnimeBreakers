# Rede — contratos Lync do v0

Status: Rascunho

Autor: `architect`. Arquivo afetado: `src/Libs/Net/init.luau` (um `Lync.define` só, dono: `architect`).
Base: seção "Rede" do `README.md` raiz e `tech/architecture.md`. Versão do Lync no `wally.toml`: 4.0.2.

Revisão 2 (2026-10-03): `Profile` ganha `AutoSkill`; saem `ForceSkills` e `ForceCooldown` (DEC-022);
entram `UseSkill` e `SetAutoSkill` (PT-16); `Beat` vira privado do dono e perde o campo `Enemy` (PT-18).

Revisão 3 (2026-10-03): `Hits` vira **privado do dono** (PT-22, alinha com FEAT-024 "No v0"). Schema igual.
O mecanismo de dev do Studio (`architecture.md` 4.6) não usa rede.

## Regras usadas para escolher

| Pergunta | Resposta → escolha |
|---|---|
| Vários clients precisam ver, e quem chega depois precisa do estado atual? | **set** (`Lync.replicate`) |
| É evento (acontece e passa) ou dado privado de um jogador? | **packet** |
| Perder um pacote deixa a tela errada até a próxima mudança? | reliable (padrão). `unreliable`/`newest` só para dado que se corrige sozinho no frame seguinte |
| Precisa saber **quando** aconteceu no relógio do servidor? | `:timestamped()` (o listener recebe `sent`, relógio de `workspace:GetServerTimeNow()`) |
| Particionar audiência? | `keyBy` só em campo finito (`bool`, `int`, `enum`), e só para grupo (ilha, time). Nunca para "cada um vê o seu" — isso é packet com `fireClient` |

Transmissão servidor → todos: sempre para `NetService.Audience` (grupo alimentado pelo `Ready`), nunca
`Lync.all` (README, "Para quem o servidor manda"). Quem transmite checa `NetService:IsRunning()`.

Responders: só no `OnInit` de Service/Controller. Nenhum Component registra responder.

---

## Resumo

| Entrada | Tipo | Direção | Situação | Quem escreve | Quem lê | Frequência típica (v0) |
|---|---|---|---|---|---|---|
| `Ready` | packet | C → S | mantém | `NetController` | `NetService` | 1 por join |
| `Profile` | packet | S → C (privado) | **muda schema** | `ProfileService` | `ProfileController` | a cada mudança de Coins/AutoSkill (≈ 1 por morte de inimigo) |
| `Inventory` | packet | S → C (privado) | nova | `ProfileService` | `ProfileController` | join + mudança de pets/equipados (raro) |
| `Reward` | packet | S → C (privado) | nova | `EconomyService` | `ProfileController` (popup na HUD) | 1 por morte para quem causou dano |
| `Enemies` | set | S → todos | nova | `EnemySpawn` | `EnemyController` | `Health` até 20 Hz por inimigo apanhando |
| `Pets` | set | S → todos | nova | `PetService` (via `CombatService`) | `PetController`, `CombatController`, `DamageNumberController`, `CommandController` | por comando + 1 a cada skill |
| `Attack` | packet | C → S | nova | `CommandController` | `CombatService` | por toque (rate limit) |
| `Recall` | packet | C → S | nova | `CommandController` | `CombatService` | por toque |
| `UseSkill` | packet | C → S | nova | `CommandController` | `CombatService` | por toque em slot, só com auto desligado |
| `SetAutoSkill` | packet | C → S | nova | `CommandController` | `CombatService` | por toque no toggle (raro) |
| `Beat` | packet `:timestamped()` | S → C (privado, dono) | nova | `CombatService` | `CombatController` | ~1,5–2/s por jogador engajado + 1 por skill |
| `Hits` | packet (array) | S → C (privado, dono) | nova | `CombatService` | `DamageNumberController` | ≤ 20/s por jogador engajado (1 por tick com hit dele), cada um com N hits |
| `Vitals` | set | — | **remove** | — | — | — |
| `Round` | packet | — | **remove** | — | — | — |
| ~~`ForceSkills`~~ | — | — | **descartada** (DEC-022) | — | — | — |
| ~~`ForceCooldown`~~ | — | — | **descartada** (DEC-022) | — | — | — |

---

## Esboço do `init.luau` do v0

Documentação do contrato, não código entregue. O coder do passo 1 da ordem de implementação transcreve
para `src/Libs/Net/init.luau` (sem comentários, regra do `CLAUDE.md`).

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lync = require(ReplicatedStorage.Packages.Lync)

const ContentId = Lync.str(1, 24)

return Lync.define("game", {
	Ready = Lync.packet(Lync.empty()),

	Profile = Lync.packet(Lync.struct({
		Coins = Lync.vlq(),
		AutoSkill = Lync.bool(),
	})),

	Inventory = Lync.packet(Lync.struct({
		Pets = Lync.array(Lync.struct({
			Uid = Lync.vlq(),
			Pet = ContentId,
			Level = Lync.int(1, 1000),
			Stars = Lync.int(1, 10),
		}), 0, 500),
		Equipped = Lync.array(Lync.vlq(), 0, 8),
	})),

	Reward = Lync.packet(Lync.struct({
		Enemy = Lync.vlq(),
		Coins = Lync.vlq(),
	})),

	Enemies = Lync.replicate(Lync.struct({
		Enemy = ContentId,
		Position = Lync.vec3(),
		Yaw = Lync.int(0, 359),
		Health = Lync.vlq(),
		MaxHealth = Lync.vlq(),
		Alive = Lync.bool(),
		Life = Lync.vlq(),
	})),

	Pets = Lync.replicate(Lync.struct({
		Owner = Lync.vli(),
		Slot = Lync.int(1, 8),
		Pet = ContentId,
		Target = Lync.optional(Lync.vlq()),
		Ring = Lync.int(0, 63),
		SkillReadyAt = Lync.f64(),
	})),

	Attack = Lync.packet(Lync.struct({
		Enemy = Lync.vlq(),
	})),

	Recall = Lync.packet(Lync.empty()),

	UseSkill = Lync.packet(Lync.struct({
		Unit = Lync.vlq(),
	})),

	SetAutoSkill = Lync.packet(Lync.struct({
		Enabled = Lync.bool(),
	})),

	Beat = Lync.packet(Lync.struct({
		Unit = Lync.vlq(),
		Move = Lync.enum({ "Enter", "Combat1", "Combat2", "Skill", "BackOff" }),
	})):timestamped(),

	Hits = Lync.packet(Lync.array(Lync.struct({
		Enemy = Lync.vlq(),
		Unit = Lync.vlq(),
		Amount = Lync.vlq(),
		Kind = Lync.enum({ "Basic", "Skill" }),
	}), 1, 255)),
})
```

Pontos a confirmar no Studio no passo 1 (o schema só é validado em runtime, dentro de `Lync.start()`):

- assinatura exata de `Lync.vec3()` sem argumento (precisão padrão) e de `:timestamped()` encadeado no `packet`;
- set com campo `optional` aceita `update` com `Lync.none` para limpar (`Target` → sem alvo);
- `:timestamped()` funciona com `fireClient` (não só com broadcast) — `Beat` agora é privado.

Se algum falhar, a alternativa já está indicada na entrada correspondente.

---

## Entradas

### `Ready` (mantém)

Sem mudança. Handshake da aplicação (README, "O handshake Ready").

### `Profile` — packet privado, S → C (muda schema)

```
{ Coins: vlq, AutoSkill: bool }
```

- **Por que packet:** dado privado do jogador (README: privado por construção com `fireClient`).
- **Por que muda:** `Level` e `Playtime` saem do Template (PT-08, `data.md`). `Coins` vira `vlq` porque
  `int(0, 2^31-1)` estoura cedo num simulador; `vlq` é exato até 2^53 e custa 1–8 bytes.
- **`AutoSkill` aqui e não num packet próprio:** é 1 bit, muda raramente e é estado do perfil (DEC-022).
  O client precisa dele no join (para desenhar o anel verde e bloquear o toque) e depois de cada
  `SetAutoSkill`. Junto com `Coins` custa 1 byte a mais por kill — irrelevante — e evita um effect e um
  packet extras.
- **`AutoSkill` não vai no set `Pets`:** é por jogador, não por pet, e só o dono precisa.
- **Quem escreve:** `ProfileService`, num `effect` do Charm que lê `Coins` e `AutoSkill`. Outro effect
  cuida do `Inventory`. Uma kill não reenvia a lista de pets.
- **Frequência:** a cada mudança; Charm junta escritas do mesmo `batch`. Mais o reenvio no `ClientReady`.

### `Inventory` — packet privado, S → C (nova)

```
{ Pets: { { Uid: vlq, Pet: str, Level: int 1..1000, Stars: int 1..10 } } (0..500), Equipped: { vlq } (0..8) }
```

- **Por que packet e não set:** é privado. Um set exigiria `keyBy` por jogador, que o Lync recusa.
- **Por que separado do `Profile`:** muda raramente e é grande (até ~500 pets × ~12 bytes ≈ 6 KB no pior caso).
- **Envio completo, não delta:** a lista só muda por ação do jogador — frequência baixa; envio completo é
  simples e não dessincroniza. Revisar se o limite de inventário passar de 500 (Q-021).
- **`Xp` e `Gear` do `OwnedPet` (PT-20) não viajam no v0.** Quando XP/equipamentos entrarem, o struct
  ganha `Xp = Lync.vlq()` e `Gear = Lync.array(...)`; mudança de schema só no Net, sem migração de perfil.
- **Frequência:** join + cada mudança em `Pets`/`Equipped`.

### `Reward` — packet privado, S → C (nova)

```
{ Enemy: vlq, Coins: vlq }
```

- Evento "+N moedas" para o popup (DEC-021, A17). O saldo de verdade vem do `Profile`; `Reward` é só
  apresentação.
- Um por jogador com dano > 0 a cada morte de inimigo.
- **Extensão futura** (DEC-026/027): `PetXp = Lync.vlq()` e `Drops = Lync.array(Lync.struct({ Item = ContentId, Count = Lync.vlq() }), 0, 16)`.

### `Enemies` — set, S → todos (nova)

```
id = Uid do inimigo (inteiro crescente, alocado pelo EnemyService)
{ Enemy: str (ENM-###), Position: vec3, Yaw: int 0..359, Health: vlq, MaxHealth: vlq, Alive: bool, Life: vlq }
```

- **Por que set:** estado que todos veem (inimigo compartilhado, DEC-011) e que quem chega depois precisa
  receber pronto. Só `Health` viaja durante o combate.
- **Vida é uma só para todos os jogadores** (A19): vários Engagements somam dano no mesmo `EnemySpawn`;
  o set reflete o agregado. A coreografia é local de cada client, a vida não.
- **`Position`/`Yaw` no record:** a Part de spawn pode não estar no client (StreamingEnabled). Mudam só no `add`.
- **`Alive` + `Life` em vez de remove/add:** a morte é uma transição (anima `Death`, depois `Spawn`).
- **`keyBy`:** nenhum no v0 (uma ilha). Jogo completo com várias ilhas: campo `Island = Lync.int(1, 63)` +
  `keyBy("Island")` + `audience(island, grupoDaIlha)`.
- **Quem escreve:** `EnemySpawn` (Component) — `add` no `OnInit`, `update` no dano/morte/respawn, `remove`
  no `OnDestroy`.
- **Frequência:** no máximo 20 `update` de `Health` por segundo por inimigo apanhando, qualquer que seja o
  número de jogadores (várias escritas no mesmo flush viram uma).

### `Pets` — set, S → todos (nova)

```
id = Id da unidade (inteiro crescente, alocado pelo PetService; nunca o UserId)
{ Owner: vli (UserId), Slot: int 1..8, Pet: str (PET-###), Target: vlq?, Ring: int 0..63, SkillReadyAt: f64 }
```

- **Por que set:** todo client desenha os pets de todos os jogadores, e quem chega depois precisa da lista atual.
- **Sem posição** (PT-05): o client deriva a posição de `Owner` ou de `Target` + `Ring`.
- **Basta para os pets dos outros** (PT-19): `Target` + `Ring` dizem onde ficar e que estão em combate
  (→ `Assist` em loop). Nenhum dado de coreografia alheia trafega.
- **`Owner` como `vli`:** jogadores de teste do Studio têm UserId negativo.
- **`Ring` vindo do servidor:** anel é por inimigo, com unidades de vários jogadores; o servidor aloca
  para ninguém se sobrepor.
- **`SkillReadyAt` (relógio do servidor):** o `PetSlot` do dono desenha o cooldown sem pacote extra e o
  `CommandController` sabe se pode mandar `UseSkill`. Muda uma vez por skill. Fica no set (e não num packet
  privado) porque já é o registro da unidade e custa ~10 B por skill; os outros clients ignoram.
- **Quem escreve:** `PetService` (add/remove na entrada/saída e ao equipar). `CombatService` muda `Target`,
  `Ring` e `SkillReadyAt` chamando `PetService:SetTarget`/`SetSkillReady` — um dono só por set.

### `Attack` — packet, C → S (nova)

```
{ Enemy: vlq }
```

- Pedido, não ordem: o servidor valida (inimigo existe e vivo, personagem vivo, alcance
  `CommandRange`, rate limit). Inválido → ignorado em silêncio.
- Mesmo alvo atual → `Recall` (toggle, Q-030 Provisório), decidido no servidor.

### `Recall` — packet, C → S (nova)

Sem payload. Recolhe todas as unidades do jogador e limpa a fila de skills. Rate limit compartilhado.

### `UseSkill` — packet, C → S (nova, PT-16)

```
{ Unit: vlq }
```

- **Por que um packet por pet:** DEC-022 — o jogador toca no slot de um pet específico. Mandar só o `Unit`
  é a intenção mínima; nada de número de dano ou cooldown sai do client.
- **Validação no servidor** (`architecture.md` 5.4): remetente é o `Owner` da unidade; unidade existe
  (= equipada); `AutoSkill` do remetente é `false`; `now ≥ SkillReadyAt`; unidade com alvo vivo e já
  chegada; ainda não está na fila; rate limit. Falhou → ignora em silêncio.
- **Sem resposta:** sucesso aparece como mudança de `SkillReadyAt` no set `Pets` + beat `Skill`. O client
  mostra "pedido enviado" localmente por até `Tuning.SkillRequestTimeout`.
- **Por que não `Lync.inst` ou `Slot`:** `Slot` exigiria o servidor traduzir slot → unidade e abre corrida
  quando o equipamento mudar; o `Unit` já é o id do set que o client tem.
- **Frequência:** humano tocando — ≤ 1 por pet a cada cooldown (8 s Provisório) em uso normal; o rate limit
  corta spam.

### `SetAutoSkill` — packet, C → S (nova, PT-16)

```
{ Enabled: bool }
```

- **Por que valor e não "toggle" vazio:** idempotente. Dois toques rápidos com perda de ordem ou reenvio
  não invertem o estado errado; o client manda o estado que quer.
- O servidor grava em `profile.AutoSkill` (persistido quando `PersistProfiles` ligar) e o `Profile`
  devolve o valor oficial. A HUD mostra o valor otimista até o `Profile` chegar.
- Ligar com skills prontas: o próximo tick enfileira todas em ordem de slot e o `SkillGap` espaça (DEC-022).
- **Frequência:** rara; rate limit compartilhado.

### `Beat` — packet `:timestamped()`, S → C privado (muda, PT-18)

```
{ Unit: vlq, Move: enum Enter | Combat1 | Combat2 | Skill | BackOff }   + sent (relógio do servidor)
```

- **Por que privado (`fireClient` para o dono):** a coreografia é por jogador (DEC-023). Os outros clients
  não tocam a sequência alheia (PT-19), então mandar para todos seria tráfego jogado fora — e, pior,
  tentação de animar o inimigo por dois roteiros ao mesmo tempo.
- **Sem `Enemy`:** o client acha o alvo pelo `Target` da unidade no set `Pets`. Um campo a menos.
- **Por que `timestamped`:** o client faz *seek* de `GetServerTimeNow() - sent` e casa a animação com o
  `HitDelay` da skill calculado no servidor.
- **Por que reliable e ordenado:** um `Skill` perdido deixaria um combo tocando por cima de uma skill; um
  `BackOff` perdido deixaria o pet parado na frente do inimigo.
- **Sem `Duration` no payload:** sai dos dados (`AnimationSet`).
- **Sem `Assist`:** `Assist` é estado derivado no client (unidade com alvo e fora de cena), não evento.
- **Alternativa se `:timestamped()` não aceitar `fireClient`:** adicionar `At = Lync.f64()` no struct com
  `GetServerTimeNow()` do servidor.
- **Frequência:** por jogador engajado, um turno a cada ~2–3 s ≈ 1,5–2 beats/s, mais 2 por skill
  (`Skill` + `BackOff`).

### `Hits` — packet (array), S → C privado do dono (nova; PT-22)

```
{ { Enemy: vlq, Unit: vlq, Amount: vlq, Kind: enum Basic | Skill } } (1..255)
```

- **Por que packet:** evento puramente visual (número subindo). O estado (vida) já vem por `Enemies`.
- **Por que privado (`fireClient` para o dono, como `Beat`):** FEAT-024 "No v0": cada jogador vê só os
  próprios números (PT-22). Mandar para todos e filtrar no client gastaria banda à toa. Quem mais luta no
  inimigo aparece pela vida (`Enemies`) e pelos pets em `Assist` no anel (`Pets`).
- **Por que array por tick:** o `CombatService` junta os hits do tick **por jogador** (o Engagement já é
  por jogador, PT-17) num fire só para ele; só dispara se houver hit.
- Se Q-037 pedir os números dos outros: volta a ser broadcast para a `Audience` com o mesmo schema, e o
  client pinta os alheios em cor neutra (o `Unit` resolve o dono pelo set `Pets`).
- **Por que não `unreliable`:** o limite de 1000 bytes do modo unreliable estoura no pior caso (255 × ~10 B).
- **`Unit` e não `Owner`:** o client sabe que são seus; `Unit` diz de qual pet (e mantém o schema pronto
  para broadcast).
- Acima de 255 hits num tick (impossível no teto proposto: 96 unidades), o excedente vai no tick seguinte.

---

## Orçamento de banda (pior caso do jogo completo)

Premissas: 12 jogadores, 8 pets cada (96 unidades), 12 inimigos apanhando ao mesmo tempo (um por jogador),
`AttackInterval` 1 s, skill a cada 8 s por pet. Custos aproximados por record/hit, cabeçalhos incluídos.

| Entrada | Conta | Por client |
|---|---|---|
| `Enemies` (Health) | 12 inimigos × 20 Hz × ~8 B | ~1,9 KB/s |
| `Hits` | só o próprio: (8 + 1 skill/s) × ~10 B | ~0,1 KB/s |
| `Beat` | só o próprio: (2 + 2) × ~6 B | < 0,1 KB/s |
| `Pets` (`SkillReadyAt`) | 12/s × ~10 B | ~0,1 KB/s |
| `Profile` + `Reward` + comandos | ~1 por kill | desprezível |
| **Total** | | **≈ 2,2 KB/s** (≈ 2,4 KB/s se `AttackInterval` cair para 0,5 s) |

Beat e Hits privados reduzem o custo de coreografia e de números de O(jogadores) para O(1) por client. O orçamento do Lync é
32 KB/s por client. Se apertar, a primeira alavanca é reduzir o `update` de `Health` para 10 Hz (a barra de
vida interpola).

## Segurança

- Nenhum pacote do client carrega número de dano, cooldown, posição ou dinheiro. Só intenção (`Attack`,
  `Recall`, `UseSkill { Unit }`, `SetAutoSkill { Enabled }`).
- `UseSkill.Unit` de outro jogador, inexistente, em cooldown ou sem alvo → ignorado.
- Com `AutoSkill` ligado, `UseSkill` é ignorado no servidor (o client já bloqueia o toque; o servidor não
  confia nisso).
- Rate limit por jogador no `CombatService` (`Tuning.CommandMinInterval`) para todos os comandos.

## Depois do v0 (não entra agora)

| Entrada | Tipo | Para quê |
|---|---|---|
| `Equip` | packet C → S `{ Uid: vlq, Equip: bool }` | inventário funcional (FEAT-012) |
| `OpenEgg` | packet C → S `{ Egg: str }` + `EggResult` S → C | ovos (FEAT-005) |
| `Island` em `Enemies`/`Pets` + `keyBy` | set | várias ilhas (FEAT-001) |
| `SkillCast` | packet S → todos `{ Unit: vlq }` | só se Q-037 pedir ver skills dos outros jogadores |
| `Items` | packet S → C privado (lista de itens/materiais) | equipamentos, gemas, pó estelar (FEAT-030/031) |
| `EquipGear` | packet C → S `{ Pet: vlq, Slot: enum, Item: vlq? }` | equipamento por slot de pet (FEAT-030, Q-038) |
| `Missions` | packet S → C privado + `ClaimMission` C → S | missões (FEAT-029, Q-040) |
