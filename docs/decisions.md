# Decisões

Append-only. Decisão revertida ganha nova entrada que cita a anterior; a antiga não é apagada.

Formato: `DEC-### — AAAA-MM-DD — título` + o que foi decidido + impacto.

---

### DEC-001 — 2026-10-03 — Regras de código do projeto

- Código sem nenhum comentário.
- Sem `--!strict` nos arquivos: o `.luaurc` já força strict no projeto inteiro.
- Documentação em Markdown (`docs/`) e agentes (`.claude/`) seguem detalhados normalmente.
- Impacto: todos os agentes que escrevem código seguem a regra; código tocado tem comentários e `--!strict` removidos.

### DEC-002 — 2026-10-03 — Gênero e loop principal: simulador de DPS com pets

- Gênero: "simulador de DPS" com temática anime, no estilo pet simulator, com foco em dano.
- Loop: player bate nos inimigos → matar dá dinheiro → dinheiro abre ovos/caixas → ovos dão personagens que funcionam como pets → pets lutam no lugar do player → mais dano → inimigos mais fortes.
- Player vai ficando mais ocioso conforme ganha pets e passa a comandar as tropas.
- O usuário quer mapear tudo antes de programar (reforça a regra da Fase 0).
- Responde Q-001. Substitui a recomendação original de Q-001 (combate PvE de ondas), que não foi escolhida.
- Impacto: define `vision.md`, a lista de temas em `README.md`, os FEAT iniciais e os prefixos `ISL`, `ENM`, `PET`, `EGG`, `GP`, `DP` em `CLAUDE.md`.
- Ponto em aberto: uso de personagens de animes reais (ver Q-005, bloqueante).

### DEC-003 — 2026-10-03 — Ilhas temáticas e inimigos em posição fixa

- O jogo tem vários mapas. Cada mapa é uma **ilha** (`ISL-##`) com temática de um anime.
- Inimigos (`ENM-###`) são "personagens de anime" sortidos conforme o tema da ilha.
- Inimigos ficam **parados** em posições fixas. Cada posição é um bloco invisível (spawn point) colocado pelo usuário no mapa.
- Ao morrer, o inimigo renasce no mesmo spawn point após alguns segundos (tempo a definir, Q-012).
- Sem spawn aleatório.
- Dentro de cada ilha os inimigos ficam progressivamente mais fortes.
- Os mapas são produzidos pelo usuário com rigs/modelos que ele já tem. Layout não é detalhado agora.
- Impacto: FEAT-001, FEAT-002. `level-designer` não desenha layout de ilha até o usuário pedir.

### DEC-004 — 2026-10-03 — Pets, ovos e comando por clique

- Ovos/caixas (`EGG-##`) são comprados com dinheiro e dão personagens que funcionam como pets (`PET-###`).
- Cada ilha tem o seu ovo, com personagens daquela ilha.
- Pets lutam no lugar do player. O player clica num inimigo; os pets vão até ele e combatem.
- Progressão por ilha: derrotar os inimigos fracos → abrir o ovo da ilha → pets mais fortes → enfrentar os inimigos fortes.
- Impacto: FEAT-005, FEAT-006, FEAT-007, FEAT-013.

### DEC-005 — 2026-10-03 — Raridades (template provisório)

- Template inicial, na ordem dita pelo usuário: Comum, Incomum, Raro, Lendário, Épico, Mítico.
- **Provisório**: a lista não está fechada e a ordem Lendário/Épico precisa de confirmação (Q-010).
- Impacto: FEAT-008. Chances por raridade em Q-012.

### DEC-006 — 2026-10-03 — Level de pet e venda

- Pets têm level.
- Subir level aumenta o dano do pet e o valor de venda.
- O player pode vender pets por dinheiro.
- Fórmulas, forma de ganhar level e valores: a definir (Q-009, Q-012).
- Impacto: FEAT-009, FEAT-010.

### DEC-007 — 2026-10-03 — Fusão e estrelas

- Só pets idênticos podem ser fundidos.
- Fusão dá estrelas ao pet.
- Mais estrelas = maior multiplicador sobre o status base.
- Multiplicadores ainda não definidos: usar valores **Provisórios** (ver FEAT-011 e Q-011).
- Impacto: FEAT-011.

### DEC-008 — 2026-10-03 — Plataformas e público

- Plataformas: PC e mobile, com **prioridade mobile**.
- Público: 10–16 anos, fãs de anime.
- Responde Q-003.
- Impacto: UI, controles e orçamento de performance projetados primeiro para celular (toque, tela pequena, hardware fraco).

### DEC-009 — 2026-10-03 — Ilha inicial funciona como lobby

