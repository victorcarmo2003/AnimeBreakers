# Pipeline de produção

Como os agentes trabalham juntos e em paralelo.

## Fases

| Fase | Objetivo | Saída | Gate |
|---|---|---|---|
| 0. Pré-produção | mapear o jogo inteiro | GDD completo em `docs/` | **bandeira verde** do usuário (`DEC-###`); parcial para o v0 já dada (DEC-015) |
| 1. Fundação técnica | arquitetura + sistemas núcleo | `docs/tech/architecture.md` + código | QA verde no núcleo |
| 2. Protótipo de apresentação (v0) | provar ao contratante que a parte do dev está pronta e só faltam os assets dele (DEC-013) | protótipo jogável com os itens abaixo | critérios A1–A13 (DEC-013) + aprovação do usuário |
| 3. Produção | jogo completo: economia, ovos, progressão, ilhas, persistência, monetização, assets do contratante | jogo completo publicado (DEC-012) | QA por entrega |
| 4. Polimento | balanceamento, performance, mobile, UX | release | playtest |

### Fase 2 — Protótipo de apresentação (v0)

Substitui a antiga "vertical slice" (DEC-013). Vem antes da produção completa.

Escopo:

1. Inimigo parado tomando dano e respawnando (FEAT-002).
2. Pets vão até o alvo tocado/clicado e atacam (FEAT-006, FEAT-007).
3. Comando "parar de atacar" (FEAT-021).
4. Dano real aplicado no servidor.
5. Números de dano em BillboardGui na região do inimigo (FEAT-020).
6. Animações e habilidades dos pets, com botão "forçar habilidades" (FEAT-022, FEAT-025).
7. Combate coreografado com state manager (FEAT-024).
8. UI do Figma: as 4 telas importadas — HUD principal com funções reais; Inventário, Loja e Battle Pass só visuais (FEAT-015, FEAT-012, FEAT-026, FEAT-027; DEC-017, DEC-018).
9. Assets trocáveis por dados, prontos para receber os do contratante (FEAT-023, DEC-019).

Fora: dinheiro, ovos, raridades, level, venda, fusão, persistência, monetização, trading, várias ilhas, ataque do player, bosses.

Mapa: mapa de teste simples numa baseplate, montado pelo usuário (DEC-014).

Arte: modelos R6 do contratante (se enviados) ou R6 padrão, animações placeholder (Q-027) até as finais chegarem. Efeitos extras entram aos poucos depois.

UI: depende do envio, pelo usuário, dos PNGs + JSON + foto de referência de cada tela (DEC-017).

Código do v0 **liberado** (DEC-015, bandeira verde parcial). Trilha E roda para o escopo do v0 em paralelo à Trilha A. Pergunta nova do v0 segue a regra "Sem o usuário" abaixo.

## Trilhas paralelas

Cada trilha roda numa sessão própria do Claude Code. Elas se comunicam **só por `docs/`**,
nunca por memória de conversa.

```
Trilha A  usuário + secretary           (design: perguntas, decisões, GDD)
            ├─ chama game-designer / narrative-writer / art-director para propor opções
Trilha B  modeler-3d                    (Blender: consome fichas AST Aprovadas)
Trilha C  level-designer                (conceito e blockout de mapas já descritos)
Trilha D  researcher                    (referências e viabilidade, sob demanda)
Trilha E  architect → task-planner → backend/frontend-coder → qa-tester   (v0 já liberado, DEC-015; resto após bandeira verde)
```

### Restrições físicas

- **Blender é um só.** Apenas uma sessão `modeler-3d`/`level-designer` usando o MCP do Blender por vez.
- **Um dono por arquivo.** Antes de editar doc compartilhado (`board.md`, `asset-list.md`), marque o item com seu dono.
  Coders trabalham em worktrees separadas por feature.
- **`src/Modux` e `src/Libs/Net/init.luau`** são pontos de conflito: mudança neles passa pelo `architect`.

## Ciclo de um item

```
ideia → secretary registra (Rascunho)
      → especialista detalha
      → usuário decide → DEC-### → Aprovado
      → task-planner gera TASK-### / AST-### entra na fila do modeler
      → coder/modeler executa
      → qa-tester valida critérios de aceite
      → Feito
```

## Sem o usuário (após bandeira verde)

1. Está respondida em `docs/`? Use.
2. Não está e **não bloqueia**: siga a recomendação do especialista, marque **Provisória**, abra `Q-###` não bloqueante.
3. Não está e **bloqueia** (muda escopo, história ou monetização): abra `Q-###` bloqueante e passe para outra task.
