# Visão

Status: Rascunho

Fontes: DEC-002 a DEC-028. Itens marcados **Proposta** ainda não foram decididos pelo usuário.

## Pitch

Simulador de DPS com temática anime. Você bate em inimigos parados numa ilha, ganha dinheiro, abre
ovos e recebe personagens que viram seus pets. Com um toque no inimigo, sua tropa de pets corre e
ataca. Fique mais forte, enfrente os inimigos mais fortes da ilha e avance para a próxima.

## Gênero e referências

- Gênero: simulador de DPS / pet simulator com foco em dano (DEC-002).
- Mundo: várias ilhas, cada uma com **tema de gênero** de anime, não de obra (DEC-003, DEC-025).
- Personagens **originais**, inspirados em arquétipos comuns de anime. Nenhum nome, personagem, golpe ou visual de obra real (DEC-025).
- Combate: "luta ensaiada" coreografada (referência de estilo: Budokai Tenkaichi) — dano simultâneo de todos os pets, uma animação de combate por vez **por jogador**, pets fora de cena em Assistência, skills interrompem (DEC-020, DEC-023, FEAT-024).
- Skills: cooldown por pet, toggle de uso automático ou toque manual no slot do pet (DEC-022).
- Referências: Budokai Tenkaichi (combate, só estilo); demais a definir (Q-023).

## Público e plataformas

| Item | Valor | Fonte |
|---|---|---|
| Plataformas | PC e mobile | DEC-008 |
| Prioridade | mobile primeiro | DEC-008 |
| Público | 10–16 anos, fãs de anime | DEC-008 |
| Lobby | não existe; a ilha 1 é o lobby | DEC-009 |

## Contratante e entrega

| Item | Valor | Fonte |
|---|---|---|
| Entrega final | jogo completo, publicado | DEC-012 |
| Prazo de publicação | não definido (fala ambígua) | DEC-012, Q-024 |
| Remuneração do usuário | porcentagem do projeto (revenue share), sem pagamento direto | DEC-012 |
| Papel do contratante | modelador e Project Manager | DEC-014 |
| Modelos 3D e VFX | fornecidos pelo contratante; alguns personagens já prontos; animações em produção | DEC-012, DEC-014, DEC-019 |
| Formato dos assets do contratante | R6 (maioria), bosses rig custom, AnimationController + Animator, pivô no pé; VFX e dono das animações a definir | DEC-019, Q-036 |
| Mapa | contratante faz as ilhas finais (ainda não existem); usuário monta mapa de teste numa baseplate | DEC-014 |
| Primeira entrega | Protótipo de apresentação (v0) | DEC-013 |
| Código do v0 | liberado (bandeira verde parcial), em paralelo ao mapeamento | DEC-015 |

### Protótipo de apresentação (v0)

Objetivo: provar ao contratante que a parte do dev está pronta e que só falta receber os assets dele.

Entra:

1. Inimigo parado tomando dano e respawnando.
2. Pets vão até o alvo tocado/clicado e atacam.
3. Comando para parar de atacar.
4. Dano real aplicado no servidor.
5. Números de dano em BillboardGui subindo na região do inimigo.
6. Animações e habilidades dos pets: cooldown por pet + toggle de uso automático / toque manual no slot (DEC-022).
7. Combate coreografado com state manager: dano simultâneo, uma animação por vez por jogador, pets fora de cena em Assistência, skill interrompe, alvo morto → pets voltam (DEC-020, DEC-023, DEC-024).
8. UI do Figma: HUD principal funcional + Inventário, Loja e Battle Pass só visuais (DEC-017, DEC-018).
9. Dinheiro ao matar inimigo, proporcional ao dano, mostrado na HUD (DEC-021).

Fica fora: ovos, raridades, level/XP, venda, fusão, persistência real, monetização, trading, várias ilhas, ataque do player, bosses, missões, equipamentos, gemas, pó estelar.

Critérios de aceite: A1–A13 em DEC-013; A10 alterado por DEC-018; A9 e A14 alterados por DEC-022; A15–A16 por DEC-020; A17 por DEC-021; A18–A19 por DEC-023. Código liberado por DEC-015. Propostas técnicas aceitas em DEC-028.

## Pilares

**Proposta** (não aprovada). Pilar serve para desempatar decisões de design.

1. **Número subindo sempre.** Todo minuto de jogo dá um ganho visível: dinheiro, pet novo, level, estrela.
2. **Comandar, não suar.** Pouco input, muita recompensa: um toque escolhe o alvo, os pets fazem o resto.
3. **Coleção que dá vontade de completar.** Cada ilha tem seu ovo, suas raridades e seus pets para colecionar.
4. **Mobile primeiro.** Tudo jogável com um polegar, em celular fraco, em tela pequena.

## Loop de jogo

### Loop de minutos

```
bater nos inimigos (player e/ou pets)
  → inimigo morre → dinheiro
  → abrir ovo da ilha → pet novo
  → equipar melhores pets → mais dano
  → enfrentar inimigo mais forte da ilha
```

### Loop de sessão

```
levelar pets (Q-009) → vender pets fracos → fundir idênticos (estrelas)
  → derrotar os inimigos mais fortes da ilha
  → desbloquear próxima ilha (Q-013) → novo ovo, novos inimigos
```

### Loop de longo prazo

- Decidido (DEC-026, DEC-027): missões progressivas que exigem bosses → bosses dão equipamentos de pet, gemas, pó estelar, itens de upgrade/merge → pets mais fortes. Pets ganham XP lutando.
- A definir: estrutura de missões (Q-040), equipamentos (Q-038), uso dos recursos (Q-039), bosses (Q-041), rebirth (Q-014), coleção completa por ilha, trading (Q-016), eventos.

## Pontos em aberto deste documento

Q-013, Q-014, Q-016, Q-023, Q-024, Q-032, Q-035, Q-036, Q-037, Q-038, Q-039, Q-040, Q-041.
