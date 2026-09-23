# 5. Keeping the prompt-writer honest

Here is the inconvenient truth - **The session that writes prompts is an LLM too, and it drifts from its own guide for the same reasons a coding agent drifts from a prompt.** 

Here needs to be repeated that [is written right in the middle of the readme](README.md#one-warning-recommendation-by-the-author) - please go back and read it before continuing this chapter. 

The fix for Producer's drift from the prompt producing guide __is not__ to write a longer, more elaborate guide. Please take this as a hard learned truth.

The fix is a short list of mechanical gates that run before dispatch, a linter that owns every rule it can express, and a measure/cap on how much verification a step may cost.

## 5.1 What went wrong on the source project

Example: batch 1 prompts of one feature phase was produced by a Prompt Producer (highly capable Frontier model) session. In that session the Producer had been told to read the process guide (which already had non-trivial number of rules and requirements) and produce the prompt according to the planned phase. The prompts the session produced put documentation "after merge" (while the guide says that they need to be in-PR), pushed device testing to the human (the guide says the agent does the all non-hardware testing), used a stale board address and a renamed config file (the state file in the repo had the right ones), and set scope checkpoints that the canonical version-bump tool tripped. Upon detecting these, batch 2 session fixed those and introduced new ones problems: a numeric constant copied from an old prompt, a changelog with pre-filled byte counts, line-number anchors, a scope section that pointed at another prompt, and a code insertion directive that would not compile.

Audit: four independent audits then catalogued eight producer failure modes, agreed on a fix list, and were merged as reports. Outcome: the fixes were never applied. 

Verification effort of the produced prompts (are they going to do what they supposed to do) reached roughly __ten times production effort__.

Here are the eight failure modes that are encountered in the Producer session on ESP32 project, generalized list:

| # | Failure mode | Generalization/the problem |
| --- | --- | --- |
| F-1 | Scope references another prompt | Self-containedness broken by convenience |
| F-2 | Numeric constant embedded without a verification gate | A value copied from text/prose, __not__ extracted from a source (see authority of source of truth in [Chapter 2](02-operating-model.md)) |
| F-3 | Device-test section names one target when the plan requires two | Coverage narrower than the pre-defined acceptance criteria |
| F-4 | Function signature embedded without re-grep | A fact that was true last batch and not verified |
| F-5 | Line numbers as anchors | Decays on every merge (see embedded fact liability section in [Chapter 4](04-writing-prompts.md)) |
| F-6 | Declaration order not modelled | Code in text/prose, never compiled |
| F-7 | "The gate ran" mistaken for "the gate enforced" | A check whose failure changes nothing instead of stopping |
| F-8 | Producer's self-analysis misattributes the root cause | Asking the drifter to explain its own drift (see the note at the bottom of [Chapter 2](02-operating-model.md)) |

## 5.2 Why prose rules fail

Every incident during prompt producing added a rule to the guide. At one point the project had 67 critical rules, five doctrinal documents, nine errata, fourteen issue-tracked guardrails, seven implemented lint rules and three more sketched — and a producer session's compliance with any one rule *fell* as the total number of rules rose. This is context attenuation, and it applies to the producer exactly as it applies to the agent. More prose is not a fix for prose that causes the problem.

The empirical signal from the same project is unambiguous: **every defect class that got a lint rule stopped recurring; every class handled by "read the guide more carefully" recurred.**

## 5.3 The gates that work

Run below before any prompt is dispatched to the coding agent. Mechanical where possible; short where not possible.

1. **Live-extract block.** The producer session starts by extracting, from the state file and live `grep`, every value the prompts will embed — addresses, filenames, signatures, constants, version — into a table with the source of each. Prompts may __only__ use values from the table. The table is committed with the bundle as the batch's assumption audit.
2. **Doctrinal value pinning.** Any number in a prompt either references a measurement the agent will perform or a live file the agent will grep. A pre-filled measured value fails lint.
3. **Symbol anchors.** Any `file:line` reference fails lint unless followed by a re-verify command.
4. **Self-containedness.** Any "see <other prompt>" in a scope or constraint section fails lint.
5. **Compile-before-dispatch.** If a prompt embeds code destined for a compiled artifact, the producer drops it into a scratch branch, runs assembly, and runs a syntax-only compile. One compile replaces the declaration-order trace across all auditors.
6. **Risk-tiered audit.** Low tier: lint only. Medium: lint plus one independent auditor using the audit template. High: two auditors from different model families, reconciled in one short file. No reconciliation file when there is one auditor; no self-report file from the producer — the producer's account of its own reasoning is input, not evidence (F-8).
7. **Precedence line.** Every prompt bundle states which document governs when two conflict. On the source project the process guide governs the prompt-writing methodology; without the line, the producer picks whichever it read last.

Audit template: [`templates/consolidated-audit.template.md`](templates/consolidated-audit.template.md) covers both prompt-bundle audits and PR prompt audits. Lint starter: [`templates/lint-rules-starter.md`](templates/lint-rules-starter.md).

## 5.4 The rule budget

A rule that gets a lint implementation is **deleted from the prose (guide)**. The linter is the rule. The success metric for the method is that the critical-rules count should *decreases* from phase to phase while the lint count increases. If the producer-facing guide grows after an incident, the incident has been recorded, not prevented and this needs to be addressed.

Keep one producer-facing contract of roughly 150 lines containing only binding MUSTs, most of them machine-checkable. Everything else is reference material a session opens on demand.

## 5.5 The freeze rule

When a phase stalls on process, the marginal value of another methodology document is negative. Declare a freeze: no new audits of audits, no methodology rewrites, no producer-prompt rewrites until the next code step merges. 

Apply the fixes already written, dispatch the lowest-risk step, and let execution — agent, CI, device — find the next defect. On the source project the cheapest remaining defect discovery was to run the prompt.

## 5.6 Instrument the process

Per batch, record five numbers in the consolidated audit: 
- producer sessions
- audit sessions
- fix-cycle PRs
- defects that escaped to agent execution
- defects that escaped to the running system. 

A leaner process that shows equal-or-fewer escapes at lower cost is validated by data; one that shows more is reverted with data in hand. This is the same truth-seeking discipline from Chapter 2 pointed at the method itself.

> **From the source project.** Two auditors caught the declaration-order defect (F-6); a third did not. The lesson was drawn as "single auditors miss things — mandate two." The cheaper lesson was "code in prose is never compiled — compile it." Both are true; only the second removes the defect class. 

**Prefer the fix that deletes a failure mode over the one that adds a check for it.**
