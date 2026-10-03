# Features e mecânicas

Status: Rascunho

Índice de sistemas do jogo. Cada FEAT descreve o comportamento já decidido, os números
(**Provisório** = valor temporário, pode mudar sem nova pergunta; **A definir** = falta decisão) e as
perguntas que travam a feature. Fichas detalhadas irão para documentos próprios em `design/`
conforme cada tema for fechado.

## Resumo

Coluna `v0`: **Sim** = entra no Protótipo de apresentação (DEC-013); **Parcial** = só a parte descrita na seção "No v0" da feature; vazio = fora do v0.

| ID | Feature | Fonte | v0 | Bloqueado por |
|---|---|---|---|---|
| FEAT-001 | Ilhas temáticas | DEC-003, DEC-014, DEC-025 |  | Q-013 |
| FEAT-002 | Inimigos em spawn fixo e respawn | DEC-003, DEC-011 | Sim | Q-012, Q-018 |
| FEAT-003 | Ataque do player | DEC-002 |  | Q-007 |
| FEAT-004 | Dinheiro (moeda principal) | DEC-002, DEC-011, DEC-021 | Parcial | Q-012 |
| FEAT-005 | Ovos | DEC-004 |  | Q-012 |
| FEAT-006 | Pets: equipar e combater | DEC-004, DEC-020 | Parcial | Q-008, Q-018 |
| FEAT-007 | Comando por clique/toque | DEC-004, DEC-011, DEC-024 | Sim | — |
| FEAT-008 | Raridades | DEC-005 |  | Q-010, Q-012 |
| FEAT-009 | Level e experiência de pet | DEC-006, DEC-027 |  | Q-009 |
| FEAT-010 | Venda de pets | DEC-006 |  | Q-012 |
| FEAT-011 | Fusão e estrelas | DEC-007 |  | Q-011 |
| FEAT-012 | Inventário de pets | DEC-004, DEC-018 | Parcial (só visual) | Q-021 |
| FEAT-013 | Progressão dentro da ilha e desbloqueio de ilha | DEC-004, DEC-026 |  | Q-013, Q-014, Q-040 |
| FEAT-014 | Ilha inicial como lobby | DEC-009, DEC-014 |  | — |
| FEAT-015 | UI importada do Figma | DEC-010, DEC-013, DEC-017, DEC-018, DEC-021, DEC-022 | Sim (4 telas) | — |
| FEAT-016 | Persistência de dados do jogador | implícito no loop |  | — |
| FEAT-017 | Controles mobile-first | DEC-008 | Sim | Q-007 |
| FEAT-018 | Monetização | — |  | Q-015 |
| FEAT-019 | Trading | — |  | Q-016 |
| FEAT-020 | Números de dano (BillboardGui) | DEC-013 | Sim | — |
| FEAT-021 | Comando "parar de atacar" | DEC-013 | Sim | Q-030 |
| FEAT-022 | Habilidades e animações de pet | DEC-013, DEC-016, DEC-022, DEC-023 | Sim | — |
| FEAT-023 | Integração de assets do contratante | DEC-012, DEC-013, DEC-014, DEC-019, DEC-028 | Sim | Q-027, Q-036 |
| FEAT-024 | Combate coreografado e state manager | DEC-020, DEC-023, DEC-024 | Sim | Q-032, Q-037 |
| FEAT-025 | Toggle de uso automático e skill manual por slot | DEC-016, DEC-022 | Sim | — |
| FEAT-026 | Loja | DEC-018 | Parcial (só visual) | Q-015, Q-035 |
| FEAT-027 | Battle Pass | DEC-018 | Parcial (só visual) | Q-015, Q-035 |
| FEAT-028 | Bosses | DEC-019, DEC-026 |  | Q-041, Q-018 |
| FEAT-029 | Missões progressivas | DEC-026, DEC-027 |  | Q-040 |
| FEAT-030 | Equipamentos de pet (slots) | DEC-026, DEC-027 |  | Q-038 |
| FEAT-031 | Recursos secundários: gemas, pó estelar, itens de upgrade/merge | DEC-026, DEC-027 |  | Q-039 |

---

## FEAT-001 — Ilhas temáticas