- Não há lobby separado. A primeira ilha é o lobby.
- Pode mudar no futuro (nova decisão).
- Impacto: FEAT-014. Ponto de spawn, lojas e UI inicial ficam na ilha 1.

### DEC-010 — 2026-10-03 — UI já desenhada no Figma

- Boa parte da UI já existe no Figma, feita pelo usuário.
- O MCP do Figma não está disponível; só há exportação "Figma to JSON", considerada ruim.
- A importação vai exigir agrupar e separar as imagens corretamente. Método a definir (Q-017).
- Impacto: FEAT-015. `frontend-coder` implementa a UI a partir do Figma, não cria layout próprio.

### DEC-011 — 2026-10-03 — Inimigos compartilhados, dinheiro proporcional ao dano

- Inimigos são compartilhados entre todos os jogadores do servidor.
- Quando o inimigo morre, cada jogador que causou dano recebe dinheiro proporcional ao dano que causou (player + pets dele).
- Responde Q-006 (opção a).
- Impacto: FEAT-002, FEAT-004, FEAT-007. Servidor registra dano por jogador em cada inimigo vivo. Regras de borda **Provisórias** em FEAT-004.

### DEC-012 — 2026-10-03 — Contrato: jogo completo, revenue share, assets do contratante

- O contratante espera receber o **jogo completo, publicado**.
- Data de publicação: **não definida** (fala do usuário ambígua). Confirmação em Q-024 (não bloqueante).
- Não há pagamento direto. A remuneração do usuário é **porcentagem do projeto** (revenue share).
- **Modelos 3D e VFX vêm do contratante**, já prontos e de boa qualidade. O usuário está aguardando a entrega.
- O mapa ainda não existe.
- Responde Q-002.
- Impacto:
  - `modeler-3d` não produz modelos de personagem/pet/inimigo nem VFX finais; só placeholders se pedido (Q-027).
  - Formato dos assets do contratante passa a ser requisito técnico (Q-025).
  - Contradição com DEC-003 ("mapas produzidos pelo usuário com rigs/modelos que ele já tem"): ver Q-029.
  - Direitos sobre os assets do contratante: Q-019 revista.

### DEC-013 — 2026-10-03 — Primeira entrega: Protótipo de apresentação (v0)

- A primeira entrega é um **protótipo jogável para apresentar ao contratante**.
- Objetivo: mostrar que a parte do dev está pronta e que só falta receber os assets do contratante. Efeitos extras entram aos poucos depois.
- Escopo do v0:
  1. Inimigo parado tomando dano e respawnando.
  2. Pets vão até o alvo clicado/tocado e atacam.
  3. Comando para os pets pararem de atacar o alvo.
  4. O alvo de fato recebe dano (vida diminui no servidor).
  5. Números de dano subindo na tela, na região do inimigo (BillboardGui).
  6. Animações e habilidades dos pets tocando.
  7. UI do Figma importada e funcionando.
- Fora do v0 (não citado pelo usuário): dinheiro, ovos, raridades, level, venda, fusão, inventário completo, persistência, monetização, trading, várias ilhas, ataque do player. Ataque do player fica fora até Q-007.
- Critérios de aceite verificáveis do v0:

| # | Critério | Como verificar |
|---|---|---|
| A1 | Inimigo nasce no spawn point ao iniciar o servidor e fica parado | entrar no jogo; inimigo está no bloco de spawn, não se move |
| A2 | Inimigo tem vida visível que diminui a cada acerto | barra/valor de vida cai a cada golpe |
| A3 | Vida chega a 0 → inimigo some → renasce no mesmo spawn point com vida cheia após o tempo de respawn | cronometrar; posição igual à do spawn |
| A4 | Tocar/clicar no inimigo faz todos os pets equipados irem até ele e atacarem | funciona com toque (mobile/emulador) e clique (PC) |
| A5 | Comando "parar" faz os pets pararem de atacar e voltarem ao player | inimigo para de perder vida; pets retornam |
| A6 | Dano é calculado e aplicado no servidor | dois clients veem a mesma vida; client não altera vida sozinho |
| A7 | Cada acerto mostra número de dano em BillboardGui acima do inimigo, subindo e sumindo | número aparece por acerto, com o valor certo |
| A8 | Pets tocam animação de andar, ataque básico e habilidade | animações visíveis nos momentos certos |
| A9 | Habilidade do pet dispara com cooldown e causa dano | dano maior aparece no intervalo do cooldown (regras em Q-026) |
| A10 | Telas do Figma definidas para o v0 aparecem e respondem a toque | lista de telas em Q-022 |
| A11 | Dois jogadores no mesmo servidor atacam o mesmo inimigo sem erro | teste com 2 clients no Studio |
| A12 | Roda em celular sem queda perceptível de FPS com 1 inimigo e pets de 2 jogadores | teste em dispositivo/emulador mobile |
| A13 | Trocar placeholder por asset do contratante não exige mudar código, só dados/arquivo | substituir 1 modelo e 1 animação de teste (depende de Q-025) |

