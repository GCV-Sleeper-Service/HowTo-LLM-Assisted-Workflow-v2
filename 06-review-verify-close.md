# 6. Review, audit, verify, close

Process and reality:

- Reviews find what prompts missed
- Evidence from the running system settles what reviews cannot assess
- Closure turns both of them into the next phase's starting point

So - review, verify, confirm. Then move on to the next step.

## 6.1 How reviews work - the review pipeline

The working order of code reviews is five reviews per step, in the following sequence: 

- Three inline AI reviewers that run automatically on the PR platform once the PR is marked ready for review (the source project is on GitHub and uses three different model families)
- After that: two external whole-PR reviewers on other platforms
- The second of the two external reviews is a structured multi-turn review, and its findings feed the consolidated audit (it is one of the five, not a sixth)

Above was the source project's default and it does not change with the risk tier. The tier changes producer-side audits and prompt style (see [Section 2.4 in Chapter 2](02-operating-model.md#24-risk-tiers)). A project may set a different default, but it sets it once.

Triggering five reviewers on several platforms and collecting their findings by hand took the source project 30-60 minutes per step. Script what you can: most PR platforms expose review requests and comments through a CLI or an API, and a short script that requests every reviewer and gathers the comments into one file pays for itself within a phase.

After the inline reviews land, the coding agent gets a single line instruction, which is the same every time:

> Please analyze the code reviews and comments for the PR. Assess if they are warranted; if yes, implement the necessary fixes. Post a comment in PR summarizing your assessment and work performed.

Important: assess-then-fix matters. Here is why - reviewers are sometimes wrong. An agent that _blindly_, without confirmation implements every finding by reviewers will damage the code and make things worse (read - more time wasted fixing things) as often as it improves it. The agent's assessment comment - warranted / not warranted / not actionable, with reasons - is part of the audit trail.

External reviewers get their own structured prompt: classify findings by severity, check each acceptance criterion and propose a concrete fix. "Looks good" is not a review. A review assesses if implementation reaches the intended, predefined goals that are measurable.

## 6.2 The consolidated audit

The coding agent writes it inside the PR for any non-trivial step (new feature, runtime data path, dashboard, build script, or three or more sub-fixes), after the last review round and before merge. Minimum contents of the consolidated audits are:

- Findings by reviewers: they are grouped by severity with clarifications/details (fixed in this PR / tracked as issue #N / accepted with reason)
- Agent autonomous decisions taken without human input, each classified as helpful / harmful / neutral
- The prompt-quality score: fix cycles, checkpoint saves, preventable review findings, autonomous decisions
- Unimplemented recommendations and where each one was routed

The score is the method's feedback loop, and it is an indicator, not a proof. A step with zero fix cycles is consistent with a complete prompt - and also with defects nobody has found yet; a checkpoint save means the prompt was wrong and the checkpoint caught it; a preventable finding means the prompt had a gap the reviewers filled. Track them per phase (§6.5), next to escaped defects and their severity, and treat a change in the numbers as a question to investigate rather than a conclusion: task difficulty, models and operator experience change too.

## 6.3 Evidence from the running system

Reality matters. No reviewer will catch a heap exhaustion that shows up after three weeks of data, a stack overflow that happens only in one specific case (a new board, for example), or a client that drops a chunked response. Only the running system shows those.

For systems that run on hardware or against live services:

- The agent deploys and posts the raw evidence into the PR: the version the system reports, health telemetry, response headers, the binary size against its partition.
- The evidence has to exercise the acceptance criterion as it is written. Example: `curl … | head -20` proves that the endpoint answers. It does not prove that a full-length response completes on the smallest environment (in the source project - the smallest board).
- Long-running behavior gets a periodic health line in the logs, plus a weekly scripted sample committed next to the state file. On the source project, most failures that only appeared in production were visible in telemetry weeks before they crashed anything.

## 6.4 Phase closure

Every phase ends with one closure step whose PR contains:

1. Issue sweep - every open issue tagged to the phase classified resolved / deferred (to a named milestone) / new
2. Plan-versus-delivery comparison and a review-findings summary: what did reviewers catch that prompts should have prevented?
3. New lessons and critical rules - and the lint rules that let redundant explanation be deleted (one line of each rule's intent stays, linked to its check)
4. Method update: new failure patterns into the pitfalls list, checkpoint learnings into the prompt template
5. State file re-verified: `Last verified` date, open issues, stale documents, unimplemented recommendations
6. KPI row appended (see the 6.5 below) and the models/tools used recorded, with any behavior change noticed
7. Every recommendation routed: issue or state-file entry, no third option

Lesson to learn: skipping closure is how the source project arrived at a plan that contradicted its decision log and a calendar that assumed an already-fixed bug was open.

## 6.5 KPIs

| KPI | Measures | Target | Red flag |
| --- | --- | --- | --- |
| Fix cycles per step | Prompt quality | 0 low / ≤1 medium / ≤2 high | >3 on any step |
| Steps per feature phase | Scoping accuracy | 6–8 | >12 |
| Wall-clock per step | Execution efficiency | ≤3 h operator time | consistently >4 h |
| Checkpoint saves | Prompt errors caught before they did damage | Record and investigate; no minimum | A defect escaped that a checkpoint should have caught; the same cause saved twice |
| Preventable review findings | Prompt gaps | falling phase over phase | rising |
| Verification-to-production ratio | Process weight | ≤2:1 sessions | ≥5:1 (the audit arms race, pitfall 6) |

Capture timestamps when they happen, not reconstructed at closure.

## 6.6 Project calendars from cadence

Time spent on project/implementation comes from reality, not from desires or wishes. Calendar for the project implementation is driven by past experience that is a measured cadence, never out of wishes. 

Derive dates from measured throughput, not from the plan's step count:

1. Count merged steps and calendar days over the last comparable stretch (same kind of work - refactoring steps run three to six times faster than runtime steps).
2. Multiply remaining steps by the measured days per step; add the plan's own per-step estimates where they are higher.
3. State the uncertainty. On the source project it was ±40 %, dominated by review-round count on high-tier steps (one PR took four rounds) and by irreversible steps that must not be compressed.
4. Publish the fallback calendar for reduced availability at the same time (×1.6 for three sessions a week instead of five).
5. If a date must hold, name what ships at that date honestly (`v1.0-rc1` at step 9 of 12) rather than redefining "complete".
