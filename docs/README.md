# AnimeBreakers — Documento de design (índice)

Fonte da verdade do projeto. Regras de IDs, status e autoridade: `../CLAUDE.md`. Fluxo: `PIPELINE.md`.

## Progresso da pré-produção

Ordem da entrevista da `secretary`. Lista ajustada em 2026-10-03 ao gênero simulador de DPS com pets (DEC-002).
Bandeira verde quando tudo estiver **Aprovado** e `open-questions.md` sem bloqueante.

| # | Tema | Documento | Status | Perguntas abertas |
|---|---|---|---|---|
| 1 | Visão, gênero, público, plataformas, contratante, primeira entrega | `vision.md` | Rascunho (contratante, mapa e v0 registrados) | Q-023, Q-024 |
| 2 | Pilares e loop de jogo | `vision.md` | Rascunho (pilares em proposta) | — |
| 3 | Índice de features | `design/features.md` | Rascunho (FEAT-001 a FEAT-031) | — |
| 4 | Propriedade intelectual e tema das ilhas/personagens | `vision.md` + `story/` | Decidido (DEC-025: originais, tema de gênero) | — |
| 5 | Combate: player, pets, comando, habilidades, coreografia, multiplayer | `design/features.md` (FEAT-022, 024, 025); `design/combat.md` (a criar) | Rascunho (DEC-020, DEC-022, DEC-023, DEC-024) | Q-007 B, Q-018 B, Q-030, Q-032 B, Q-037 |
| 6 | Ilhas, inimigos, bosses e assets do contratante (`ISL`, `ENM`) | `design/islands.md`, `design/enemies.md` (a criar) | Rascunho (formato DEC-019, mapa DEC-014, bosses DEC-026) | Q-019, Q-027, Q-036, Q-041 B |
| 7 | Pets, ovos, raridades e equipamentos (`PET`, `EGG`) | `design/pets.md` (a criar) | Vazio (equipamentos em Rascunho, FEAT-030) | Q-008 B, Q-010 B, Q-021, Q-038 B |
| 8 | Level/XP de pet, fusão e estrelas | `design/progression.md` (a criar) | Rascunho parcial (XP por combate, DEC-027) | Q-009 B, Q-011 B |
| 9 | Progressão entre ilhas, missões e rebirth | `design/progression.md` (a criar) | Rascunho parcial (missões DEC-026/027) | Q-013 B, Q-014 B, Q-040 B |
| 10 | Economia: dinheiro, gemas, pó estelar, custo de ovo, chances, venda | `design/economy.md` (a criar) | Vazio (dinheiro no v0, DEC-021) | Q-012 B, Q-039 B |
| 11 | Monetização, Loja, Battle Pass e regras do Roblox (`GP`, `DP`) | `design/monetization.md` (a criar) | Vazio | Q-015 B, Q-035 B |
| 12 | Social: servidor, trading | `design/features.md` | Vazio | Q-016 B, Q-020 |
| 13 | UI/UX mobile-first e importação do Figma | `design/features.md` (FEAT-015); `design/ui.md` (a criar) | Rascunho (método DEC-017, telas DEC-018) | — |
| 14 | Direção de arte e orçamento técnico | `art/style-guide.md` | Vazio | — |
| 15 | Lista de assets | `art/asset-list.md` | Vazio | — |
| 16 | Áudio | `art/style-guide.md` (seção Áudio) | Vazio | — |
| 17 | Arquitetura técnica | `tech/architecture.md` | Rascunho (propostas do v0 aceitas, DEC-028) | Q-036 (T-02) |
| 18 | Roadmap e prazos | `PIPELINE.md` | Rascunho (v0 liberado, DEC-015) | Q-024 |

Última sessão: 2026-10-03 (rodada 4: DEC-021 a DEC-028).

- **Bandeira verde parcial dada para o v0 (DEC-015).** Código do v0 em andamento em paralelo.
- Bloqueantes para o **jogo completo** (bandeira verde): 17 — Q-007, Q-008, Q-009, Q-010, Q-011, Q-012, Q-013, Q-014, Q-015, Q-016, Q-018, Q-032, Q-035, Q-038, Q-039, Q-040, Q-041.
- Bloqueantes para o **Protótipo v0**: 0. Pendências do v0 seguem com valores **Provisórios** (Q-027, Q-030, Q-032, Q-037).
- `tech/architecture.md` precisa refletir DEC-021 a DEC-024 e DEC-028 (sequência por jogador, toggle no lugar de PT-13, Assistência) — tarefa do `architect`.

Mapas: ilhas finais são do contratante; usuário monta mapa de teste numa baseplate (DEC-014).

## Mapa de arquivos

```
docs/
  vision.md              pitch, gênero, público, plataformas, pilares, loop
  decisions.md           DEC-### (append-only)
  open-questions.md      Q-###
  design/                features, progressão, economia e fichas do jogo
  story/                 lore, characters, campaign
  levels/                LVL-## (mapas/áreas)
  art/                   style-guide, asset-list, credits
  tech/                  architecture, network, data, content-data
  tasks/board.md         TASK-###
  research/              relatórios do researcher
  tests/                 planos de teste do qa-tester
```