- Números do v0 são **Provisórios** (FEAT-002, FEAT-006, FEAT-022).
- Responde Q-004 (nenhuma das opções originais; escopo novo dado pelo usuário).
- Impacto: `PIPELINE.md` (Fase 2 vira "Protótipo de apresentação (v0)"), FEAT-020, FEAT-021, FEAT-022, FEAT-023 criados, coluna v0 em `features.md` e `open-questions.md`. Liberação de código para o v0 antes da bandeira verde completa: Q-028.

### DEC-014 — 2026-10-03 — Contratante faz mapa e modelos (corrige DEC-003)

- O contratante é **modelador e Project Manager**. Ele produz o mapa (ilhas) e os modelos.
- Já tem alguns personagens prontos. O mapa ainda não existe.
- Para começar, o usuário monta um **mapa de teste simples numa baseplate**.
- **Corrige DEC-003**, item "Os mapas são produzidos pelo usuário com rigs/modelos que ele já tem". Vale agora: ilhas finais vêm do contratante; o usuário só faz o mapa de teste. O resto de DEC-003 (ilhas temáticas, spawn fixo, respawn) continua valendo.
- Spawn points (blocos invisíveis): quem coloca nas ilhas finais fica com o fluxo de integração do mapa (**Provisório**: o usuário coloca, como em DEC-003).
- Responde Q-029 (opção b).
- Impacto: FEAT-001, FEAT-014, FEAT-023. `level-designer` e `modeler-3d` não produzem ilhas nem modelos finais.

### DEC-015 — 2026-10-03 — Bandeira verde parcial: código do v0 liberado

- O código do **Protótipo v0 (DEC-013)** começa **já**, em paralelo ao mapeamento.
- O agente pode criar a base técnica que julgar necessária para o v0.
- Só o escopo do v0 está liberado. O resto do jogo segue em pré-produção até a bandeira verde completa.
- Dúvida nova do v0 segue a regra pós-bandeira: vira `Q-###` e o trabalho continua com valor **Provisório**.
- Responde Q-028 (opção a, sem esperar fechar as bloqueantes do v0).
- Impacto: `CLAUDE.md` seção "Fase atual" precisa refletir a liberação parcial; `PIPELINE.md` (Trilha E ativa para o v0).

### DEC-016 — 2026-10-03 — Habilidades: automáticas por tempo + botão "forçar"

- Pet ataca sozinho (ataque automático).
- Cada personagem tem **1 habilidade própria**, que recarrega com o tempo e é usada automaticamente quando pronta.
- O player tem um **botão para forçar** o uso das habilidades, para quando elas atrasam ou não são usadas.
- Ao forçar, **todos os pets equipados usam a habilidade ao mesmo tempo** (objetivo: DPS, dano simultâneo).
- Habilidade é identificada pelo personagem (1 por `PET-###`). Sem prefixo de ID próprio por enquanto.
- Regras de borda do botão (pets em recarga, recarga do botão): Q-031, **Provisório** em FEAT-025.
- Responde Q-026 (mistura das opções a e c).
- Altera critérios do DEC-013:
  - A9 passa a ser: habilidade de cada pet dispara sozinha ao fim da recarga e causa dano maior.
  - Novo A14: tocar no botão "forçar" faz todos os pets equipados com habilidade disponível usarem a habilidade no mesmo instante; o dano de todas aparece junto.
- Impacto: FEAT-022, FEAT-025.

### DEC-017 — 2026-10-03 — Método de importação da UI do Figma

- O usuário envia, por tela:
  1. elementos específicos exportados como **PNG**;
  2. o **JSON da estrutura** (exportação "Figma to JSON");
  3. uma **foto de referência** da tela inteira.
- O agente (`frontend-coder`) monta a tela em Vide comparando os PNGs e o JSON com a referência.
- O usuário revisa e dá direcionamentos de ajuste até a tela bater com o Figma.
- Responde Q-017.
- Impacto: FEAT-015. Upload dos PNGs como imagens no Roblox fica no fluxo de integração (ver Q-036).

### DEC-018 — 2026-10-03 — Telas do v0: as 4 telas do Figma

- O v0 importa **todas as telas que já existem no Figma**: **HUD principal, Inventário, Loja, Battle Pass**.
- **HUD principal**: recebe features reais de gameplay do v0.
- **Inventário, Loja, Battle Pass**: só visual (abrem, fecham, respondem a toque, sem lógica de sistema).
- Motivo: o contratante quer ver resultado.
- Responde Q-022.
- Altera DEC-013, critério A10: as 4 telas aparecem com visual fiel à referência e abrem/fecham por toque; o HUD executa as ações reais do v0.
- Impacto: FEAT-012 (no v0 vira só visual), FEAT-015, FEAT-026, FEAT-027.

