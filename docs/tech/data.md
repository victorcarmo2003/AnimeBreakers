# Dados do jogador — perfil v0

Status: Rascunho

Autor: `architect`. Afeta `src/Profile/server/ProfileService/` (`Template.luau`, `init.luau`, novo
`Migrations.luau`) e `src/Profile/client/ProfileController.luau`. Base: seção "Estado reativo" do `README.md`.

Revisão 2 (2026-10-03): `AutoSkill` no perfil (DEC-022); `OwnedPet` ganha `Xp` e `Gear` sem uso no v0
(PT-20); campos futuros de itens, materiais e missões detalhados (DEC-026, DEC-027).

## Princípios

- **O Template é o tipo.** `Atomic.Table<typeof(Template)>` gera um atom tipado por campo de topo. Campo
  novo no Template vira atom sem tocar em mais nada.
- **Campo de topo = unidade de reatividade e de replicação.** Tabelas (`Pets`, `Equipped`) são um atom só;
  mudar um pet troca a tabela inteira.
- **Atom de tabela é imutável.** Charm só notifica se a referência mudar. Toda mudança em `Pets`/`Equipped`
  clona, altera e grava (`profile.Pets(novo)`).
- **Regra de domínio fica no serviço do domínio.** `ProfileService` continua genérico (`Get`, `Update`,
  replicação, sessão). Quem sabe o que é "adicionar pet" é o `PetService`; quem credita moeda é o
  `EconomyService`; quem interpreta `AutoSkill` é o `CombatService`.
- **Forma aninhada nasce completa.** `Reconcile` do ProfileStore só preenche chaves que existem no Template.
  Como `Pets` é um dicionário vazio no Template, campos novos **dentro** de cada `OwnedPet` não são
  preenchidos sozinhos — exigiriam migração. Por isso `OwnedPet` já nasce com os campos que o design
  futuro confirmou (PT-20). Campos de topo novos não têm esse problema.

## Template v0

```lua
export type OwnedPet = {
	Pet: string,
	Level: number,
	Stars: number,
	Xp: number,
	Gear: { [string]: number },
}

return {
	Version = 1,
	Coins = 0,
	AutoSkill = true,
	Pets = {} :: { [string]: OwnedPet },
	Equipped = {} :: { string },
	NextPetUid = 1,
	EquipSlots = 3,
}
```

(Esboço de contrato; no arquivo real o `export type` fica no `Template.luau` e o `init.luau` reexporta.)

| Campo | Tipo | v0 | Provisório? | Notas |
|---|---|---|---|---|
| `Version` | number | 1 | não | versão do formato; ver "Migração" |
| `Coins` | number | 0 | valor inicial sim | moeda principal (FEAT-004, DEC-021). Reaproveita o campo existente (PT-08). Inteiro; teto prático 2^53 (`vlq` na rede) |
| `AutoSkill` | boolean | `true` | sim (DEC-022: "estado inicial ligado") | toggle de uso automático de skills. Gravado pelo `CombatService` ao receber `SetAutoSkill`; lido no tick. Persistir é aceitável (pedido do usuário): fica salvo quando `PersistProfiles` ligar |
| `Pets` | `{ [uid]: OwnedPet }` | 3 pets iniciais | sim (StarterPets) | chave = `tostring(uid)`: DataStore serializa em JSON, e dicionário com chave numérica esparsa vira problema |
| `Equipped` | `{ uid }` | os 3 iniciais | sim (Q-008) | ordem = `Slot` da unidade (1..n) |
| `NextPetUid` | number | 1 | não | contador por jogador; uid nunca reaproveitado |
| `EquipSlots` | number | 3 | sim (Q-008) | teto de `Equipped` |

Por que `AutoSkill` é campo de topo e não parte de um `Settings`: vira atom próprio, e o effect de
replicação do `Profile` e o tick do combate leem só ele. Dentro de `Settings` (tabela), qualquer mudança
de configuração re-rodaria o tick-reader e reenviaria tudo. Se um `Settings` existir no futuro
(`Music`, `Vfx`), ele fica separado.

`OwnedPet`:

| Campo | v0 | Notas |
|---|---|---|
| `Pet` | `"PET-001"` | chave em `Content.Pets` |
| `Level` | 1 | FEAT-009, sem uso no v0 (multiplicador = 1) |
| `Stars` | 1 | FEAT-011, sem uso no v0 (multiplicador = 1) |
| `Xp` | 0 | FEAT-009 / DEC-027: pets ganham XP lutando. Sem uso no v0. XP acumulada no level atual; curva em `Content` (Q-009) |
| `Gear` | `{}` | FEAT-030 / DEC-027: chave = slot de equipamento (`"Weapon"`, `"Charm"`, ... — Q-038), valor = uid do item em `Items` (campo futuro). Sem uso no v0 |

Saem do Template atual: `Level` (nível de jogador não existe no design) e `Playtime` (nunca era
incrementado). Como o v0 roda em Mock e nada foi salvo em produção, não precisa de migração para isso.

### Pets iniciais (v0)

`PetService`, no `ProfileService.Loaded`: se `Pets` estiver vazio, concede `Content.Tuning.StarterPets`
(Provisório: os 3 pets placeholder) com `Level = 1`, `Stars = 1`, `Xp = 0`, `Gear = {}` e preenche
`Equipped`, num único `ProfileService:Update` (um `batch`, uma replicação). Um construtor único
`NewOwnedPet(petId)` no `PetService` é o lugar de criar `OwnedPet` — ovo, recompensa e migração futuros
usam o mesmo.

## Persistência no v0: Mock (PT-09)

- O código usa o mesmo `ProfileService`, mas abre a sessão em `Store.Mock` (API idêntica do ProfileStore,
  sem gravar no DataStore). Cada sessão começa do Template — inclusive `AutoSkill = true`.