- Cada mapa é uma ilha `ISL-##`, com **tema de gênero** de anime, não de obra (DEC-025). Personagens originais, inspirados em arquétipos. Nenhum nome/visual de obra real.
- Cada ilha tem: conjunto de inimigos `ENM-###`, um ovo `EGG-##`, spawn points.
- Ilhas finais e seus modelos são feitos pelo **contratante** (DEC-014, corrige DEC-003). Layout não é responsabilidade dos agentes.
- No v0: fora; usa o mapa de teste simples numa baseplate, montado pelo usuário (DEC-014).
- Número de ilhas e desbloqueio: A definir (Q-013).

## FEAT-002 — Inimigos em spawn fixo e respawn

- Cada inimigo nasce num spawn point: bloco invisível colocado pelo usuário no mapa.
- O spawn point define qual inimigo nasce ali (forma de configurar: a definir pelo `architect`; ex.: atributo no bloco com o ID `ENM-###`).
- Inimigo fica parado. Não anda, não persegue.
- Ao morrer: some, e renasce no mesmo spawn point após o tempo de respawn.
- Tempo de respawn: **Provisório** 5 s (Q-012).
- Vida por inimigo: A definir (Q-012). Cresce dentro da ilha, do mais fraco ao mais forte.
- Inimigo ataca de volta? A definir (Q-018).
- Inimigos são **compartilhados** entre todos os jogadores do servidor (DEC-011). Vida e morte são do servidor; todos veem a mesma vida.
- Servidor guarda, por inimigo vivo, o dano acumulado de cada jogador (player + pets dele). Zera ao renascer.

### No v0

- 1 spawn point com 1 inimigo placeholder, num baseplate.
- Vida: **Provisório** 1.000. Respawn: **Provisório** 5 s. Inimigo não ataca.
- Vida visível acima do inimigo (barra ou número; forma conforme Figma, Q-022).

## FEAT-003 — Ataque do player

- O player começa batendo nos inimigos com as próprias mãos.
- Dano próprio, forma de ataque e se continua batendo após ter pets: A definir (Q-007).

## FEAT-004 — Dinheiro

- Moeda principal. Ganha ao matar inimigo.
- Valor por inimigo e curva entre ilhas: A definir (Q-012).
- Divisão entre jogadores (DEC-011): ao morrer, recompensa do inimigo é dividida em proporção ao dano.
  - `parte do jogador = recompensa × (dano do jogador ÷ soma do dano de todos)`.
  - Dano conta só até a vida restante (overkill não conta) — **Provisório**.
  - Arredondar para baixo; quem causou dano > 0 recebe no mínimo 1 — **Provisório**.
  - Jogador que saiu do servidor antes da morte perde a parte; ela não é redistribuída — **Provisório**.
- Bosses dão mais dinheiro que inimigos comuns (DEC-026; valor em Q-041).
- Usos: abrir ovos, desbloquear ilhas (Q-013), outros a definir.

### No v0 (DEC-021)

- Matar inimigo dá dinheiro, dividido pela regra acima.
- Recompensa do inimigo do v0: **Provisório** 100.
- Contador de dinheiro na HUD, atualizado na hora da morte do inimigo.
- Sem uso do dinheiro (Loja só visual). Sem persistência real.
- Critério A17 (DEC-021): matar o inimigo soma dinheiro na HUD de cada jogador que causou dano, na proporção do dano.

## FEAT-005 — Ovos

- Cada ilha tem um ovo `EGG-##` com os pets daquela ilha.
- Comprado com dinheiro. Abrir dá 1 pet sorteado pela tabela de chances da raridade.
- Custo por ovo e tabela de chances: A definir (Q-012).
- Abrir múltiplo (ex.: triplo) e auto-abrir: dependem de Q-015.

## FEAT-006 — Pets: equipar e combater

- Pets `PET-###` são personagens obtidos em ovos.
- Pets equipados seguem o player e atacam o alvo escolhido (FEAT-007).
- Dano do pet = dano base × multiplicador de level × multiplicador de estrela (forma **Provisória**).
- Slots equipados: A definir (Q-008).
- Pet sem alvo: segue o player (comportamento **Provisório**).

### No v0

- 3 pets placeholder já equipados ao entrar (**Provisório**, Q-008). Sem ovo.
- Ataque básico automático: **Provisório** 10 de dano a cada 1,0 s por pet. Todos os pets no alvo causam dano ao mesmo tempo, mesmo sem estar animando (DEC-020).
- Habilidade: ver FEAT-022. Coreografia: ver FEAT-024.