### DEC-019 — 2026-10-03 — Formato dos assets do contratante

- Maioria dos personagens: **rig R6**.
- **Bosses** (monstros chefões): **rig custom**. Conceito de boss: Q-034.
- Todos os modelos têm **AnimationController com Animator** dentro. Animações tocam via `LoadAnimation` no Animator.
- O usuário ajusta o **pivô** dos modelos (personagens, bosses, pets) para a **posição do pé**.
- O animador do contratante ainda está fazendo as animações. O v0 usa **animações placeholder** até elas chegarem.
- Responde Q-025 (itens a e b em parte). Formato de VFX, dono das animações e pacote de amostra seguem em Q-036.
- Impacto: FEAT-023, FEAT-024. Código posiciona modelos pelo pivô no pé. Placeholder do v0 passa a ser R6 (Q-027).

### DEC-020 — 2026-10-03 — Combate coreografado: o que está decidido

- Existe um **state manager** que sincroniza em que estado cada personagem está (ex.: Combate 1, Combate 2, Skill, Back Off).
- Com vários pets atacando o mesmo inimigo: o inimigo recebe **dano de todos ao mesmo tempo**, mas **só uma animação de combate toca por vez** (combos em sequência, um pet depois do outro).
- **Skills interrompem** as animações de combate padrão.
- Dano e animação são separados: o dano segue o ritmo de cada pet; a animação é apresentação.
- O resto da proposta (estrutura Combate 1 → Combate 2 → Skill → Back Off, rig que apanha simulando defesa, mini teleportes temáticos) é **proposta enviada ao contratante**, ainda não aprovada: Q-032. Coreografia com vários jogadores e skills simultâneas: Q-033.
- Novos critérios do v0:
  - A15: com 3 pets no alvo, a vida cai pelo dano dos 3 ao mesmo tempo, mas só um pet toca animação de combate por vez.
  - A16: uma skill disparada interrompe a animação de combate em curso.
- Impacto: FEAT-024 (Rascunho), FEAT-022, FEAT-006.

### DEC-021 — 2026-10-03 — Dinheiro entra no v0 (corrige DEC-013)

- **Corrige DEC-013**, item "Fora do v0: dinheiro". Dinheiro passa a fazer parte do v0.
- Matar inimigo dá uma quantia de dinheiro. A quantia aparece na interface (HUD).
- Divisão entre jogadores segue DEC-011 (proporcional ao dano) e as regras Provisórias de FEAT-004.
- Sem uso do dinheiro no v0: Loja segue só visual (DEC-018). Sem persistência real (ver DEC-028, PT-09).
- Valor por inimigo do v0: **Provisório** 100 (FEAT-004). Curva do jogo completo segue em Q-012.
- Novo critério do v0:
  - A17: matar o inimigo soma dinheiro no contador da HUD de cada jogador que causou dano, na proporção do dano.
- Responde T-01 de `tech/architecture.md`.
- Impacto: FEAT-004 (v0 Parcial), FEAT-015 (HUD mostra dinheiro).

### DEC-022 — 2026-10-03 — Skills: cooldown por pet + toggle de uso automático (revisa DEC-016)

- **Revisa DEC-016.** Sai o botão "forçar" (todos os pets ao mesmo tempo). Não existe botão com cooldown próprio.
- Continua de DEC-016: ataque básico automático; 1 habilidade própria por personagem; cada pet tem **cooldown de habilidade próprio**.
- Novo: **toggle "uso automático de skills"** na HUD (liga/desliga).
  - **Auto ligado:** cada pet usa a skill sozinho quando o cooldown dele termina. O jogador **não consegue clicar** no slot. A UI mostra um círculo verde girando ao redor do slot daquele pet (detalhe de UI, entra conforme a interface for importada).
  - **Auto desligado:** o jogador toca no **slot do pet** na HUD para usar a skill daquele pet, quando o cooldown dele estiver pronto (uso manual).
- Regras de borda **Provisórias** (FEAT-025): estado inicial ligado; skill manual só com alvo ativo e pet já no alvo; skill pronta em modo manual espera o toque sem limite; ligar o auto com skills prontas dispara todas em ordem de slot, 0,3 s entre cada.
- Altera critérios do DEC-013/DEC-016:
  - A9 passa a ser: com auto ligado, a habilidade de cada pet dispara sozinha ao fim do cooldown dele e causa dano maior; os slots não respondem a toque.
  - A14 passa a ser: com auto desligado, tocar no slot de um pet com skill pronta faz aquele pet usar a skill (dano de skill aparece, animação interrompe o combate); slot em recarga não responde.
