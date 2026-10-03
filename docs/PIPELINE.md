# Pipeline de produção

Como os agentes trabalham juntos e em paralelo.

## Fases

| Fase | Objetivo | Saída | Gate |
|---|---|---|---|
| 0. Pré-produção | mapear o jogo inteiro | GDD completo em `docs/` | **bandeira verde** do usuário (`DEC-###`) |
| 1. Fundação técnica | arquitetura + sistemas núcleo | `docs/tech/architecture.md` + código | QA verde no núcleo |
| 2. Vertical slice | uma fatia jogável do começo ao fim, com arte final | slice completa | aprovação do usuário |
| 3. Produção | resto do conteúdo e progressão | jogo completo | QA por entrega |
| 4. Polimento | balanceamento, performance, mobile, UX | release | playtest |

## Trilhas paralelas

Cada trilha roda numa sessão própria do Claude Code. Elas se comunicam **só por `docs/`**,
nunca por memória de conversa.

```
Trilha A  usuário + secretary           (design: perguntas, decisões, GDD)
            ├─ chama game-designer / narrative-writer / art-director para propor opções
Trilha B  modeler-3d                    (Blender: consome fichas AST Aprovadas)
Trilha C  level-designer                (conceito e blockout de mapas já descritos)
Trilha D  researcher                    (referências e viabilidade, sob demanda)
Trilha E  architect → task-planner → backend/frontend-coder → qa-tester   (após bandeira verde)
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
