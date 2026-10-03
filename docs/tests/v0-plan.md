# Plano de teste — Protótipo de apresentação (v0)

Status: Rascunho

Autor: `qa-tester` (TASK-027). Executado por TASK-028 (núcleo servidor) e TASK-029 (completo).
Fontes: DEC-013 (A1–A13), DEC-016, DEC-018 (A10), DEC-020 (A15, A16), DEC-021 (A17), DEC-022 (A9, A14),
DEC-023 (A18, A19), DEC-024, DEC-028; `design/features.md` (FEAT-002, 004, 006, 007, 015, 020–025);
`tech/architecture.md` (Revisão 3: PT-21 a PT-25), `tech/network.md` (Revisão 3), `tech/data.md`,
`tech/content-data.md`; `tasks/board.md`.

Valores usados nos casos (todos **Provisórios**, `content-data.md`): `ENM-001` vida 1000, `Rewards.Coins`
100, respawn 5 s; 3 pets `PET-001..003`, dano 10 a cada 1,0 s; `ABL-001` Power 5 (= 50), `HitDelay` 0,4 s,
`Cooldown` 8 s; `Tuning`: `ArriveSeconds` 0,4, `SkillGap` 0,3, `CommandMinInterval` 0,1, `CommandRange` 80,
`LeashRange` 120, `SkillRequestTimeout` 1, `AssistDistance` 6, `TeleportThreshold` 25,
`DamageNumbers = { PerEnemy 10, Total 40, Rise 2, Lifetime 0,8 }`, `MaxSkillEffects` 6, `StarterPets` 3,
`PersistProfiles = false`, `AutoSkill` inicial `true`. Se o `Tuning` mudar, os números esperados mudam
junto; o caso cita o campo, não só o número.

---

## 1. Como usar

| Tipo | Sigla | Como roda |
|---|---|---|
| Estático | **E** | leitura de código, grep, `modux check`, `tools/analyze.ps1` |
| Servidor | **S** | Studio, Test > Clients and Servers, janela do **Server**, Command Bar com `ServerStorage.Dev:Invoke` (PT-25) |
| Manual 1 jogador | **M1** | Play (F5) ou Clients and Servers com 1 client |
| Manual 2+ jogadores | **M2** | Test > Clients and Servers, **2 players** (e 3 quando indicado), servidor local |
| Mobile | **MB** | Studio > Device Emulator (perfil de celular, toque) e, se houver, dispositivo real |

Evidência obrigatória por caso executado (TASK-029 critério 1): print ou vídeo curto + trecho do Output
(servidor e cada client). Resultado: `Passou` / `Falhou` / `Bloqueado` (dependência externa).

Acesso pelo Command Bar do servidor (`architecture.md` 4.6, PT-25): `DevService` cria
`ServerStorage.Dev` (`BindableFunction`) só com `RunService:IsStudio()`. Jogador é passado por **nome**;
retorno é tabela simples; erro do handler volta como `false, mensagem`. Abreviação usada nos casos:
`Dev(...)` = `print(game.ServerStorage.Dev:Invoke(...))`.

| Comando | Entregue por | Retorno / efeito |
|---|---|---|
| `Enemies()` | TASK-006 | `{ Uid, EnemyId, Health, MaxHealth, Alive, Life }` |
| `Damage(uid, amount, playerName)` | TASK-006 | dano aplicado (após overkill) |
| `Kill(uid, playerName)` | TASK-006 | mata creditando o restante ao jogador |
| `Ledger(uid)` | TASK-006 | `{ Name, Damage, Present }` + `Total` |
| `Coins(playerName)` / `SetCoins(playerName, n)` | TASK-014 | saldo do `Profile` |
| `LastPayout(uid)` | TASK-014 | `{ Name, Damage, Present, Share }` da última morte |
| `Units(playerName)` | TASK-015 | `{ Id, Slot, PetId, Target, Ring, ArriveAt, NextHitAt, SkillReadyAt }` |
| `Engagement(playerName)` | TASK-015 (+019) | `{ EnemyUid, Phase, Featured }` (+ `Queue`, `LastCastAt`, `PendingHits`) |
| `FireAs(playerName, packet, payload)` | TASK-015 (`Attack`, `Recall`), TASK-019 (`UseSkill`, `SetAutoSkill`) | chama o mesmo `Handle*` do responder Lync (mesma validação e rate limit) |
| `SetSkillReady(playerName, unitId, at)` | TASK-019 | força `SkillReadyAt` |

Saída de jogador: fechar a janela do client ou `game.Players.Player2:Kick()` no Command Bar do servidor.
Verificação estática extra (E, TASK-006): fora do Studio `Dev` não existe (`DevService` sem `IsStudio` →
nada criado, `Register` no-op); nenhum service de jogo requer `DevService`; nenhum packet Lync novo para
dev. Comando ausente na task de origem → caso **S** vira **Bloqueado** e a falha vai para a task.

Simular client mal-intencionado (pacote forjado): no Command Bar do **client** (janela do Player1),
requerer `ReplicatedStorage.shared.Libs.Net` (ou o caminho real do `src/Libs/Net` após `rogen build`) e
chamar `Net.UseSkill:fire({ Unit = n })`, `Net.Attack:fire({ Enemy = n })` etc. diretamente, sem passar
pelo `CommandController`. O que vale é o efeito no servidor (set `Pets`, `Hits`, vida, `Profile`).

---

## 2. Checklist estática por task (DoD-C)

Rodar em **toda** task de código antes de `Feito`. Qualquer item falho = `Falhou` com arquivo:linha.

