# 5. Keeping the prompt-writer honest

Here is the inconvenient truth - **The session that writes prompts is an LLM too, and it drifts from its own guide for the same reasons a coding agent drifts from a prompt.** 

Repeating what [is written right in the middle of the readme](README.md#one-warning-recommendation-by-the-author) - please go back and read it before continuing this chapter. 

The fix for Producer's drift from the prompt producing guide __is not__ to write a longer, more elaborate guide. Please take this as a hard learned truth.

The fix is a short list of mechanical gates that run before dispatch, a linter that owns every rule it can express, and a measure/cap on how much verification a step may cost.

## 5.1 What went wrong on the source project

**Example**: batch 1 prompts of one feature phase were produced by a Prompt Producer (highly capable frontier model) session. In that session the Producer had been told to read the process guide (which already had non-trivial number of rules and requirements) and produce the prompt according to the planned phase. The prompts the session produced put documentation "after merge" (while the guide says that they need to be in-PR), pushed device testing to the human (the guide says the agent does all non-hardware testing), used a stale board address and a renamed config file (the state file in the repo had the right ones), and set scope checkpoints that the canonical version-bump tool tripped. Upon detecting these, batch 2 session fixed those and introduced new problems: a numeric constant copied from an old prompt, a changelog with pre-filled byte counts, line-number anchors, a scope section that pointed at another prompt, and a code insertion directive that would not compile.

Audit: four independent methodology audits reviewed the process. The one that consolidated them cataloged eight producer failure modes (below) and a fix list. Most prompt fixes were applied in the next two PRs; the last four findings of the final audit, and the process-level guardrails, were still open when development was paused for reasons unrelated to the method. 

Verification effort of the produced prompts (are they going to do what they are supposed to do) reached roughly __ten times production effort__.

Here are the eight failure modes that are encountered in the Producer session on ESP32 project, generalized list:

| # | Failure mode | Generalization/the problem |
| --- | --- | --- |
| F-1 | Scope references another prompt | Self-containedness broken by convenience |
| F-2 | Numeric constant embedded without a verification gate | A value copied from text/prose, __not__ extracted from a source (see authority of source of truth in [Chapter 2](02-operating-model.md)) |
| F-3 | Device-test section names one target when the plan requires two | Coverage narrower than the pre-defined acceptance criteria |
| F-4 | Function signature embedded without re-grep | A fact that was true last batch and not verified |
| F-5 | Line numbers as anchors | Decays on every merge (see embedded fact liability section in [Chapter 4](04-writing-prompts.md)) |
| F-6 | Declaration order not modeled | Code in text/prose, never compiled |
| F-7 | "The gate ran" mistaken for "the gate enforced" | A check whose failure changes nothing instead of stopping |
| F-8 | Producer's self-analysis misattributes the root cause | Asking the drifter to explain its own drift - its account is input, not evidence |

## 5.2 Why prose rules fail

Every incident during prompt producing added a rule to the guide. At one point the project had 67 critical rules, nine errata, seven lint rules with an eighth planned, and a tracked list of more than a dozen guardrails still to build - and a producer session's compliance with any one rule *fell* as the total number of rules rose. This is context attenuation, and it applies to the producer exactly as it applies to the agent. Adding more rules to the guide does not help when the rules already there are being skipped.

The evidence from the same project points one way, although the sample is small: in the prompt batches after the linter went in, **no linted defect class came back, while two unlinted ones did** - a delay constant copied from an old prompt and a declaration-order error in embedded code.

## 5.3 The gates that work

Here is what runs before any prompt goes to the coding agent. Mechanical wherever possible - and short where it is not possible.

1. **Live-extract block.** The producer session starts by pulling every value the prompts will use - addresses, filenames, function signatures, constants, the version - out of the state file and live `grep`, into one table with the source of each value. The prompts may use __only__ values from that table. The table is committed with the bundle as the batch's assumption audit.
2. **Pin every number.** Any number in a prompt points either to a measurement the agent will do, or to a live file the agent will grep. A pre-filled measured value is a defect - lint it once the class comes back (L9 in the lint starter).
3. **Anchor by symbol.** A `file:line` reference without a re-verify command next to it is a defect - lint it once the class comes back (L10 in the lint starter).
4. **Self-contained prompts.** Any "see <other prompt>" in a scope or constraint section fails lint.
5. **Compile before dispatch.** If a prompt carries code that ends up in a compiled artifact, the producer drops it into a scratch branch and runs the assembly step and a syntax-only compile. One compile replaces the declaration-order reading that every auditor would otherwise have to do.
6. **Audit by risk tier.** Low tier: lint only. Medium: lint plus one independent auditor with the audit template - with one auditor there is nothing to reconcile, so no reconciliation file. High: two AI auditors from different model families, because different families catch different defects; their findings are reconciled in one short file. And no self-report file from the producer - what the producer says about its own reasoning is input, not evidence (F-8)..
7. **Precedence line.** Every prompt bundle says which document wins when two disagree. On the source project the process guide wins over the prompt-writing methodology. Without that line, the producer follows whichever document it read last.

Audit template: [`templates/consolidated-audit.template.md`](templates/consolidated-audit.template.md) covers both prompt-bundle audits and code-PR audits. Lint starter: [`templates/lint-rules-starter.md`](templates/lint-rules-starter.md).

## 5.4 The rule budget

Simple rule: once a rule has a lint check, its __explanation__ is deleted from the guide and one line of intent stays, linked to the check. From then on the linter enforces the pattern, and nobody has to remember the explanation. Keep the line of intent, because a pattern check catches its pattern and not the whole rule: on the source project the check for testing handed to the human matches section headers, and a body sentence that does the same thing passes it.

The evidence that the method works: the number of prose rules goes down from phase to phase, while the number of lint rules goes up. If the producer-facing guide gets longer after an incident, you have written the incident down - you have not stopped it from happening again. Treat that as a problem to fix.

Keep one producer-facing contract of about 150 lines, with only the binding MUSTs, most of them machine-checkable. Everything else is reference material that a session opens when it needs it.

## 5.5 The freeze rule

There is a point where one more methodology document costs more than it gives. You are there when a phase is held up by process rather than by code. At that point, declare a freeze: no new audits of audits, no methodology rewrites, no rewrites of the producer prompt - until the next code step merges.

Then do three things: apply the fixes that are already written, dispatch the lowest-risk step, and let the execution itself - the agent, CI, the device - find the next defect. On the source project, after all the audits, the cheapest way left to find defects was simply to run the prompt.

## 5.6 Instrument the process

Measure the method the same way you measure the code. For every batch, record five numbers in the consolidated audit: 
- producer sessions
- audit sessions
- fix-cycle PRs
- defects that escaped to agent execution
- defects that escaped to the running system. 

If a leaner process shows the same or fewer escapes at a lower cost, the data says keep it. If it shows more, revert it - and you will have the numbers to show why. This is the truth-seeking discipline from [Chapter 2](02-operating-model.md#26-truth-seeking-as-a-named-discipline), pointed at the method itself.

> **From the source project.** Two auditors caught the declaration-order defect (F-6); a third did not. One lesson was drawn as "single auditors miss things - mandate two." The second, cheaper lesson was "code in prose is never compiled - compile it." Both statements are true, but the fact is that only the second removes the defect class. 

**When you find a failure mode, a fix that removes it is better than a check that watches for it.**
