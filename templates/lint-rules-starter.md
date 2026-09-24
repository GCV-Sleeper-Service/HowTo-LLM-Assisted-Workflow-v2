# Lint rules starter

A linter over `prompts/**` (and handoffs) that runs in CI on every PR touching them. This file is the specification; `lint-prompts-starter.sh` next to it is a minimal runnable version, with regression tests in `tests/run-tests.sh`. Rules are ERROR unless marked WARN. Under the method, a rule is added only after its defect class has recurred. Once a rule has a lint check, keep one line of its intent in the guide, linked to the check, and remove only the redundant explanation - reviewers still check the intent beyond the pattern the linter recognizes.

## Rules the source project implemented (L1-L7)

Each of these followed a recurrence in the source project's prompts. The IDs are the source project's; the "generalize to" column is how to write the rule for your own project.

| ID | Defect class | Source project's check | Generalize to |
| --- | --- | --- | --- |
| L1 | Documentation deferred to after merge | The section title "Post-Merge Deliverables" | Any post-merge section that lists documents instead of tag-and-close |
| L2 | Testing handed to the human | "(for Human)" in a section header of an agent prompt | Headers that assign agent-doable work to the operator |
| L3 | Cross-prompt reference | "see v7.x.y.z prompt" | Any "see <other prompt>" in scope or constraint sections |
| L4 | Stale target address | One retired board IP | Any address not in the state file's target table (build the allow-list from the file at run time) |
| L5 | Wrong config filename | One renamed YAML file | References to build/config files that do not exist in the tree |
| L6 | Pipeline order (WARN) | Identity `--check` within 20 lines before regeneration `--write` | Same; advisory, because intentional pre-checks trigger it |
| L7 | Variants of L1 | "§9 ... Post-Merge ... Deliverables" in any spelling | Pattern-based variants of your forbidden titles |

## Planned and candidate rules

| ID | Class | Detects | Status |
| --- | --- | --- | --- |
| L8 | Constant drift | A numeric constant cited near a rule keyword that differs from the live value in the source file (parse the source; compare within a 3-line window) | Planned on the source project after one recurrence |
| - | Interactive deploy | `esphome run`, `docker run -it`, any tailing command without a timeout in agent-executed blocks | Candidate; the source project catches it in audits |
| - | Missing timeouts | `curl` to a target without `--connect-timeout`/`--max-time`; deploy without `timeout` | Candidate; the source project catches it in audits |
| L9 | Pre-filled measurement | A byte count or other measured value inside changelog/template blocks | Candidate; needs a structural Markdown parse. Until then the `<MEASURED>` placeholder rule covers it |
| L10 | Bare line anchor | `<file>:<n>` without a following re-verify command | Candidate; needs a context-aware regex. Until then the symbol-anchor rule covers it |

## Implementation notes

- Run from the repository root with repository-relative paths. With `--baseline <ref>`, report existing violations and fail only on new ERRORs, so existing debt does not block unrelated PRs. An existing violation is the same rule on the exact same line (line numbers ignored); an invalid ref fails the run.
- Keep pass/fail fixtures per rule under `tests/lint-prompts/`; a rule without a failing fixture is untested.
- Required status checks must not be path-filtered, or docs-only PRs deadlock on a check that never runs; use a stub job that always reports.
- A rule is added when its defect class has recurred, not when it can be imagined: speculative lint rules are their own maintenance surface.