| # | Verificação | Comando / método | Esperado |
|---|---|---|---|
| E1 | Zero comentários nos `.luau`/`.lua` tocados | `rg -n --glob '*.luau' --glob '*.lua' --glob '!src/Modux/**' --glob '!Packages/**' -e '--' src` e depois descartar ocorrências dentro de string (revisar cada linha à mão; o hook `.claude/hooks/no-comments.js` é a referência do que é "fora de string") | nenhum `--`, `--[[`, `TODO`, docstring fora de string |
| E2 | Sem diretiva de modo | `rg -n -e '--!strict' -e '--!nonstrict' -e '--!nocheck' src --glob '!src/Modux/**'` | vazio |
| E3 | Build | `rogen build` → `modux generate` | sem erro |
| E4 | Gerados atualizados | `modux check` | 0 |
| E5 | Análise | `powershell tools/analyze.ps1 -Detail` | 0 erros, 0 ciclos |
| E6 | Nada editado em `src/Modux` nem gerados | `git diff --name-only` sem `src/Modux/**`, `*/Manifest/init.luau`, `*/Modules.luau`, `shared/Libs.luau` (exceto regeneração pelo `modux generate`) | ok |
| E7 | Responder só em `OnInit` de Service/Controller | `rg -n '\.listen\|:listen\|\.on\(' src --glob '!src/Modux/**'` e conferir que cada um está em `OnInit` de Service/Controller; nenhum em Component (`EnemySpawn`) | ok |
| E8 | Charm no servidor, Vide no client; Lync/Vide requeridos direto | `rg -n 'Vide' src/*/server`, `rg -n 'Charm' src/*/client` vazios; nenhum `src/Libs/Vide` ou `src/Libs/Lync` | ok |
| E9 | Transmissão S→todos só para `NetService.Audience` | `rg -n 'Lync.all' src` vazio | ok |
| E10 | Escopo da task | arquivos do diff ⊆ coluna "Toca" do board | ok |
| E11 | Nenhum número de dano/cooldown/dinheiro/posição sai do client | ler os `fire` de `CommandController`: só `Attack{Enemy}`, `Recall`, `UseSkill{Unit}`, `SetAutoSkill{Enabled}` | ok |
| E12 | Sem IP de anime e sem asset sem licença | nomes em `Content/*`, `assets/roblox/*`; `docs/art/credits.md` para terceiros | ok |
| E13 | Commit | `feat:`/`fix:`/`refactor:`/`docs:`/`chore:`, inglês, sem menção a IA/ferramenta | ok |
| E14 | IDs de imagem só em `Content/Interface.luau` | `rg -n 'rbxassetid' src --glob '!src/Shared/Content/**'` vazio | ok |
| E15 | Asset/animação só por dados (base de A13) | `rg -n 'FindFirstChild\("(Left\|Right) (Arm\|Leg)\|Torso\|Head' src` vazio; nenhum `rbxassetid` de animação fora de `AnimationSets.luau` | ok |

Observação: E1 por grep dá falso positivo em string (`"a--b"`) e o hook pode deixar passar comentário
gerado fora do Write/Edit (ex.: arquivo copiado). Por isso o grep roda sempre, e cada ocorrência é
conferida à mão.

---

## 3. Mapa critério → task

| Critério | Resumo (texto vigente) | Fonte | Entregue por | Validado em |
|---|---|---|---|---|
| A1 | inimigo nasce no spawn e fica parado | DEC-013 | TASK-006, TASK-007, TASK-011 | 028 (S), 029 |
| A2 | vida visível cai a cada acerto | DEC-013 | TASK-011 (+015 para acerto real) | 029 |
| A3 | vida 0 → some → renasce no mesmo spawn com vida cheia após respawn | DEC-013 | TASK-006, TASK-011 | 028 (S), 029 |
| A4 | toque/clique no inimigo → todos os pets vão e atacam (PC e mobile) | DEC-013 | TASK-015, TASK-016, TASK-017 | 029 |
| A5 | "parar" → pets param e voltam ao player | DEC-013, FEAT-021 | TASK-015, TASK-016, TASK-017, TASK-022 | 029 |
| A6 | dano calculado e aplicado no servidor | DEC-013 | TASK-006, TASK-015 | 028 (S), 029 |
| A7 | número de dano em BillboardGui por acerto, sobe e some; cada client só os próprios (PT-22) | DEC-013, FEAT-020, FEAT-024 | TASK-015, TASK-018 | 029 |
| A8 | animação de andar, ataque básico e habilidade | DEC-013 | TASK-008, TASK-016, TASK-020 | 029 |
| A9 | auto ligado: skill de cada pet sozinha ao fim do cooldown, dano maior; slots não respondem | DEC-022 (revisa DEC-016) | TASK-019, TASK-021, TASK-022 | 029 |
| A10 | 4 telas fiéis à referência, abrem/fecham por toque; HUD com ações reais | DEC-018 | TASK-013, 022, 023, 024, 025, 026 | 029 (+ usuário) |
| A11 | 2 jogadores no mesmo inimigo sem erro | DEC-013 | TASK-010, TASK-015 | 028 (S), 029 |
| A12 | mobile sem queda perceptível de FPS (1 inimigo + pets de 2 jogadores) | DEC-013 | TASK-016, 018, 020, 012, 030 | 029, refeito na 030 |
| A13 | trocar asset só por dados/arquivo | DEC-013 | TASK-003, 004, 007, 008, 011, 016 | 029 |
| A14 | auto desligado: toque no slot com skill pronta usa a skill daquele pet; slot em recarga não responde | DEC-022 (revisa DEC-016) | TASK-019, TASK-021, TASK-022 | 029 |
| A15 | 3 pets: vida cai pelo dano dos 3 juntos, 1 animação de combate por vez | DEC-020 | TASK-015, TASK-019, TASK-020 | 029 |
| A16 | skill interrompe a animação de combate em curso | DEC-020 | TASK-019, TASK-020 | 029 |
| A17 | morte soma dinheiro na HUD de cada jogador com dano, proporcional | DEC-021 | TASK-005, TASK-014, TASK-022 | 028 (S), 029 |
| A18 | 2 pets fora de cena em Assistência perto do alvo enquanto o principal coreografa | DEC-023 | TASK-016, TASK-020 | 029 |
| A19 | 2 jogadores: cada um vê a própria sequência, sem erro, mesma vida | DEC-023 | TASK-019, TASK-020 | 029 |

Textos revogados que **não** se testam mais: A9/A14 de DEC-016 (botão "forçar" todos os pets) — substituídos
por DEC-022. Qualquer resquício de `ForceSkills`/`ForceCooldown` no código é falha (E: `rg -n 'Force' src`).

---

## 4. Casos por critério

Formato: **Tipo** · **Pré-condição** · **Passos** · **Esperado** · **Bordas**.

### A1 — Inimigo nasce no spawn e fica parado

- Tipo: S + M1 + M2. Tasks: 006, 007, 011.
- Pré: mapa de dev com 1 Part `EnemySpawn` (`EnemyId = "ENM-001"`), anotar `CFrame` da Part.
- Passos:
  1. Start (Clients and Servers, 1 player). No Server: `Dev("Enemies")`.
  2. No client, conferir `Workspace.Visuals.Enemies` e a posição do modelo.
  3. Esperar 30 s sem interagir; medir o pivô do modelo no início e no fim.