## FEAT-007 — Comando por clique/toque

- O player clica/toca num inimigo. Todos os pets equipados vão até ele e atacam.
- Quando o alvo morre: pets voltam para o dono (DEC-024). Não procuram outro alvo sozinhos.
- Inimigo compartilhado (DEC-011): pets de vários jogadores podem atacar o mesmo inimigo ao mesmo tempo.
- Tocar em outro inimigo troca o alvo de todos os pets do player.
- Parar de atacar: FEAT-021.

## FEAT-008 — Raridades

- Template **Provisório** (DEC-005): Comum, Incomum, Raro, Lendário, Épico, Mítico.
- Ordem e lista final: Q-010.
- Cada raridade tem cor própria na UI (definir no style guide).
- Chance por raridade e faixa de dano base: A definir (Q-012).

## FEAT-009 — Level e experiência de pet

- Pet tem level. Subir level aumenta dano e valor de venda (DEC-006).
- Pet ganha **experiência ao lutar** (DEC-027). Bosses dão mais experiência (DEC-026).
- Divisão da XP, level máximo, curva e XP do jogador: A definir (Q-009).
- Possível relação com pó estelar/itens de upgrade: Q-039.

## FEAT-010 — Venda de pets

- Player vende pet por dinheiro.
- Valor de venda = valor base da raridade × fator de level (forma **Provisória**; números em Q-012).
- Pet equipado não pode ser vendido sem desequipar (**Provisório**).
- Venda em massa por raridade: **Provisório**, ver Q-021.

## FEAT-011 — Fusão e estrelas

- Só pets idênticos (mesmo `PET-###`) podem ser fundidos (DEC-007).
- Fusão consome as cópias e gera 1 pet com +1 estrela.
- Valores **Provisórios** até Q-011:

| Estrelas | Cópias para chegar | Multiplicador do status base |
|---|---|---|
| 1 (padrão do ovo) | — | ×1,0 |
| 2 | 3 pets de 1 estrela | ×1,5 |
| 3 | 3 pets de 2 estrelas | ×2,25 |
| 4 | 3 pets de 3 estrelas | ×3,5 |
| 5 (máx.) | 3 pets de 4 estrelas | ×5,0 |

- O que acontece com o level dos pets consumidos: A definir (Q-011).

## FEAT-012 — Inventário de pets

- Lista todos os pets do player, com raridade, level, estrelas, dano.
- Ações: equipar, desequipar, vender, fundir.
- Limite de inventário: A definir (Q-021).
- No v0: Parcial — **só visual** (DEC-018): tela importada do Figma abre, fecha e responde a toque; sem lógica de equipar/vender/fundir.

## FEAT-013 — Progressão dentro da ilha e desbloqueio

- Inimigos da ilha vão dos fracos aos fortes.
- Ciclo: derrotar fracos → abrir ovo da ilha → pets melhores → derrotar fortes.
- Bosses são opcionais, exceto quando exigidos por missão (DEC-026, FEAT-029).
- Desbloqueio da próxima ilha: A definir (Q-013). Rebirth: Q-014.

## FEAT-014 — Ilha inicial como lobby

- Jogador entra no servidor direto na ilha 1 (DEC-009).
- A ilha 1 concentra o spawn do jogador e a UI inicial.
- Pode virar lobby separado no futuro, por nova decisão.

## FEAT-015 — UI importada do Figma

- Layout da UI vem do Figma do usuário (DEC-010). Implementação em Vide.
- Prioridade mobile: botões grandes, alcance do polegar, telas legíveis em celular.

### Método de importação (DEC-017)

1. Usuário envia por tela: PNGs dos elementos, JSON da estrutura ("Figma to JSON"), foto de referência da tela.
2. `frontend-coder` monta a tela em Vide usando PNGs e JSON, comparando com a foto.
3. Usuário revisa e direciona ajustes. Tela pronta = usuário aprova o visual.

- Publicação das imagens no Roblox (dono do asset): Q-036.

### Telas existentes no Figma (DEC-018)

