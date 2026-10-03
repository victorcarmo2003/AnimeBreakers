# Decisões

Append-only. Decisão revertida ganha nova entrada que cita a anterior; a antiga não é apagada.

Formato: `DEC-### — AAAA-MM-DD — título` + o que foi decidido + impacto.

---

### DEC-001 — 2026-10-03 — Regras de código do projeto

- Código sem nenhum comentário.
- Sem `--!strict` nos arquivos: o `.luaurc` já força strict no projeto inteiro.
- Documentação em Markdown (`docs/`) e agentes (`.claude/`) seguem detalhados normalmente.
- Impacto: todos os agentes que escrevem código seguem a regra; código tocado tem comentários e `--!strict` removidos.