- Responde Q-031 (perde o objeto) e T-03 de `tech/architecture.md`. Substitui a proposta técnica PT-13.
- Impacto: FEAT-022, FEAT-025 (renomeada), FEAT-015.

### DEC-023 — 2026-10-03 — Coreografia por jogador + animação de Assistência

- A sequência de animação de combate é **por jogador**: cada jogador vê a própria sequência de combate com os próprios pets.
- A regra "uma animação de combate por vez" (DEC-020) vale **dentro da sequência de cada jogador**.
- Pets do mesmo jogador fora de cena ficam **próximos** do alvo fazendo ações leves.
- Nova **terceira categoria de animação: Assistência** (ataque à distância / suporte). Categorias por personagem: Combate (Combate 1, Combate 2, Back Off), Skill, Assistência.
- O pet principal faz a coreografia enquanto os outros fazem Assistência. Dano de todos continua simultâneo (DEC-020).
- **Provisório** (o usuário não disse): como os pets de **outros jogadores** aparecem no mesmo inimigo. Valor do v0 em FEAT-024; pergunta em Q-037 (não bloqueia o v0).
- Novos critérios do v0:
  - A18: com 3 pets no alvo, os 2 fora de cena tocam animação de Assistência perto do alvo enquanto o principal faz a coreografia.
  - A19: dois jogadores no mesmo inimigo veem cada um a sequência dos próprios pets, sem erro e com a mesma vida do inimigo.
- Responde Q-033 (itens a e b; item c perdeu o objeto com DEC-022) e T-05 de `tech/architecture.md` (troca a "pose de guarda" pela Assistência).
- Impacto: FEAT-024, Q-032 (estrutura de animações ganha Assistência), `tech/architecture.md` seções 5 e 6 (o `architect` ajusta o sequenciador para ser por jogador).

### DEC-024 — 2026-10-03 — Alvo morto: pets voltam ao dono

- Quando o alvo morre, os pets voltam para o dono. Não procuram outro alvo sozinhos.
- Confirma o valor Provisório de FEAT-007. Responde T-06 de `tech/architecture.md`.
- Impacto: FEAT-007, FEAT-024.

### DEC-025 — 2026-10-03 — Propriedade intelectual: personagens originais

- Personagens (pets, inimigos, bosses) são **originais**, inspirados em **arquétipos comuns de anime** (ninja, espadachim, pirata, guerreiro de energia etc.).
- Ilhas têm **tema de gênero**, não de obra.
- Obras citadas antes (Naruto, Dragon Ball, Bleach, Budokai Tenkaichi) foram **só referência** de estilo e de combate. Nenhum nome, personagem, golpe, logo ou visual reconhecível delas entra no jogo.
- A regra de `CLAUDE.md` (nada de IP de anime existente) permanece sem mudança.
- Responde Q-005 (opção a).
- Impacto: FEAT-001, `vision.md`, tema 4 do `README.md`. Q-019 continua: o contratante deve confirmar por escrito que os modelos entregues são originais e de direito dele.

### DEC-026 — 2026-10-03 — Bosses: opcionais, exigidos por missão, recompensa valiosa

- Bosses são monstros mais fortes que dão **mais experiência e mais dinheiro** ao pet/jogador.
- **Não são obrigatórios**, exceto quando uma **missão** exige (DEC-027).
- Missões exigem, progressivamente, derrotar bosses para ganhar recompensa.
- Recompensas valiosas de boss: **equipamentos para pets, gemas, pó estelar, itens de upgrade/merge**.
- Rig custom (DEC-019). Se atacam: Q-018. Spawn, respawn, vida e tabela de drop: Q-041.
- Responde Q-034 (nenhuma das opções originais; papel novo dado pelo usuário). Boss deixa de ser a forma recomendada de desbloquear ilha (Q-013 atualizada).
- Impacto: FEAT-028, FEAT-013. Fora do v0.

### DEC-027 — 2026-10-03 — Novos sistemas do jogo completo

Fora do v0. Entram no jogo completo, como **Rascunho** até as perguntas fecharem.

- **Missões progressivas** (FEAT-029): exigem progressivamente derrotar bosses; dão recompensa. Estrutura: Q-040.
- **Equipamentos de pet com slots** (FEAT-030): cada pet tem slots de equipamento. Quantos, tipos e efeito: Q-038.
- **Recursos secundários** (FEAT-031): gemas, pó estelar, itens de upgrade/merge. Uso e fontes: Q-039.
- **Experiência de pet** (FEAT-009): pets ganham experiência ao lutar. Responde parte de Q-009 (fonte de XP = combate); curva, level máximo e XP do jogador seguem em Q-009.
- Impacto: `features.md`, `vision.md` (loop de longo prazo), temas 8 a 10 do `README.md`.

