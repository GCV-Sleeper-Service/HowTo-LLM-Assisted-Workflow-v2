# Templates

Copy the templates you need into your project, fill every `<placeholder>`, and adapt paths, commands, scope lists and lint patterns. Run `tests/run-tests.sh` (and your own copies of the checks) against your checkout before the first prompt goes out.

| File | Copy to | Read chapter |
| --- | --- | --- |
| `CURRENT-STATE.template.md` | `CURRENT-STATE.md` at repo root | 3 |
| `decision-log.template.md` | `Docs/decisions/decision-log.md` | 3 |
| `agent-prompt.template.md` | `prompts/<phase>/<step>-agent-prompt.md` | 4 |
| `session-handoff.template.md` | `prompts/handoff/<phase>/session-handoff-<step>.md` | 3, 4 |
| `consolidated-audit.template.md` | inside each PR (`prompts/<phase>/<step>-PR<n>-audit.md`) | 5, 6 |
| `planning-assumption-audit.md` | `prompts/handoff/<phase>/<phase>-batch<n>-assumption-audit.md` | 5 |
| `setup-and-review.template.md` | `prompts/<phase>/<step>-setup-and-review.md` | 4, 6 |
| `scope-gate.py` | `scripts/scope-gate.py`; the agent prompt's PRE-PR gate calls it | 4 |
| `lint-prompts-starter.sh` | `scripts/lint-prompts.sh` + a CI job; adapt the patterns, keep the regression tests | 5 |
| `lint-rules-starter.md` | Reference when adapting the linter and its CI check | 5 |
| `restart-checklist.md` | run, do not commit | 3 |

Also create, from the source project's pattern: `AGENTS.md` (comprehensive agent instructions: what never to edit, mandatory patterns, pipeline, review checklist, severity classes) and a short `.github/copilot-instructions.md` (the ten rules that catch the most defects, under the platform's character limit).