- Esperado:
  - Record `{ Enemy = "ENM-001", Health = 1000, MaxHealth = 1000, Alive = true, Life = 1 }`; `Position` =
    centro da face de baixo da Part (± 0,01); `Yaw` = yaw do `LookVector` (0..359).
  - Modelo local com pivô (pé) em `Position`, olhando para o `LookVector`; não se move (pivô igual após 30 s).
  - Nenhum modelo de inimigo no servidor (`Workspace` do Server sem o rig; PT-01).
- Bordas:
  - `EnemyId = "ENM-999"` → `warn` no servidor, nenhum `add`, sem erro no client.
  - Part sem atributo `EnemyId` → `warn`, sem crash.
  - Part com atributo `RespawnSeconds = 2` → usado no A3 em vez de 5.
  - 3 Parts → 3 inimigos com `Uid` distintos e crescentes.
  - Jogador entra **depois** do boot (2º client entra 20 s depois): recebe o inimigo pronto pelo set.
  - Part apagada em runtime (Server) → `Enemies:remove`, modelo some no client, sem erro.

### A2 — Vida visível cai a cada acerto

- Tipo: M1 (+ S para dano isolado). Tasks: 011, 015.
- Passos:
  1. S: `Dev("Damage", 1, 100, "Player1")`. Observar a `HealthBar` do client.
  2. M1: atacar com os 3 pets; observar a barra por 5 s.
- Esperado: barra em `BillboardGui` acima do modelo (`CharacterDef.Height`) vai de 1000 para 900 no passo 1;
  no passo 2, cai a cada `Hits` (≈ 30/s com 3 pets). Valor mostrado = `Enemies.Health`.
- Bordas: dano > vida restante → barra em 0, nunca negativa; client com HUD/tela aberta continua vendo a barra.

### A3 — Morte, sumiço e respawn no mesmo spawn

- Tipo: S + M1. Tasks: 006, 011.
- Passos:
  1. S: `Dev("Kill", 1, "Player1")` (ou `Dev("Damage", 1, 1000, "Player1")`). Cronometrar pelo Output
     (timestamp do `Died` e do respawn) e repetir `Dev("Enemies")` / `Dev("Ledger", 1)` após o respawn.
  2. Client: observar `Death`, modelo some, `Spawn` no mesmo lugar.
  3. Repetir com `RespawnSeconds = 2` na Part.
- Esperado: `Alive = false` imediatamente; `Died(uid, ledger, def)` uma vez; após 5 s (± 1 tick): `Health = 1000`,
  `Alive = true`, `Life = 2`, ledger vazio, mesma `Position`/`Yaw`. Com atributo: 2 s.
- Bordas:
  - Dano no inimigo morto (`Dev("Damage", 1, 100, "Player1")` durante os 5 s) → aplicado 0, `Health` fica 0,
    ledger não muda.
  - `Attack` em inimigo morto → ignorado (ver A4).
  - Overkill: `Dev("Damage", 1, 5000, "Player1")` com vida 1000 → retorno 1000; `Ledger` `Total` = 1000.
  - Dois `Damage` no mesmo tick que zeram juntos → um só `Died`.
  - Jogador entra durante o respawn → vê o inimigo ausente (ou em `Death`) e depois o `Spawn`.

### A4 — Toque/clique no inimigo manda todos os pets atacar

- Tipo: M1 (PC) + MB (toque). Tasks: 015, 016, 017.
- Pré: personagem a < 80 studs do inimigo; `AutoSkill` qualquer.
- Passos:
  1. PC: clicar no inimigo sem arrastar.
  2. MB: tocar no inimigo no emulador.
  3. Arrastar a câmera começando sobre o inimigo (PC: botão esquerdo + mover > 6 px; MB: arrastar).
  4. Clicar em outro inimigo (mapa com 2 spawns) enquanto ataca o primeiro.
- Esperado:
  - 1/2: os 3 pets saem da formação e vão (corrida ou teleporte se > 25 studs) para o anel do alvo; `Target` e
    `Ring` atualizados no set `Pets`; dano começa ~0,4 s depois (`ArriveSeconds`).
  - 3: nenhum comando enviado.
  - 4: as 3 unidades trocam de alvo; o primeiro inimigo para de perder vida do jogador; `Queue` de skills limpa.
- Bordas:
  - Personagem a 100 studs (> `CommandRange`) → `Attack` ignorado; pets não saem.
  - Personagem morto (Humanoid.Health = 0) → `Attack` ignorado; pets congelam até o respawn do personagem.
  - Toque sobre botão da HUD por cima do inimigo → `processedByUI`, não comanda.
  - Com tela (Loja) aberta → contexto `Menu`, não comanda (TASK-026).
  - **Forjado**: `Net.Attack:fire({ Enemy = 999 })` (uid inexistente) e `Enemy` de inimigo morto → ignorados,
    sem erro no servidor. Repetir no servidor com `Dev("FireAs", "Player1", "Attack", { Enemy = 999 })` e
    conferir `Dev("Units", "Player1")` (`Target` inalterado).
  - **Spam**: 50 `Attack` em 1 s pelo Command Bar do client → servidor processa no máximo ~10 (1 a cada
    0,1 s), sem quebrar estado; sem erro no Output. `Dev("Engagement", "Player1")` coerente no fim.
  - Leash: depois de engajado, andar até > 120 studs do spawn → recall automático em ≤ 0,5 s.

### A5 — Comando "parar"

- Tipo: M1 + MB. Tasks: 015, 016, 017, 022.
- Passos:
  1. Engajar. Tocar de novo no **mesmo** inimigo.
  2. Engajar. Tocar no botão **Parar** da HUD (ou `CommandController:Recall()` pelo Command Bar do client
     enquanto a HUD não existe).
- Esperado: `Target = nil` nas 3 unidades (`Dev("Units", "Player1")`); `Dev("Engagement", "Player1")` vazio;
  vida do inimigo para de cair pelo jogador em ≤ 1 tick (nenhum `Hits` dele depois disso); pets voltam à
  formação; `Dev("Ledger", 1)` mantém o dano já causado (FEAT-021). `SkillReadyAt` **não** muda pelo recall
  (PT-23).
