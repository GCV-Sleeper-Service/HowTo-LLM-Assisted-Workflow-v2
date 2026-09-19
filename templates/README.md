# Templates

Copy these into a new project as-is; rename paths to match your tree.

| File | Copy to | Read chapter |
| --- | --- | --- |
| `CURRENT-STATE.template.md` | `CURRENT-STATE.md` at repo root | 3 |
| `decision-log.template.md` | `Docs/decisions/decision-log.md` | 3 |
| `agent-prompt.template.md` | `prompts/<phase>/<step>-agent-prompt.md` | 4 |
| `session-handoff.template.md` | `prompts/handoff/<phase>/session-handoff-<step>.md` | 3, 4 |
| `consolidated-audit.template.md` | inside each PR (`prompts/<phase>/<step>-PR<n>-audit.md`) | 5, 6 |
| `planning-assumption-audit.md` | `prompts/handoff/<phase>/<phase>-batch<n>-assumption-audit.md` | 5 |
| `lint-rules-starter.md` | `scripts/lint-prompts.sh` + `.github/workflows/prompt-lint.yml` | 5 |
| `restart-checklist.md` | run, do not commit | 3 |

Also create, from the source project's pattern: `AGENTS.md` (comprehensive agent instructions: what never to edit, mandatory patterns, pipeline, review checklist, severity classes) and a short `.github/copilot-instructions.md` (the ten rules that catch the most defects, under the platform's character limit).
