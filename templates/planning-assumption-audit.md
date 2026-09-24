# Pre-batch assumption audit

_Committed by the prompt producer with every prompt bundle, before dispatch._

## 1. Live-extract table

Every value the prompts embed, with the command that produced it and the date.

| Value | Used in | Source command | Output | Date |
| --- | --- | --- | --- | --- |
| target address | §6 device test | `grep -n '<target>' CURRENT-STATE.md` | | |
| config filename | §6 | `ls <dir>` | | |
| function signature | §6 code | `grep -n 'static.*<fn>' <file>` | | |
| numeric constant | §4 rule | `grep -n '<pattern>' <file>` | | |
| version | §2 gate | `cat VERSION` | | |

Prompts may use only values from this table. A value from memory is a defect.

## 2. Unverified assumptions

| Assumption | Why it could not be verified this session | Label in prompt |
| --- | --- | --- |
| | | `UNVERIFIED ASSUMPTION` |

## 3. Unimplemented items from the previous batch's audit

| Recommendation | Implemented / issue #N / rejected (reason) |
| --- | --- |

## 4. Simplest thing that could go wrong

One failure mode most likely to surface during execution, and the checkpoint that catches it.

## 5. Long-running impact

If this batch's changes ran unattended for three weeks, what degrades (memory, storage fill, log volume, quotas), and what in the prompt measures it.

## 6. Embedded code

- [ ] None, or
- [ ] Assembled on a scratch branch and syntax-checked on <date>: <command> → PASS

## 7. Platform capabilities the plan relies on

Every hardware, framework or library capability the plan depends on, with the evidence that it exists in the version you use. A capability that is unsupported or unverified turns its step into a research step with a decision gate.

| Capability and use | Platform / library and exact version | Source (URL and section) | Date checked | Evidence (probe output, or why the documentation is enough) | Result and next step |
| --- | --- | --- | --- | --- | --- |
| | | | | | supported / unsupported / unverified → research step |

If the plan relies on none, write "Not applicable" and one sentence why.