- Bordas:
  - Parar com skill em `HitDelay` (até 0,4 s após o cast, dano pendente) → `PendingHit` descartado: o número
    de skill **não** aparece e a vida não cai (TASK-019 critério 8). O cooldown dessa skill continua
    contando do cast (PT-23).
  - Parar durante `Enter`/`Combat1` → pet sai de cena; nenhum beat posterior ao `Recall` para o dono.
  - Parar sem estar engajado → nada acontece, sem erro.
  - **Spam** de `Recall` forjado (100 em 1 s) → sem erro; estado final consistente (sem alvo).
  - Parar e voltar a atacar em < 0,1 s → segundo comando pode ser descartado pelo rate limit (aceito).
  - Recall depois do dano: se o inimigo morrer pelas mãos de outro jogador, quem parou **ainda** recebe a
    parte pelo dano já causado (A17).

### A6 — Dano no servidor

- Tipo: E + S + M2. Tasks: 006, 015.
- Passos:
  1. E: `rg` em `src/*/client` por qualquer escrita em `Enemies`/`Health` ou envio de número; ver E11.
  2. M2: 2 clients, Player1 ataca. Comparar `HealthBar` nos dois clients e `Dev("Enemies")` a cada 1 s.
  3. Forjar no client: alterar localmente o texto/valor da barra ou destruir o modelo local; e tentar
     `Net.Enemies:update(...)` pelo client (deve não existir API de escrita no client).
- Esperado: os dois clients mostram o mesmo `Health` do servidor (± 1 flush); mudança local de um client não
  afeta servidor nem o outro client; não existe pacote C→S que carregue dano.
- Bordas: dano com 3 pets ≈ 30/s (10 × 3, `AttackInterval` 1 s) medido em 10 s → 300 ± 30.

### A7 — Números de dano

- Tipo: E + M1 + M2. Tasks: 015 (envio privado), 018 (exibição).
- Passos:
  1. E: no `CombatService`, `Hits` sai por `fireClient` para o dono, um fire por jogador por tick, só se houver
     hit dele; nenhum `Hits` para a `Audience`/`Lync.all`. No `DamageNumberController`, nenhum filtro por dono
     e nenhuma cor "neutra" (PT-22, `network.md` `Hits`).
  2. M1: atacar; filmar 5 s. Depois, com auto ligado, esperar uma skill.
  3. M2 (Clients and Servers, 2 players): P1 e P2 atacam o mesmo inimigo; filmar as duas janelas 10 s,
     incluindo skills de ambos.
- Esperado:
  - Um número por entrada de `Hits`, com o `Amount` certo (10 básico, 50 skill), acima do inimigo
    (`CharacterDef.Height`), subindo ~2 studs (`DamageNumbers.Rise`) em ~0,8 s (`Lifetime`) com fade e leve
    deslocamento horizontal; skill maior e com outra cor.
  - Número de skill sobe `HitDelay` (0,4 s) depois do beat `Skill` do pet, casado com o `Effect` no alvo (PT-24).
  - M2: a janela do P1 mostra **só** os números dos pets do P1; a do P2, só os do P2. A barra de vida cai pela
    soma nas duas janelas (vida é compartilhada, números não).
- Bordas:
  - Jogador só observando (3º client sem atacar) → nenhum número aparece para ele; barra de vida cai.
  - P2 sai no meio → números do P1 continuam, sem erro.
  - Limite (`DamageNumbers.PerEnemy` 10, `Total` 40): com só os próprios 3 pets o pico no v0 é ~6 números
    no ar (3 básicos + 3 skills em 0,8 s), então o teto não é atingido em jogo. Validar por leitura de código
    (E: recicla o mais antigo ao passar do limite) e, se quiser ver, baixar `PerEnemy` para 2 numa cópia
    local de `Tuning` (revertida) → no máximo 2 visíveis, o mais antigo some primeiro.
  - Inimigo morre com números no ar → números terminam ou somem, sem erro de instância destruída.
  - **Forjado/escuta**: no client do P2, conectar um listener extra em `Net.Hits` pelo Command Bar → não
    recebe nenhum `Hits` com `Unit` do P1.

### A8 — Animações de andar, ataque básico e habilidade

- Tipo: M1. Tasks: 008, 016, 020.
- Passos: andar com o personagem (pets seguindo); engajar; esperar uma skill (auto ligado).
- Esperado: `Run` quando o pet anda > 1 stud, `Idle` parado; no alvo: pet em cena toca `Enter` → `Combat1` →
  `Combat2` → `BackOff`; skill toca `Skill`; demais em `Assist`. Inimigo reage (`Defend`/`Hit`/`HitHeavy`).