- Flag única em `Content.Tuning.PersistProfiles` (v0: `false`). Ligar persistência = trocar para `true`.
- O caminho real (sessão, reconcile, migração, replicação) é exercitado desde o v0.

## Mudanças necessárias no `ProfileService`

1. **Replicação dividida.**
   - effect de persistência: lê todos os atoms e copia para `session.Data` (como hoje, sem replicar);
   - effect `Profile`: lê `Coins` e `AutoSkill` → `Net.Profile:fireClient`;
   - effect `Inventory`: lê `Pets` + `Equipped` → monta o array do `Inventory` → `fireClient`.
   Charm rastreia dependência por leitura, então uma kill só re-roda o effect do `Profile`.
   `Replicate(player)` (chamado no `ClientReady`) manda os dois.
2. **`Bind` itera as chaves do Template, não de `session.Data`.** Campo obsoleto salvo não vira atom fantasma.
3. **`Mutate(player, field, fn)`**: clona a tabela do campo, aplica `fn(cópia)`, grava.
4. **Migração** antes do `Reconcile` (abaixo).
5. **Mock** pela flag.

## Migração de versão

Arquivo `src/Profile/server/ProfileService/Migrations.luau`: lista ordenada, índice = versão de destino.

```
Migrations[2] = function(data) ... end   transforma dados da versão 1 em 2
Migrations[3] = function(data) ... end   2 → 3
```

Ordem no `Load`, depois de `StartSessionAsync`:

1. `data.Version` ausente → trata como 1 (perfil anterior ao campo).
2. Para `v = data.Version + 1` até `CURRENT_VERSION`: `Migrations[v](data)`, `data.Version = v`.
3. `session:Reconcile()` — preenche campos de topo novos com o valor do Template.
4. `Bind`.

Regras:

- **Só adicionar campo de topo não precisa de migração**: `Reconcile` cobre (ex.: `Items`, `Materials`,
  `Missions` do futuro).
- **Adicionar campo dentro de `OwnedPet` precisa** (Reconcile não entra em dicionário de pets). Por isso
  `Xp`/`Gear` já nascem no v0. Se surgir outro, a migração é um laço simples preenchendo o padrão.
- **Renomear, mudar tipo, mudar forma, apagar campo** precisa de migração, que também apaga a chave velha.
- Migração é **pura e idempotente**, não faz yield, não lê outro serviço.
- Migração nunca é apagada nem renumerada (mesma regra dos IDs do `CLAUDE.md`).
- Perfil com `Version > CURRENT_VERSION` (servidor velho abrindo dado novo): kick com mensagem
  "atualizando, entre de novo" e **não** grava.
- Cada migração ganha um caso de teste no plano do `qa-tester` (dado de entrada → dado esperado).

## Campos previstos para o jogo completo (não entram no v0)

Listados para o `task-planner` não ser surpreendido; cada um entra por decisão própria. Todos são de
topo, então entram por `Reconcile`, sem migração.

| Campo | Tipo provável | Feature | Pergunta |
|---|---|---|---|
| `Items` | `{ [itemUid]: { Item: string, Level: number? } }` | equipamentos de pet (FEAT-030, DEC-027) | Q-038 |
| `NextItemUid` | number | FEAT-030 | — |
| `Materials` | `{ [materialId]: number }` (gemas, pó estelar, itens de upgrade/merge) | FEAT-031, DEC-026 | Q-039 |
| `Missions` | `{ [missionId]: { Progress: number, Claimed: boolean } }` + `MissionTier: number` | FEAT-029, DEC-027 | Q-040 |
| `UnlockedIslands` | `{ [islandId]: true }` | FEAT-013 | Q-013 |
| `InventoryLimit` | number | FEAT-012 | Q-021 |
| `Rebirths` | number | — | Q-014 |
| `Purchases` | `{ [receiptId]: true }` (idempotência de developer product) | FEAT-018 | Q-015 |
| `Settings` | `{ Music: boolean, Vfx: "Full" \| "Lite" }` | FEAT-017 | — |
| `Stats` | totais (kills, bosses, ovos abertos) — alimenta missões | analytics, FEAT-029 | — |

Notas de forma:

- **Item é instância com uid** (como pet), não contador: equipamento pode ter level/raridade própria e ir
  para um slot de um pet específico (`OwnedPet.Gear[slot] = itemUid`). Material (gema, pó) é **contador**
  em `Materials`: não tem identidade.
- **Um item equipado não sai de `Items`**: `Gear` só aponta. Vender/fundir pet devolve os itens apontados
  (regra no serviço do domínio, não no Profile).
- **Missões guardam só progresso**; a definição (objetivo, boss exigido, recompensa) fica em
  `Content.Missions` (`content-data.md`).

Trading (Q-016) exigiria uid de pet/item global (não por jogador); se Q-016 for "sim", `NextPetUid` e
`NextItemUid` viram `"<UserId>-<n>"` com migração.

## Lado do client (`ProfileController`)

| Source | Tipo | Vem de |
|---|---|---|
| `Coins` | `Vide.Source<number>` | `Profile` |
| `AutoSkill` | `Vide.Source<boolean>` | `Profile` (o `CommandController` escreve otimista ao tocar no toggle; o próximo `Profile` corrige) |
| `Pets` | `Vide.Source<{ InventoryEntry }>` | `Inventory` |
| `Equipped` | `Vide.Source<{ number }>` | `Inventory` |
| `Ready` | `Vide.Source<boolean>` | primeiro `Profile` recebido |
| `LastReward` | `Vide.Source<{ Enemy, Coins }?>` | `Reward` (popup da HUD) |

Some `Level` e `Playtime`.