### DEC-028 — 2026-10-03 — Propostas técnicas do v0 (PT-01 a PT-15) aceitas

- O usuário não vetou nenhuma proposta de `tech/architecture.md` seção 0. Ficam **aceitas implicitamente para o v0**.
- Exceções, alteradas por decisões desta rodada:
  - **PT-13 (botão "Forçar skill" com cooldown global) substituída** pelo toggle de uso automático + uso manual por slot (DEC-022).
  - **PT-03 / PT-04 / PT-05:** a coreografia passa a ser **por jogador** (DEC-023). O dano continua por inimigo no servidor; o sequenciador de animação e o anel de posições precisam ser por jogador, com slots de Assistência.
- Respostas da seção 12:
  - T-01: dinheiro entra (DEC-021).
  - T-02: não respondida; segue em Q-036 (item a).
  - T-03: substituída pelo toggle (DEC-022).
  - T-04: placeholder em **R6**, com AnimationController (DEC-019).
  - T-05: substituída pela animação de Assistência (DEC-023).
  - T-06: pets voltam ao dono (DEC-024).
- Responde Q-027 quanto ao rig (R6). Origem do modelo placeholder segue Provisória em Q-027.
- Impacto: `tech/architecture.md` (o `architect` atualiza), FEAT-023, FEAT-024, FEAT-025.

### DEC-029 — 2026-10-03 — Missões: três categorias, uma ativa por categoria

- Três categorias de missão: **principais**, **secundárias** e **diárias**.
- O jogador tem no máximo **uma missão ativa por categoria** ao mesmo tempo (até 3 ativas no total: 1 principal + 1 secundária + 1 diária).
- Missões **principais** e **secundárias** formam uma **sequência por ilha**.
- O jogador **não é obrigado** a terminar as missões de uma ilha. Pode pular e iniciar as missões de outra ilha.
- Aceitar uma missão nova da mesma categoria **sobrescreve** a ativa. A antiga é descartada.
- **Diárias** são uma categoria separada, fora da sequência por ilha.
- Responde Q-040 em parte (item a: formato). Seguem abertos em Q-040: tipos de objetivo, recompensas, o que a missão destrava, quem dá a missão, reset e quantidade de diárias, destino do progresso da missão descartada.
- Consequência para Q-013: como o jogador pode pular as missões de uma ilha, completar missão provavelmente **não** é o critério de desbloqueio da próxima ilha. Q-013 segue aberta.
- Impacto: FEAT-029, FEAT-013, Q-013.

### DEC-030 — 2026-10-03 — Gemas premium e uso do pó estelar

- **Gemas**: moeda **premium**. Ganhas no jogo e vendidas por Robux (recomendação de Q-039 aceita).
  - Onde se gastam: **Provisório**, conforme a recomendação: ovos especiais, slots, boosts. Lista final junto com a monetização (Q-015).
- **Pó estelar**: serve para **melhorar equipamentos** (FEAT-030) e **melhorar pets**.
  - Nota de interpretação: a transcrição da fala trouxe "pause NPCs". Registrado como **pets** (contexto: Q-039 perguntava sobre melhorar pet). Se estiver errado, o usuário corrige com nova decisão.
- Responde Q-039 em parte (itens a e b). Seguem abertos em Q-039: como o pó estelar melhora o pet (relação com level/XP e fusão), itens de upgrade/merge (item c) e fontes além de boss (item d).
- Impacto: FEAT-031, FEAT-030, FEAT-009, FEAT-018.

### DEC-031 — 2026-10-03 — Equipamentos: 3 slots por pet, bônus de status

- Cada pet tem **3 slots de equipamento** (recomendação de Q-038 aceita).
  - Tipos dos slots: **Provisório** Arma, Acessório, Amuleto (exemplo da recomendação; nomes podem mudar).
- Equipamento dá **bônus de status** (recomendação aceita). Ex.: % de dano, % de velocidade de ataque, redução de cooldown da skill. Sem efeitos especiais.
- Equipamento é melhorado com pó estelar (DEC-030).
- Responde Q-038 em parte (itens a e b). Seguem abertos em Q-038: raridade de equipamento, fontes além de boss, se o equipamento move entre pets (não respondido pelo usuário).
- Impacto: FEAT-030.

### DEC-032 — 2026-10-03 — Equipamento troca livremente entre pets