| Tela | No v0 | Funções reais no v0 |
|---|---|---|
| HUD principal | Sim | ações de gameplay do v0: parar de atacar (FEAT-021), toggle de uso automático de skills e slots dos pets com cooldown (FEAT-025), contador de dinheiro (FEAT-004), botões que abrem as outras telas |
| Inventário | Sim, só visual | abrir/fechar |
| Loja | Sim, só visual | abrir/fechar |
| Battle Pass | Sim, só visual | abrir/fechar |

- Se o HUD do Figma não tiver botão "Parar", toggle de auto-skill, slots de pet ou contador de dinheiro: o agente adiciona no estilo das outras peças e marca **Provisório** para o usuário revisar.
- Critério A10 (alterado por DEC-018): as 4 telas aparecem fiéis à referência e abrem/fecham por toque; o HUD executa as ações reais do v0.

## FEAT-016 — Persistência de dados

- Salvar: dinheiro, pets (ID, level, XP, estrelas, equipamentos), equipados, ilhas desbloqueadas, gemas, pó estelar, itens de upgrade/merge, progresso de missões (DEC-027).
- Formato e serviço: `architect` (ProfileStore). Fora do v0 (DEC-013); entra no jogo completo.

## FEAT-017 — Controles mobile-first

- Toque no inimigo seleciona o alvo. Mesmo comportamento com clique no PC.
- Detalhes dependem de Q-007.

## FEAT-018 — Monetização

- Gamepasses `GP-##` e developer products `DP-##`. A definir (Q-015).
- Deve seguir as regras de conteúdo e monetização do Roblox (inclui exibir chances de itens pagos aleatórios, se ovo for vendido por Robux).

## FEAT-019 — Trading

- A definir (Q-016).

## FEAT-020 — Números de dano (BillboardGui)

- Cada acerto em inimigo mostra o valor do dano num BillboardGui na região do inimigo (DEC-013).
- O número sobe e some. **Provisório**: sobe ~2 studs em 0,8 s, com fade no final; posição horizontal com leve deslocamento aleatório para números não se sobreporem.
- Dano de habilidade com destaque (maior e cor diferente) — **Provisório**.
- Só visual, no client. O valor vem do servidor.
- Mobile: limite de números simultâneos por inimigo — **Provisório** 10; acima disso, o mais antigo some.
- Formatação de números grandes (1,2K, 3,4M) — **Provisório**; necessário no jogo completo.
- No v0: Sim.

## FEAT-021 — Comando "parar de atacar"

- O player pode mandar os pets pararem de atacar o alvo atual (DEC-013).
- Ao parar: pets saem do alvo e voltam a seguir o player. O dano acumulado no inimigo continua valendo (DEC-011).
- Forma do comando: **Provisório** (Q-030) — tocar de novo no mesmo inimigo alterna atacar/parar + botão "Parar" na HUD.
- No v0: Sim.

## FEAT-022 — Habilidades e animações de pet

- Pets tocam animações: parado, andar/correr, combate (FEAT-024), habilidade, **Assistência** (DEC-013, DEC-023).
- Categorias de animação de combate por personagem (DEC-023): **Combate** (Combate 1, Combate 2, Back Off), **Skill**, **Assistência** (ataque à distância / suporte, para pets fora de cena).
- Pet ataca sozinho (DEC-016).
- Cada personagem tem **1 habilidade própria**, com **cooldown próprio** (DEC-016, DEC-022).
- Uso da habilidade: automático ou manual, conforme o toggle (FEAT-025, DEC-022).
- Habilidade identificada pelo `PET-###` (1 por personagem). Sem prefixo próprio por enquanto.
- Ao disparar, a habilidade interrompe a animação de combate em curso (DEC-020). Se o pet estava em Assistência, ele entra em cena para a Skill (**Provisório**).
- Valores **Provisórios** do v0: 50 de dano, cooldown 8 s, VFX placeholder. O cooldown começa a contar quando o pet chega ao alvo.
- No v0: Sim. Critério A9 (alterado por DEC-022): com auto ligado, a habilidade de cada pet dispara sozinha ao fim do cooldown dele e causa dano maior; os slots não respondem a toque.

## FEAT-023 — Integração de assets do contratante

- Modelos 3D, mapa e VFX vêm do contratante (DEC-012, DEC-014).
- O código não referencia modelo, animação ou VFX direto: tudo passa por dados (tabela de conteúdo por pet/inimigo apontando para modelo, IDs de animação e VFX). Trocar asset = trocar dado (critério A13 do DEC-013).

### Formato dos modelos (DEC-019)

