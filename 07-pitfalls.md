# 7. Pitfalls you will meet

**Twelve (anti)patterns, each with the signal that tells you it is happening, as well as one change that prevents it.** 

All twelve occurred on the source project.

| # | Pitfall | Recognition signal | Prevention |
| --- | --- | --- | --- |
| 1 | **Plausible narrative** - an elegant explanation is accepted without the one-line check that would falsify it | The explanation is more interesting than the observation and this carries you away | Confirm *what* before hypothesizing *why*; one diagnostic command first (Occam's Razor again) ([Section 2.6, Chapter 2](02-operating-model.md#26-truth-seeking-as-a-named-discipline)) |
| 2 | **Forgotten recommendation** - a postmortem's action items are archived and never read again; the failure they predicted arrives weeks later | A recommendation exists in a document no prompt lists as required reading. In other words - those who forget the past are condemned to repeat it | Route every recommendation to an issue or the state file; no third option ([Section 3.2, Chapter 3](03-state-and-continuity.md#32-current-statemd)) |
| 3 | **Context-window cliff** - files outgrow what an agent can hold; fix cycles jump from 0–1 to 3+ and the operator responds with longer prompts | Rising fix cycles with no change in the kind of work | Split at ~2,000 lines; assemble artifacts; never edit generated files ([Section 1.2, Chapter 1](01-before-you-start.md#12-context-windows-decide-your-file-sizes)) |
| 4 | **Documentation drift** - plans reference paths and functions that moved two phases ago | A plan's date predates the last refactor | State file "stale documents" section; re-verify before use ([Section 3.2, Chapter 3](03-state-and-continuity.md#32-current-statemd)) |
| 5 | **Over-documentation** - the corpus grows, retrieval fails, defects do not fall | You cannot find a known lesson in 30 seconds | Five-layer model; promote findings up, never read layer 5 in execution ([Section 3.1, Chapter 3](03-state-and-continuity.md#31-the-five-layer-knowledge-model)) |
| 6 | **Audit arms race** - each incident adds an auditor, a reconciliation file, a self-report; verification cost overtakes production | Verification-to-production sessions ≥ 5:1; a batch produces reports and no code | Risk tiers; lint over prose; freeze rule; per-batch metrics ([Chapter 5](05-keeping-the-producer-honest.md)) |
| 7 | **Doctrine attenuation** - rules multiply, compliance with any one rule falls | A new rule is added after an incident and the class recurs anyway | Rule budget: lint it and delete the prose; producer contract ≤150 lines ([Chapter 5](05-keeping-the-producer-honest.md)) |
| 8 | **Code in prose** - a prompt embeds finished code that no compiler sees; two reviewers argue about declaration order | Prompts over ~20 KB with fenced source blocks | Compile before dispatch, or specify intent and let the agent write it ([Chapter 4](04-writing-prompts.md)) |
| 9 | **Memory records a plan as done** - a session's deliverables, closure commands, or "we decided" are noted as completed and never landed | Repository log and tracker show nothing after the date the note says work happened | Only the repository is state; restart protocol compares repo, docs, and last conversation ([Chapter 3](03-state-and-continuity.md)) |
| 10 | **Calendar on a stale assumption** - a date is set to fix something already fixed, or to finish work sized by wishes | The calendar's gating item is not in the state file's open list | Check every gating item against the state file and the code; derive dates from cadence ([Chapter 6](06-review-verify-close.md)) |
| 11 | **Contradictory planning documents** - roadmap, phase plan, and decision log disagree; the newest conversation silently wins | Two documents give different orders or targets for the same phase | Source-of-truth ranking; a plan that changes a logged decision writes the superseding line first ([Section 2.5](02-operating-model.md#25-source-of-truth-hierarchy), [Section 3.4](03-state-and-continuity.md#34-the-decision-log)) |
| 12 | **Infeasible as written** - a plan step assumes a platform capability that does not exist in the version you use | The step names a library feature without a citation to current documentation | Every hardware/platform claim in a plan cites a current source; research steps (no version bump) precede implementation ([Section 2.7, Chapter 2](02-operating-model.md#27-before-any-plan-the-assumption-audit)) |

## From the list above - notes on the ones that hurt most

**6 and 7 together - the process trap.** From the inside they feel like diligence, __and__ they take you in the wrong direction. How to recognize it: the documents being produced are *about the process* and not *about the product* - audits of prompts, audits of audits, reconciliations of audits, methodology reviews by four model families. Each one of them was good on its own. Together they took more time than implementing the features would have. The way out is always the same: apply the fixes already written, freeze the meta-work, ship the lowest-risk step, measure, move on.

**8 - the one a compiler would have caught.** Two of three auditors found a declaration-order error in C++ code embedded in a prompt. The audit itself said that no automated check was possible without a real compile, and put the compile out of scope. That was the mistake. A syntax-only compile of the assembled file takes seconds and gives the same answer every time; a human (or an AI) reading C++ inside a prose document does neither.

**9 - a pitfall that makes no noise.** A memory note or a chat summary says "issues closed", in reality they are not and on surface nothing fails. The next session inherits a false state and continues/plans on it. The only defense against such a failure is that state claims need to be verified against the live repository/code before usage. And should be done every time, by every role.

**12 - ambition rather than reality.** On the source project a plan step assumed the firmware framework could act as a Zigbee coordinator while running a Wi-Fi access point for provisioning. The framework's documentation, checked later, said the component supports end-device and router roles only and that access-point mode with Zigbee is unsupported. The step had been sized, versioned, and sequenced. One citation would have moved it to a research step with a decision gate.

## Early-warning dashboard

Three numbers, checked at every phase closure, catch most of the twelve before they cost a phase:

1. **Verification-to-production ratio** - sessions spent on audits and methodology divided by sessions spent on steps that merge code. Above 2:1, look for pitfalls 6–7 above.
2. **Fix cycles per step trend.** Rising without a change in work type: pitfall 3; rising after a new rule was added: pitfall 7.
3. **Days since `Last verified`** in the state file. More than one step: pitfalls 4, 9, 10, 11 are all in play.