- Equipamento **não fica preso** ao pet. O jogador tira de um pet e coloca em outro **livremente**, sem custo e sem perder melhorias.
- Responde Q-038 item e (recomendação aceita).
- Regras de borda **Provisórias** (FEAT-030): equipamento fica com o nível de melhoria ao trocar de pet; vender ou fundir um pet devolve os equipamentos dele ao inventário.
- Seguem abertos em Q-038: raridade, níveis e custo de melhoria (c) e fontes além de boss (d).
- Impacto: FEAT-030, FEAT-010, FEAT-011, FEAT-016.

### DEC-033 — 2026-10-03 — Pó estelar dá XP ao pet; XP passiva por derrotar inimigos

- O pó estelar (o usuário fala "pó instelar") dá **experiência** ao pet. O pet sobe de level com essa XP.
- O jogador **escolhe em qual pet** usar o pó.
- Pets também ganham XP **passivamente** ao derrotar inimigos (confirma DEC-027).
- Papel do pó: bônus para upar mais rápido, ou para upar logo pets recém-adquiridos.
- Pó estelar segue servindo também para melhorar equipamentos (DEC-030).
- Responde Q-039 item b2 (opção 1, recomendação). Responde Q-009 item a em parte: XP vem de derrotar inimigos. Divisão da XP entre pets participantes segue em Q-009.
- Conversão pó → XP: **A definir** (Q-009, números com `game-designer`).
- Seguem abertos em Q-039: itens de upgrade/merge (c) e fontes de gemas e pó (d).
- Impacto: FEAT-009, FEAT-031.

### DEC-034 — 2026-10-03 — Missões: recompensas, diárias e missão descartada

Recomendações de Q-040 c, f, g aceitas. **Aprovadas, mas ajustáveis**: o usuário pode mudar depois sem que isso seja contradição (nova DEC registra a mudança).

- **Recompensas por categoria (c):**

| Categoria | Recompensa |
|---|---|
| Principal | equipamento e/ou gemas |
| Secundária | pó estelar e/ou dinheiro |
| Diária | poucas gemas |

- **Diárias (f):** 3 por dia, reset às **00:00 UTC**, uma ativa por vez (DEC-029).
- **Missão descartada (g):** ao ser substituída, **perde o progresso**; volta a ficar disponível do zero.
- Quantidades exatas de cada recompensa: A definir (Q-012, `game-designer`).
- Ainda **Provisório** (não respondido): missão principal concluída não pode ser refeita.
- Seguem abertos em Q-040: tipos de objetivo (b), o que a missão destrava (d), quem dá a missão (e).
- Consequência para Q-039 d: missões e diárias passam a ser fonte de gemas e pó estelar.
- Impacto: FEAT-029, FEAT-031.

### DEC-035 — 2026-10-03 — Desbloqueio de ilha: passagem paga + gate de vida dos inimigos

Duas camadas:

1. **Comprar a passagem** para a próxima ilha com **dinheiro**.
   - Preço = valor mínimo calibrado. Exemplo do usuário: ~**5×** o dinheiro que o boss final da ilha atual rende ao morrer. **Provisório**.
2. **Gate natural de progressão**: inimigos da ilha seguinte têm **muita vida**. Com dano baixo, farmar lá não é economicamente viável.
   - Não há trava de acesso além da passagem; o gate é de balanceamento.

- Balanceamento por **vida** (local, por ilha) + por **dinheiro** (preço da passagem).
- Missão **não** é critério de desbloqueio (confirma a consequência de DEC-029). Boss não é obrigatório (DEC-026).
- Passagem comprada fica salva no perfil (FEAT-016).
- Responde Q-013 em parte (critério de desbloqueio; opção a, com camada extra de vida). Segue aberto: **quantas ilhas** no lançamento.
- Impacto: FEAT-001, FEAT-013, FEAT-004, Q-012 (curva de vida e preço da passagem por ilha).

### DEC-036 — 2026-10-03 — Propostas técnicas do v0 (PT-21 a PT-25) aceitas

Decisão técnica do `architect` (Revisão 3 de `tech/architecture.md`), resolvendo divergências apontadas pelo QA. **Aceitas para o v0; o usuário pode vetar** (nova DEC registra o veto).

| PT | Regra |
|---|---|
| PT-21 | Ledger de dano: o dano de quem sai do servidor **conta no denominador**; quem saiu **não recebe** a parte. |
| PT-22 | Cada cliente vê **só os números de dano dos próprios pets**. |
| PT-23 | Cooldown da skill conta a partir do **uso**. Pet começa com a skill **pronta**. Chegada ao alvo, Recall e troca de alvo **não** reiniciam o cooldown. |
| PT-24 | Dano da skill sai **0,4 s** após o uso (`HitDelay`). Usos do mesmo jogador ficam espaçados **0,3 s** (`SkillGap`). Valores **Provisórios**. |
| PT-25 | `DevService` existe **só no Studio**, para testes. |