| Tipo | Rig | Animação |
|---|---|---|
| Personagens / pets (maioria) | R6 | AnimationController + Animator; `LoadAnimation` |
| Inimigos comuns | R6 (mesmos personagens) | idem |
| Bosses | rig custom | idem |

- Pivô do modelo no **pé** (usuário ajusta). O código posiciona o modelo pelo pivô.
- Animações finais ainda em produção pelo animador do contratante. v0 usa placeholder.
- Pendente: dono das animações, formato de VFX, pacote de amostra (Q-036). Placeholder do v0: rig **R6** com AnimationController (DEC-028); origem do modelo em Q-027.
- Animações esperadas por personagem: Combate 1, Combate 2, Back Off, Skill, Assistência, além de parado e andar (DEC-023; estrutura final em Q-032).
- Direitos de uso: Q-019.
- No v0: Sim.

## FEAT-024 — Combate coreografado e state manager

Status: **Rascunho**. Inspiração: "luta ensaiada" de Dragon Ball Budokai Tenkaichi (referência de estilo, nada de IP copiada).

### Decidido (DEC-020)

- Um **state manager** sincroniza o estado de cada personagem em combate.
- Vários pets no mesmo inimigo: **dano de todos ao mesmo tempo**, **uma animação de combate por vez** (combos em sequência).
- **Skills interrompem** a animação de combate padrão.
- Dano (servidor, ritmo de cada pet) e animação (apresentação) são separados.

### Decidido (DEC-023, DEC-024)

- A sequência de animação é **por jogador**: cada jogador vê a própria sequência com os próprios pets. "Uma animação por vez" vale dentro da sequência de cada jogador.
- Pets do jogador fora de cena ficam **próximos** do alvo fazendo **Assistência** (ataque à distância / suporte). O pet principal faz a coreografia.
- Alvo morre → todos os pets voltam para o dono (DEC-024).

### Proposta ao contratante (não aprovada, Q-032)

- Cada personagem: 2 animações de ataque passivas (Combate 1, Combate 2) + 1 animação de skill.
- 2 rigs animados por vez: o que bate e o que apanha. O que apanha simula defesa enquanto leva dano.
- Mini teleportes temáticos por personagem: substituição, teleporte instantâneo, passo rápido; aparecer no céu/chão, empurrar, arremessar.
- Sequência por personagem: Combate 1 → Combate 2 → Skill (se pronta) → Back Off (empurra o inimigo e sai de cena para o próximo pet ou skill entrar).

### Estados (Provisório)

| Estado | Quando | Sai para |
|---|---|---|
| Seguindo | sem alvo | IndoAoAlvo |
| IndoAoAlvo | player escolheu alvo | Esperando |
| Assistência | no alvo, fora da vez de animar (continua causando dano; toca animação de Assistência, DEC-023) | Combate1 (na vez) ou Skill |
| Combate1 | vez do pet | Combate2, ou Skill se interrompido |
| Combate2 | fim do Combate1 | Skill (se pronta) ou BackOff |
| Skill | skill disparada (auto ao fim do cooldown, ou toque no slot com auto desligado) | BackOff |
| BackOff | fim da sequência | Assistência; passa a vez ao próximo pet do mesmo jogador |

- Qualquer estado → Seguindo quando o alvo morre (DEC-024) ou o player manda parar (FEAT-021).
- Estados extras (Seguindo, IndoAoAlvo) são do agente, **Provisório**. "Esperando" virou "Assistência" (DEC-023).
- Duas skills prontas ao mesmo tempo no mesmo jogador: o dano de cada uma sai na hora do disparo; as animações entram em fila, 0,3 s entre cada (**Provisório**).

### No v0 (Provisório)

- Sequência de animação por jogador (DEC-023).
- Pets em Assistência em círculo a ~6 studs do alvo.
- Pets de outros jogadores no mesmo inimigo (Q-037, **Provisório**): aparecem no anel em volta do alvo, só com animação de Assistência; nunca entram em cena na tela de outro jogador. Cada jogador vê só os próprios números de dano.
- Inimigo: animação de "apanhar" segue a sequência do próprio jogador (cada client anima o inimigo localmente).
- Duração de cada estado = duração da animação placeholder; alvo: Combate 1 0,8 s, Combate 2 0,8 s, Skill 1,2 s, Back Off 0,5 s.
- Teleporte = reposicionamento instantâneo simples ao entrar na vez e ao sair no Back Off.
- Inimigo toca animação placeholder de "apanhar" enquanto um pet anima nele.
- Critérios: A15 (dano dos 3 junto, 1 animação por vez) e A16 (skill interrompe combate), DEC-020; A18 (Assistência) e A19 (dois jogadores, cada um vê a própria sequência), DEC-023.

