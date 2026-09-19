# Lint rules starter

A linter over `prompts/**` (and handoffs) that runs in CI on every PR touching them. Rules are ERROR unless marked WARN. Each rule is one defect class that recurred on the source project until it was linted; each one, once linted, was deleted from the prose guide.

| ID | Class | Detects | Note |
| --- | --- | --- | --- |
| L1 | Stale target address | Any address not present in `CURRENT-STATE.md`'s target table | Extend the allow-list from the state file at runtime, not from a hard-coded list |
| L2 | Wrong filename | References to config/build files that do not exist in the tree | `ls`-backed |
| L3 | Cross-prompt reference | `see <other prompt>`, `as in step <n>` inside scope/constraint sections | Self-containedness |
| L4 | Forbidden section title | `Post-Merge Deliverables` and synonyms | Teaches agents to defer documentation |
| L5 | Interactive deploy | `esphome run`, `docker run -it`, any tailing command without timeout in agent-executed blocks | Hangs the agent |
| L6 | Pipeline order (WARN) | Identity `--check` before regeneration `--write` in the same task group | Advisory; produces false positives on intentional pre-checks |
| L7 | Missing timeouts | `curl` to a target without `--connect-timeout`/`--max-time`; deploy without `timeout` | |
| L8 | Constant drift | A numeric constant cited near a rule keyword that differs from the live value in the source file | Parse the source; compare within a ±3-line context window. Implemented on the source project after one recurrence |
| L9 | Pre-filled measurement | `\b\d+ bytes?\b` inside changelog/template blocks not under a Measurements heading | **Candidate** — implement when the class recurs. Requires a structural Markdown parse; until then the `<MEASURED>` placeholder rule in the producer contract covers it |
| L10 | Bare line anchor | `<file>:<n>` without a following re-verify command | **Candidate** — implement when the class recurs. Needs a context-aware regex; the symbol-anchor rule in the producer contract covers it until then |

Implementation notes:

- Run with `--baseline <ref>`: fail only on new ERRORs relative to the base branch, so existing debt does not block unrelated PRs; report the existing count so it can be driven down.
- Keep pass/fail fixtures per rule under `tests/lint-prompts/`; a rule without a failing fixture is untested.
- Required status checks must not be path-filtered, or docs-only PRs deadlock on a check that never runs; use a stub job that always reports.
- Every new rule removes a sentence from the producer-facing guide.
- A rule is added when its defect class has recurred, not when it can be imagined: speculative lint rules are their own maintenance surface. L1–L8 each followed a recurrence on the source project; L9–L10 are listed so the decision is recorded, not to be built in advance.