- Impacto: FEAT-004, FEAT-022, FEAT-024, `tech/architecture.md`.

### DEC-037 — 2026-10-03 — Lançamento com 5 ilhas

- O jogo completo é lançado com **5 ilhas** no total (`ISL-01` a `ISL-05`). Pedido do PM/contratante.
- A ilha 1 continua sendo o lobby (DEC-009).
- Desbloqueio entre elas segue DEC-035 (4 passagens pagas: 1→2, 2→3, 3→4, 4→5).
- Responde Q-013 em parte (quantidade de ilhas; opção b). Segue aberto: onde se compra a passagem (Provisório: portal na borda da ilha).
- Impacto: FEAT-001, FEAT-013, Q-012 (curva de vida e preço da passagem para 5 ilhas), Q-041 (bosses por ilha × 5), escopo de assets do contratante.

### DEC-038 — 2026-10-03 — Mapa de teste do v0: 1 spawn normal + 1 spawn de boss (altera DEC-013)

- **Altera DEC-013** (escopo e critérios do v0) e o item "1 spawn point com 1 inimigo" de FEAT-002.
- O v0 **não tem ilha**. O mapa de teste (baseplate, DEC-014) tem **exatamente 2 spawn points**:
  1. 1 spawn de **inimigo normal** (`ENM-001`).
  2. 1 spawn de **boss** (placeholder).
- Objetivo: só testar mecânicas. Quando o contratante entregar o mapa, spawns e personagens são distribuídos conforme as features.
- Consequência: o v0 precisa de um **EnemyDef de boss placeholder**. Valores **Provisórios** (o usuário não deu números):
  - ID: `ENM-002`, marcado como boss nos dados.
  - Vida: 10.000 (×10 do normal). Dinheiro: 1.000 (×10). Respawn: 5 s (igual ao normal, para agilizar o teste).
  - Modelo: rig R6 placeholder em escala maior (~1,5×), com AnimationController + Animator. Rig custom real chega com o contratante (DEC-019).
  - Não ataca (Q-018). Sem drop de itens, sem XP (fora do v0).
- O mapa de dev atual (TASK-007) tem **3 spawns de `ENM-001`**: precisa virar 1 `ENM-001` + 1 `ENM-002`. Ajuste de tarefa fica com `task-planner`/`architect`.
- Critérios do v0 alterados:
  - A1 passa a ser: ao iniciar o servidor, o inimigo normal e o boss nascem cada um no seu spawn point e ficam parados.
  - A12 passa a ser: roda em celular sem queda perceptível de FPS com os 2 inimigos (normal + boss) e pets de 2 jogadores.
  - Novo A20: o boss usa os dados do próprio EnemyDef (vida, dinheiro, modelo maior); matar o boss soma o dinheiro do boss na HUD, dividido por dano (DEC-011); renasce no próprio spawn.
  - Novo A21: o mapa de teste tem só os 2 spawns; trocar qual inimigo nasce num spawn é só mudar o dado do spawn, sem mudar código.
- Impacto: FEAT-002, FEAT-028 (Parcial no v0), FEAT-001, `tasks/board.md` (TASK-007), `tests/`.

### DEC-039 — 2026-10-03 — Divisão de XP da morte do inimigo

- **Entre jogadores:** proporcional ao dano, como o dinheiro (DEC-011). Ex.: jogador A causou 40% do dano → recebe 40% da XP do inimigo.
- **Entre os pets do próprio jogador:** a parte dele é dividida **igualmente** entre os pets que ele tem **equipados no momento da morte** do inimigo (opção b de Q-009). Motivo: progressão linear, ajuda pets fracos.
- Regras de borda **Provisórias**: mesmas do dinheiro (overkill não conta, quem saiu perde a parte e o dano dele conta no denominador, PT-21); arredondar para baixo por pet.
- Responde Q-009 item a. Seguem abertos em Q-009: XP por 1 pó estelar (a2), level máximo e curva (b), XP/level do jogador (c).
- Impacto: FEAT-009. Fora do v0.

### DEC-040 — 2026-10-03 — Slots de pets equipados: 3 → 5 por progressão, 6º por Game Pass

- O jogador começa com **3 pets equipados**.
- Sobe até **5** por progressão no jogo.
- O **6º slot** é vendido por **Game Pass**.
- Valores base ajustáveis pelo usuário (mudança vira nova DEC, não contradição).
- Responde Q-008 em parte. Segue aberto: **como** sobe de 3 para 5 (o que libera o 4º e o 5º) e botão "equipar melhores".
- v0 continua com 3 pets fixos (FEAT-006).
- Impacto: FEAT-006, FEAT-018 (primeiro Game Pass definido), FEAT-025 (HUD com até 6 slots), FEAT-024 (até 6 pets na sequência por jogador).
