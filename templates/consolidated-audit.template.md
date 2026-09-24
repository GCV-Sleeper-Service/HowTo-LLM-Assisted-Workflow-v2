# Consolidated audit - <step id or prompt bundle id> - PR #<n>

_Written inside the PR, completed after the last review round and committed before merge. Required for any non-trivial step (new feature, runtime data path, UI, build script, or ≥3 sub-fixes) and for every prompt bundle at medium/high tier._

## 1. Verdict

PASS | CONDITIONAL PASS (only low/medium findings, tracked) | FAIL (≥1 high finding; do not merge/dispatch)

## 2. Findings by severity

| # | Severity | File / location | Finding (quote verbatim) | Disposition |
| --- | --- | --- | --- | --- |
| | High / Medium / Low | | | fixed here / issue #N / accepted: <reason> |

## 3. Reviewer assessment (for PRs)

| Reviewer | Findings | Warranted | Not warranted (why) | Not actionable |
| --- | --- | --- | --- | --- |

## 4. Agent autonomous decisions

| Decision | Helpful / harmful / neutral | Note |
| --- | --- | --- |

## 5. Prompt-quality score

_An indicator, not proof: zero fix cycles is consistent with a complete prompt, and also with defects nobody has found yet. Record escaped defects and their severity in section 6._

- Fix cycles:
- Checkpoint saves:
- Preventable review findings:
- Autonomous decisions (h / h / n):
- One-line judgment:

## 6. Process metrics for this batch

- Producer sessions:
- Audit sessions:
- Fix-cycle PRs:
- Defects escaped to agent execution:
- Defects escaped to the running system:

## 7. Recommendations routed

| Recommendation | Routed to (issue #N / CURRENT-STATE entry / rejected: reason) |
| --- | --- |

## 8. Cross-audit reconciliation (only when two auditors ran)

| Check | Auditor A | Auditor B | Resolution |
| --- | --- | --- | --- |
