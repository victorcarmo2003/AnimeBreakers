# AnimeBreakers — Documento de design (índice)

Fonte da verdade do projeto. Regras de IDs, status e autoridade: `../CLAUDE.md`. Fluxo: `PIPELINE.md`.

## Progresso da pré-produção

Ordem da entrevista da `secretary`. A lista de temas é ajustada depois do tema 1 (gênero define o resto).
Bandeira verde quando tudo estiver **Aprovado** e `open-questions.md` sem bloqueante.

| # | Tema | Documento | Status |
|---|---|---|---|
| 1 | Visão, gênero, público, plataformas, contratante | `vision.md` | Vazio |
| 2 | Pilares e loop de jogo | `vision.md` | Vazio |
| 3 | Features e mecânicas | `design/features.md` | Vazio |
| 4 | Personagens jogáveis / classes / poderes | `design/` | Vazio |
| 5 | Combate e habilidades | `design/` | Vazio |
| 6 | Inimigos e chefes | `design/` | Vazio |
| 7 | Modos de jogo e mapas | `levels/` | Vazio |
| 8 | História e personagens | `story/` | Vazio |
| 9 | Progressão | `design/progression.md` | Vazio |
| 10 | Economia, loot e monetização | `design/economy.md` | Vazio |
| 11 | Direção de arte e orçamento técnico | `art/style-guide.md` | Vazio |
| 12 | Lista de assets | `art/asset-list.md` | Vazio |
| 13 | Áudio | `art/style-guide.md` (seção Áudio) | Vazio |
| 14 | UI/UX e HUD | `design/features.md` (seção UI) | Vazio |
| 15 | Arquitetura técnica | `tech/architecture.md` | Vazio |
| 16 | Escopo, prazos e roadmap | `PIPELINE.md` | Vazio |

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