## FEAT-025 — Toggle de uso automático e skill manual por slot

Substitui o antigo botão "forçar habilidades" (DEC-016, revisado por DEC-022). Não existe botão "forçar todos" nem cooldown global.

- Cada pet tem **cooldown de skill próprio**. HUD mostra 1 slot por pet equipado.
- **Toggle "uso automático de skills"** na HUD (liga/desliga).

| Estado do toggle | Comportamento | Slot do pet na HUD |
|---|---|---|
| Ligado | pet usa a skill sozinho quando o cooldown dele termina | não clicável; círculo verde girando ao redor do slot (detalhe de UI, conforme Figma) |
| Desligado | jogador toca no slot do pet para usar a skill daquele pet | mostra o cooldown; clicável só quando pronto |

- Regras de borda **Provisórias** (DEC-022):
  - Estado inicial do toggle: ligado.
  - Skill manual só com alvo ativo e o pet já no alvo; fora disso o toque não faz nada.
  - Skill pronta em modo manual espera o toque, sem limite de tempo.
  - Ligar o auto com skills prontas: disparam em ordem de slot, 0,3 s entre cada.
  - Usar a skill (auto ou manual) reinicia o cooldown só daquele pet.
  - Slot em cooldown mostra o progresso; visual exato conforme Figma.
  - Estado do toggle não é salvo no v0 (sem persistência).
- Critérios (DEC-022): A9 (auto ligado) e A14 (auto desligado, toque no slot).
- No v0: Sim.

## FEAT-026 — Loja

- Tela já desenhada no Figma (DEC-018).
- O que vende: A definir (Q-035, Q-015).
- No v0: só visual.

## FEAT-027 — Battle Pass

- Tela já desenhada no Figma (DEC-018).
- Se existe no jogo completo, estrutura e preço: A definir (Q-035, Q-015).
- No v0: só visual.

## FEAT-028 — Bosses

Status: **Rascunho**.

- Monstros chefões com rig custom, feitos pelo contratante (DEC-019).
- Mais fortes que os inimigos comuns. Dão **mais experiência e mais dinheiro** ao pet/jogador (DEC-026).
- **Opcionais**, exceto quando uma missão exige (FEAT-029).
- Recompensas valiosas: equipamentos de pet (FEAT-030), gemas, pó estelar, itens de upgrade/merge (FEAT-031).
- Spawn, respawn, quantidade por ilha, vida, recompensa e regra de drop: A definir (Q-041). Se atacam: Q-018.
- Fora do v0.

## FEAT-029 — Missões progressivas

Status: **Rascunho** (DEC-027).

- Missões progressivas que exigem, cada vez mais, derrotar bosses (DEC-026).
- Completar missão dá recompensa.
- Formato (cadeia/lista/diárias), tipos de objetivo, recompensas, o que destravam, quem dá a missão: A definir (Q-040).
- Fora do v0.

## FEAT-030 — Equipamentos de pet

Status: **Rascunho** (DEC-027).

- Cada pet tem **slots de equipamento**.
- Equipamentos vêm de bosses (DEC-026); outras fontes em Q-038.
- Número de slots, tipos, efeito, raridade, upgrade e se o equipamento move entre pets: A definir (Q-038).
- Persistência: entra no perfil do jogador (FEAT-016).
- Fora do v0.

## FEAT-031 — Recursos secundários

Status: **Rascunho** (DEC-027).

| Recurso | Fonte conhecida | Uso |
|---|---|---|
| Gemas | bosses (DEC-026) | A definir (Q-039) |
| Pó estelar | bosses (DEC-026) | A definir (Q-039) |
| Itens de upgrade/merge | bosses (DEC-026) | A definir (Q-039); possível relação com fusão (FEAT-011) e equipamentos (FEAT-030) |

- Persistência: entram no perfil do jogador (FEAT-016).
- Venda por Robux: liga com Q-015.
- Fora do v0.