- Bordas:
  - Animação placeholder sem permissão (dono diferente) → falha visível no Output ("Failed to load
    animation"): registrar como `Bloqueado` por Q-036, não como falha de código.
  - Beat atrasado (`late ≥ Duration`) → ignorado, sem pose travada (simular com Network > Incoming Replication
    Lag no Studio, 0,5–1 s).
  - Dono morre com pets em formação → pets congelam; ao respawn, voltam a seguir.

### A9 — Auto ligado: skill sozinha, dano maior, slots sem toque

- Tipo: M1 + S. Tasks: 019, 021, 022.
- Pré: `AutoSkill = true` (padrão ao entrar; conferir `Profile`). Regras: PT-23 (cooldown do cast, unidade
  nasce pronta) e PT-24 (dano `HitDelay` após o próprio cast, casts espaçados por `SkillGap`).
- Passos:
  1. Antes de engajar: `Dev("Units", "Player1")` → `SkillReadyAt = 0` nas 3.
  2. Engajar com 3 pets (instante `t0` = `Attack`). Logo após, `Dev("Engagement", "Player1")` várias vezes
     (`Queue`, `LastCastAt`, `PendingHits`) e `Dev("Units", "Player1")`; filmar a janela do client.
  3. Tocar nos 3 slots da HUD durante 20 s.
  4. Dar `Recall` aos ~3 s, reengajar o mesmo inimigo aos ~4 s; depois trocar de alvo (mapa com 2 spawns).
- Esperado:
  - Nenhum cast antes de `t0 + ArriveSeconds` (0,4 s): a unidade só entra na fila chegada.
  - Primeiros casts (beat `Skill`) em ordem de slot: ~`t0+0,4`, `+0,7`, `+1,0` (`LastCastAt` consecutivos
    com diferença ≥ `SkillGap` 0,3 s, ± 1 tick 0,05 s).
  - Dano de cada skill (`Hits{Kind="Skill", Amount=50}` e `PendingHits` vencendo) `HitDelay` (0,4 s) depois
    do **próprio** cast: ~`t0+0,8`, `+1,1`, `+1,4`. Nunca as três no mesmo tick.
  - `SkillReadyAt` de cada unidade = `LastCastAt` dela + `Cooldown` (8 s); muda uma vez por cast; próximo
    cast de cada unidade ~8 s após o próprio cast (cooldowns independentes).
  - Passo 4: `Recall`/reengajar/troca de alvo **não** mudam `SkillReadyAt` (nem reiniciam, nem pausam). Se a
    unidade já estiver pronta ao reengajar, o cast sai ~0,4 s após o novo `Attack`; se ainda em recarga, sai
    quando `now ≥ SkillReadyAt` e a unidade estiver chegada. `Queue` limpa no `Recall` e na troca de alvo.
  - Slots com anel verde girando; toque não gera `UseSkill` (nada muda em `Queue`).
- Bordas:
  - Cooldown corre fora de combate: cast, `Recall` logo após, esperar 8 s parado, reengajar → skill sai
    ~0,4 s depois do `Attack`.
  - Alvo morre com skill na fila ou em `HitDelay` → `Queue` e `PendingHits` limpos; nenhuma skill nem dano
    de skill depois (DEC-024); `SkillReadyAt` das que já castaram não volta.
  - `Dev("SetSkillReady", "Player1", <unitId>, 0)` com a unidade engajada e chegada → entra na fila no
    próximo tick e casta respeitando `SkillGap`.
  - **Forjado**: `Net.UseSkill:fire({ Unit = <própria> })` com auto ligado (client) e
    `Dev("FireAs", "Player1", "UseSkill", { Unit = <própria> })` (servidor) → ignorados (`SkillReadyAt` e
    `Queue` não mudam, nenhum `Hits` Skill extra).

### A10 — 4 telas do Figma

- Tipo: M1 + MB + revisão do usuário. Tasks: 013, 022, 023, 024, 025, 026.
- Bloqueio: assets do usuário (PNG + JSON + foto) por tela. Sem eles → `Bloqueado`.
- Passos:
  1. Story de cada tela no UI Labs vs foto de referência, lado a lado (print anexado).
  2. Em jogo (MB): abrir Inventário, Loja, Battle Pass pelos atalhos da HUD; fechar cada um.
  3. Com cada tela aberta, tocar no inimigo atrás da tela.
- Esperado: visual fiel (aprovação do usuário, não do QA); abre/fecha por toque; só uma tela por vez; fechar
  volta à HUD; com tela aberta o toque no mundo não comanda pets; HUD mostra Coins, Parar, toggle, 3 slots.
- Bordas: abrir duas telas em toques rápidos → fica só a última; telas sem lógica de sistema (tocar "Comprar"
  não muda `Coins`, não manda pacote); layout legível em 1280×720 e em celular pequeno (emulador iPhone SE ou
  equivalente); botões ≥ 44 px lógicos.

### A11 — Dois jogadores no mesmo inimigo

- Tipo: S + M2. Tasks: 010, 015.
- Passos (Clients and Servers, 2 players):
  1. Conferir o set `Pets` nos dois clients: 6 unidades, `Owner` = UserId de cada um (negativos no Studio);
     no Server, `Dev("Units", "Player1")` e `Dev("Units", "Player2")` → 3 cada, `Ring` distintos ao engajar.
  2. Player1 e Player2 atacam o mesmo inimigo.
  3. Matar o inimigo; esperar o respawn; atacar de novo.
- Esperado: vida cai pela soma (~60/s com 6 pets); anel sem sobreposição (6 `Ring` distintos); nenhum erro
  no Output de servidor e dos 2 clients durante 2 ciclos completos de morte/respawn.
- Bordas:
  - **Jogador sai no meio** (fechar a janela do Player2 engajado): unidades dele somem do set em todos os
    clients; slots do anel liberados; `Dev("Engagement", "Player2")` vazio/erro tratado (jogador não existe);
    vida continua caindo só pelo Player1; `Dev("Ledger", 1)` mantém a entrada do Player2 com
    `Present = false` (PT-21); sem erro.
  - Player2 entra com Player1 já engajado → vê pets do Player1 no anel em `Assist`.
  - 3 players (Clients and Servers com 3) → 9 unidades, anel com N=9 sem sobreposição.

### A12 — Desempenho mobile

- Tipo: MB (+ dispositivo real se houver). Tasks: 012, 016, 018, 020, 030.
- Passos:
  1. Clients and Servers com 2 players; na janela do Player1 ativar Device Emulator (perfil de celular médio).
  2. Ctrl+Shift+F5 (estatísticas) / MicroProfiler. Medir FPS por 60 s em: ocioso; 1 jogador atacando;
     2 jogadores atacando com auto ligado (skills, números, Assist, teleportes).
  3. Qualidade gráfica no mínimo (variante `Lite` dos efeitos).
- Esperado: sem queda perceptível; registrar FPS médio/mínimo e `Network Receive` por client (< 1 KB/s no v0,
  `architecture.md` §10). Números entregues à TASK-030 (base para aceitar/recusar).
- Bordas: ≤ 6 VFX de skill simultâneos (`MaxSkillEffects`); VFX de skill de outro jogador não aparece (PT-19);
  ≤ 40 números de dano no total. LOD (TASK-030): pets de outros ocultos > 150 studs, inimigo sem animação
  > 200 e sem modelo > 300.
- Observação: emulador do Studio não mede o hardware do celular; o resultado oficial pede dispositivo real
  quando disponível. Sem dispositivo, marcar "medido só no emulador".

### A13 — Troca de asset só por dados

- Tipo: E + M1. Tasks: 003, 004, 007, 008, 011, 016 (execução TASK-029).
- Passos:
  1. `git stash`/branch de teste. Adicionar `assets/roblox/Characters/<NovoModelo>.rbxm` (R6, sem Humanoid,
     AnimationController + Animator, pivô no pé) e apontar `Characters.luau` de um personagem para ele.
  2. Trocar o `Id` (e `Duration`) de **uma** animação em `AnimationSets.luau`.
  3. `rogen build` → `modux generate` → Play.
  4. `git diff --stat`.
  5. Reverter.
- Esperado: o personagem aparece com o novo modelo e a nova animação; o diff só contém `Characters.luau`,
  `AnimationSets.luau`, o `.rbxm` (e `.rogen.json` só se o mapeamento por pasta não cobrir o arquivo novo);
  nenhum Service/Controller muda.
- Bordas: `Model` apontando para nome inexistente → `ContentService` para o boot com mensagem citando arquivo
  e ID (TASK-004); modelo com Humanoid ou sem `Animator` → erro claro no boot ou no client, não crash
  silencioso; rig custom (boss) fora do v0, não testar.

### A14 — Auto desligado: toque no slot usa a skill daquele pet

- Tipo: M1 + MB + S (forjado). Tasks: 019, 021, 022.
- Pré: desligar o toggle; conferir `Profile.AutoSkill = false` no client.
- Passos:
  1. Sem alvo: tocar num slot com skill pronta.
  2. Engajar; antes de 0,4 s tocar num slot.
  3. Depois de chegar: tocar no slot 2 com skill pronta.
  4. Imediatamente tocar de novo no slot 2 (agora em recarga).
  5. Tocar nos slots 1 e 3 em sequência rápida (< 0,3 s).
  6. Esperar 30 s sem tocar com skills prontas.
- Esperado:
  1/2: nada acontece (slot "Indisponível"); nenhum `UseSkill` enviado (ou ignorado se enviado).
  3: só a unidade do slot 2 faz `Skill` (beat para o dono; `Hits` Skill 50 0,4 s após o **próprio** cast;
     `SkillReadyAt` = cast + 8 s, conferir com `Dev("Units", "Player1")`); animação de combate em curso é
     interrompida (A16); slot passa por "Pedido enviado" e depois "Recarga".
  4: não responde; nada chega ao servidor ou é ignorado.
  5: as duas skills saem em ordem de pedido, casts espaçados ≥ 0,3 s (`SkillGap`); danos 0,4 s após cada
     cast (≈ +0,4 s e +0,7 s do primeiro cast se o pedido do 3 chegou antes do fim do gap).
  6: nenhuma skill dispara sozinha (espera o toque sem limite).
- Bordas:
  - **Toggle com skills prontas**: com 3 skills prontas e auto desligado, ligar o auto → disparam as 3 em
    ordem de slot, 0,3 s entre casts (± 1 tick de 0,05 s); danos em +0,4, +0,7 e +1,0 s do primeiro cast.
  - Desligar o auto no meio da fila de auto-cast → itens já enfileirados: registrar o comportamento
    observado (spec não define; esperado razoável: casts já na fila saem). Se diferente, apenas anotar.
  - Toggle desligado → religado → desligado em 0,2 s: estado final = último enviado (`SetAutoSkill` é por
    valor, idempotente); HUD otimista bate com `Profile` depois do flush.
  - **Forjados** (Command Bar do client do Player1, 2 players; repetir cada um no servidor com
    `Dev("FireAs", "Player1", "UseSkill", { Unit = n })` e conferir `Dev("Units", ...)`/`Dev("Engagement", ...)`):
    - `UseSkill { Unit = <unidade do Player2> }` → ignorado; nada muda nas unidades do Player2.
    - `UseSkill { Unit = <própria> }` com auto **ligado** → ignorado.
    - `UseSkill { Unit = <própria em recarga> }` → ignorado; `SkillReadyAt` não muda.
    - `UseSkill { Unit = 99999 }` (inexistente) → ignorado, sem erro.
    - `UseSkill` própria pronta mas sem alvo/antes de chegar → ignorado.
    - Mesmo `UseSkill` válido 20× em 1 s → uma só skill (não enfileira duplicado; rate limit).
    - `SetAutoSkill` 100× alternando em 1 s → sem erro; servidor aceita ≤ ~10; `Profile` final coerente com o
      último aceito; nenhuma skill extra.
  - Payload malformado (`UseSkill:fire({ Unit = -1 })`, tipo errado) → rejeitado pelo Lync/servidor sem
    derrubar o handler para os outros jogadores.
  - Estado do toggle não persiste: sair e entrar → `AutoSkill = true` (Mock, FEAT-025).

### A15 — Dano dos 3 junto, uma animação de combate por vez

- Tipo: M1 + S. Tasks: 015, 019, 020.
- Passos: engajar com 3 pets; `Dev("Units", "Player1")` e `Dev("Enemies")` no início e 10 s depois
  (`NextHitAt` de cada unidade avança ~10 × `AttackInterval`; vida cai ~300); filmar os números no client.
- Esperado: as 3 unidades aparecem em `Hits` com ritmo de ~1/s cada, inclusive as fora de cena; vida ≈
  30/s; em qualquer instante, no máximo **um** pet do jogador toca `Enter/Combat1/Combat2/BackOff`; os turnos
  alternam em round-robin (slot 1 → 2 → 3 → 1).
- Bordas: com 1 pet equipado → o mesmo pet repete turnos, sem erro (não há comando de dev para `Equipped`:
  usar cópia local de `Tuning.StarterPets = 1`, revertida, ou marcar `Bloqueado`); unidade removida no meio
  do turno (jogador sai) → turno encerra sem beat órfão.

### A16 — Skill interrompe o combate

- Tipo: M1. Tasks: 019, 020.
- Passos: com auto desligado, esperar o pet do slot 1 entrar em `Combat1`; tocar no slot 3 (pronto).
- Esperado: o pet do slot 1 sai de cena (volta ao anel) sem terminar o `Combat1`; o pet 3 entra, toca
  `Skill` + `CastEffect`; `Effect` no alvo e número de skill em ~0,4 s; inimigo toca `HitHeavy` (ou `Hit`);
  depois `BackOff` e o round-robin continua.
- Bordas:
  - Skill durante a skill de outro pet (dois pedidos seguidos; o segundo cast sai `SkillGap` 0,3 s depois) →
    a segunda corta a primeira na animação; o dano da primeira **ainda sai** 0,4 s após o cast dela (antes do
    impacto da segunda, que sai 0,4 s após o próprio cast) (PT-24).
  - **Alvo morre durante a skill**: logo após o beat `Skill`, no servidor `Dev("Kill", 1, "Player2")` antes
    de 0,4 s → `PendingHits` vazio em `Dev("Engagement", "Player1")`, sem `Hits` para inimigo morto, pets
    voltam ao dono, sem erro; `SkillReadyAt` mantém cast + 8 s.
  - **Dono morre durante a skill** (resetar personagem) → servidor: não há regra de recall por morte do
    personagem na spec; registrar o observado. Client: pets congelam até o respawn; nada trava.

### A17 — Dinheiro proporcional ao dano

- Tipo: S + M2. Tasks: 005, 014, 022.
- Casos de servidor (`Rewards.Coins = 100`, Clients and Servers com 2–3 players, inimigo uid 1 com vida
  cheia). Montar o ledger com `Dev("Damage", 1, n, "PlayerX")`, conferir com `Dev("Ledger", 1)`, fechar com
  `Dev("Kill", 1, ...)` só se a soma não zerou a vida (o restante entra no ledger de quem mata: preferir
  somas = 1000), e ler `Dev("LastPayout", 1)` e `Dev("Coins", "PlayerX")` (zerar antes com `SetCoins`).

| # | Ledger ao morrer | Esperado (`Reward` / `Coins`) | Regra |
|---|---|---|---|
| D1 | P1 = 1000 | P1 +100 | só um |
| D2 | P1 = 700, P2 = 300 | P1 +70, P2 +30 | proporcional (TASK-014 crit. 3) |
| D3 | P1 = 999, P2 = 1 | P1 +99, P2 +1 | floor + mínimo 1 |
| D4 | P1 = 995, P2 = 5 | P1 +99 (floor 99,5), P2 +1 (floor 0,5 → mín. 1) | arredondamento e mínimo |
| D5 | P1 = 333, P2 = 333, P3 = 334 | +33, +33, +33 (soma 99, sobra não redistribuída) | floor |
| D6 | overkill: `Damage(1, 950, P2)`, depois `Damage(1, 500, P1)` | retorno 50; ledger P1 = 50 (não 500); `Total` 1000 | overkill não conta |
| D7 | `Damage(1, 400, "Player2")`; **P2 sai** (`Kick` ou fechar janela); `Damage(1, 600, "Player1")` mata | antes da morte: `Ledger` mantém P2 = 400 `Present = false`, `Total` 1000; `LastPayout`: P1 `Share` **60**, P2 `Present = false`, `Share` 0; nenhum `Reward` enviado a P2; os 40 não vão para ninguém | PT-21: quem sai conta no denominador e não recebe |
| D7b | P2 = 400, P2 sai, **P2 volta** (nova instância), P2 = 100, P1 = 500 | `Ledger` com 2 entradas "Player2" (antiga `Present = false`, nova `true`), `Total` 1000; P1 +50, P2 novo +10 | chave é a instância `Player` |
| D8 | P2 causou 0 (só olhou) | P2 não recebe `Reward`, não aparece em `LastPayout` | só dano > 0 |
| D9 | P2 = 999 e sai; P1 = 1 | P1 +1 (mínimo para presente); P2 nada | mínimo 1 só para presentes |

- Estático (E, TASK-006/014): `EnemyService`/`EnemySpawn` não escutam `PlayerRemoving` para mexer no ledger
  (`rg -n PlayerRemoving src/Enemy src/Economy`); `EconomyService` usa a soma de **todas** as entradas e
  testa presença (`player.Parent == Players`) só para pagar (`architecture.md` 4.5).
- Manual (M2):
  1. P1 e P2 atacam o mesmo inimigo até morrer. Anotar `Coins` antes/depois nas duas HUDs e o ledger no Output.
  2. P1 ataca sozinho até 900, P2 entra e dá o último hit.
  3. Com P2 engajado, fechar a janela do P2 antes da morte.
- Esperado: HUD de cada um soma a parte certa na hora da morte; popup "+N" (`LastReward`) igual à parte;
  bate com `Dev("LastPayout", 1)`. Passo 3: P1 recebe só a própria fração do total (dano do P2 continua no
  denominador, PT-21); P2 que saiu não recebe nada e não gera erro (`Reward` para ausente não é enviado).
- Bordas: kill durante a troca de alvo/recall do jogador → ainda recebe pelo dano já causado; dois inimigos
  morrendo no mesmo tick → dois `Reward`, `Coins` soma os dois; `Coins` não persiste entre sessões (Mock).

### A18 — Assistência dos pets fora de cena

- Tipo: M1. Tasks: 016, 020.
- Passos: engajar com 3 pets; observar 10 s de câmera aberta.
- Esperado: os 2 fora de cena ficam no slot do anel a ~6 studs da borda do inimigo, olhando para ele, tocando
  `Assist` em loop; o principal faz `Enter`→`Combat1`→`Combat2`→`BackOff` na posição de golpe e volta ao anel;
  o próximo assume.
- Bordas: personagem do dono se afasta até perto do leash (110 studs) → pets continuam no anel; após 120 →
  recall e voltam à formação; `Assist` não é interrompido por toques na HUD.

### A19 — Dois jogadores, cada um com a própria sequência

- Tipo: M2. Tasks: 019, 020.
- Passos (2 players lado a lado na tela; gravar as duas janelas):
  1. P1 e P2 atacam o mesmo inimigo.
  2. Comparar o que cada janela mostra por 20 s, incluindo skills de ambos.
  3. No Server, `Dev("Engagement", "Player1")` e `Dev("Engagement", "Player2")`: `Featured`/`Phase`
     independentes.
- Esperado:
  - Janela P1: pets do P1 fazem a coreografia; pets do P2 só em `Assist` no anel, sem teleporte de golpe e sem
    VFX de skill; inimigo reage aos golpes do P1.
  - Janela P2: o espelho.
  - Mesma vida nas duas janelas e em `Dev("Enemies")`; cada janela mostra só os números dos próprios pets
    (A7, PT-22).
  - `Beat` e `Hits` vão só para o dono de cada Engagement (nenhum do P1 chega ao P2): E no `CombatService`
    (`fireClient` por dono) + listener extra em `Net.Beat`/`Net.Hits` no Command Bar do client do P2.
  - Sem erro nos 3 Outputs por 2 ciclos de morte/respawn.
- Bordas:
  - P2 sai no meio do turno do P1 → janela do P1 sem alteração na coreografia; pets do P2 somem.
  - P1 troca de alvo enquanto P2 continua → P2 não percebe mudança na própria sequência.
  - Um terceiro jogador só observando → inimigo em `Idle` para ele, com `Hits` dos outros subindo.

---

## 5. Casos de borda transversais (Provisórios)

| ID | Caso | Passos | Esperado | Critério ligado |
|---|---|---|---|---|
| B1 | Overkill | vida 50, hit de skill 50 + 3 básicos no mesmo tick | aplicado total = 50; ledger soma 50; `Hits` mostram o aplicado | A6, A17 |
| B2 | Mínimo 1 moeda | ledger 999/1 | +99 / +1 | A17 |
| B3 | Jogador sai antes da morte | ver D7, D9 | entrada fica no ledger (`Present = false`), conta no denominador, sem parte, sem redistribuição, sem erro (PT-21) | A11, A17 |
| B4 | Alvo morre durante skill | ver A16 | `PendingHit` descartado, pets ao dono, cooldown mantido | A16, DEC-024, PT-23 |
| B5 | Toggle com skills prontas | 3 prontas, liga auto | 3 casts em ordem de slot, ≥ 0,3 s entre cada; danos 0,4 s após cada cast | A9, A14, PT-24 |
| B6 | `UseSkill` forjado: unidade de outro jogador | ver A14 | ignorado | A14 |
| B7 | `UseSkill` forjado: auto ligado | ver A14 | ignorado | A9 |
| B8 | `UseSkill` forjado: em recarga | ver A14 | ignorado | A14 |
| B9 | Spam `UseSkill`/`SetAutoSkill`/`Attack`/`Recall` | 100 pacotes/s por 5 s | ≤ 10 aceitos/s por jogador; sem erro; outro jogador não sofre lag perceptível | A11, rede |
| B10 | Dono morre durante ataque | resetar personagem engajado | pets congelam no client; nada quebra; ao respawn, seguem | A4, A8 |
| B11 | Jogador sai com fila de skills | sair com 3 skills na fila | sem cast órfão, sem erro, unidades removidas | A11 |
| B12 | Dois jogadores no mesmo inimigo e divisão | ver A17 manual | partes proporcionais nas duas HUDs | A11, A17 |
| B13 | Respawn com jogador engajado | inimigo morre e renasce | pets já em casa (DEC-024); novo `Attack` funciona no `Life` novo | A3, A4 |
| B14 | Lag de replicação | Studio: Incoming Replication Lag 0,5 s | beats atrasados com seek ou descartados; vida consistente | A8, A19 |
| B15 | Cooldown atravessa recall/troca de alvo | cast, `Recall`, reengajar em 2 s | `SkillReadyAt` inalterado; skill só ~8 s após o cast | A9, PT-23 |
| B16 | Números alheios | 2 jogadores no mesmo inimigo | nenhum `Hits` do outro chega; barra igual | A7, A19, PT-22 |
| B17 | `Dev` fora do Studio | E: `DevService` com guarda `IsStudio`; em place publicado, `ServerStorage.Dev` não existe | nada exposto em produção | PT-25 |

---

## 6. Migração de perfil (TASK-005, `data.md`)

Executar com `PersistProfiles = false` (Mock), injetando o dado antes do `Load` numa cópia local do
`ProfileService`/store Mock só para teste, revertida (não há comando de `Dev` para isso; `Coins`/`SetCoins`
cobrem só o saldo). Cada migração futura (`Migrations[v]`) ganha uma linha
nesta tabela, com entrada → saída esperada.

| ID | Dado de entrada | Esperado |
|---|---|---|
| P1 | Perfil novo (vazio) | Template: `Version 1, Coins 0, AutoSkill true, Pets {}, Equipped {}, NextPetUid 1, EquipSlots 3`; PetService concede 3 pets (`Level 1, Stars 1, Xp 0, Gear {}`) e `Equipped` com 3 uids num único `Update` |
| P2 | Sem campo `Version` (`{ Coins = 50 }`) | tratado como 1; nenhuma migração roda; `Reconcile` preenche os campos faltantes; `Coins = 50` preservado |
| P3 | `Version = 2` com `CURRENT_VERSION = 1` | jogador kickado com mensagem "atualizando, entre de novo"; **nada gravado** (store Mock inalterado); sem atom criado |
| P4 | Campos obsoletos `Level = 7, Playtime = 300` | não viram atom (`Bind` itera o Template); não replicam; sem erro |
| P5 | Sem `AutoSkill` | `Reconcile` → `true` |
| P6 | `Pets` com 1 pet já existente | StarterPets **não** concedidos de novo |
| P7 | `Migrations.luau` na v1 | lista vazia; laço de migração não roda; arquivo sem yield, sem `require` de serviço |
| P8 | Replicação dividida | mudar `Coins` → só `Profile` dispara; mudar `Equipped` → só `Inventory`; `ClientReady` → os dois |

---

## 7. Roteiros de sessão

### 7.1 Dois clients no Studio (A11, A17, A19)

1. Test > Clients and Servers: Local Server, **2 Players**, Start.
2. Organizar janelas: Server, Player1, Player2 visíveis (gravação de tela das 3).
3. Em cada janela, abrir o Output; filtrar por erro.
4. Player1 e Player2 andam até o inimigo (< 80 studs) e tocam nele.
5. Executar A11 → A19 → A17 (manual) → bordas B3, B9, B11, B12.
6. Fechar o Player2 no meio de um ciclo (jogador sai).
7. Repetir com 3 players para o anel (A11 borda).
8. Cleanup; anexar vídeos e Outputs ao relatório.

### 7.2 Emulador mobile (A4, A5, A10, A12, A14)

1. Clients and Servers com 2 players; na janela do Player1, View > Device Emulator → perfil de celular médio
   e um pequeno; orientação paisagem.
2. Usar só toque (mouse simula toque no emulador; não usar teclado).
3. A4 (toque), A5 (Parar), A14 (slots), A10 (telas), A12 (FPS, MicroProfiler).
4. Qualidade gráfica 1 para a medição `Lite`.
5. Dispositivo real (se disponível): publicar em place privado de teste e repetir A12.

### 7.3 Troca de asset por dados (A13)

Ver A13. Fazer em branch descartável; diff anexado ao relatório; revert confirmado com `git status` limpo.

---

## 8. Pendências que afetam o plano

| Item | Efeito no teste |
|---|---|
| Assets da UI (DEC-017, Q-036) | A10 e A14/A9 pela HUD ficam `Bloqueado`; A9/A14 testados pelo `CommandController` via Command Bar do client (TASK-021 crit. 4) |
| Animações do contratante / dono (Q-036 a) | A8 com placeholders; falha de permissão = `Bloqueado`, não falha de código |
| Pets de outros jogadores (Q-037) | A19 testado contra PT-19 (só `Assist`) |
| Comandos de `Dev` (PT-25) | casos **S** dependem dos comandos da seção 1 entregues por TASK-006, 014, 015, 019 |
| Texto de FEAT-022/FEAT-024 (secretária) | arquitetura Revisão 3 já resolveu (PT-22 a PT-24); o plano segue a arquitetura. Se `features.md` ainda trouxer "cooldown conta da chegada" ou "dano de todas na hora", não é falha de código |
