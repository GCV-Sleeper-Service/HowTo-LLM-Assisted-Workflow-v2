# 6. Review, audit, verify, close

Process and reality:

- Reviews find what prompts missed
- Evidence from the running system settles what reviews cannot assess
- Closure turns both of them into the next phase's starting point

So - review, verify, confirm. Then move on to the next step.

## 6.1 How reviews work - the review pipeline

The working order of code reviews is five reviews per step, in the following sequence: 

- Three online automated AI reviewers on the PR platform once PR is created and made ready for review (for the source project repo is on GitHub with different AI model families for codereviews)
- After that: two external whole-PR reviewers on other platforms
- Finally one structured multi-turn review that produces the consolidated audit 

Above was the source project's default and it does not change with the risk tier. The tier changes producer-side audits and prompt style (see [Section 2.4 in Chapter 2](02-operating-model.md#24-Risk-tiers)). A project may set a different default, but it sets it once.

After the inline reviews land, the coding agent gets a single line instruction, which is the same every time:

> Please analyze the code reviews and comments for the PR. Assess if they are warranted; if yes, implement the necessary fixes. Post a comment in PR summarizing your assessment and work permormed.

Important: assess-then-fix matters. Here is why - reviewers are sometimes wrong. An agent that _blindly_, without confirmation implements every finding by reviewers will damage the code and make things worse (read - more time wasted fixed things) as often as it improves it. The agent's assessment comment - warranted / not warranted / not actionable, with reasons - is part of the audit trail.

External reviewers also get the same structured prompt: classify findings by severity, check each acceptance criteria and propose a concrete fix. "Looks good" is not a review - it is a prose. Review assess if implementation reaches the intended, pre defined goals that are measurable.

## 6.2 The consolidated audit

This is written inside the PR for any non-trivial step (new feature, runtime data path, dashboard, build script, or three or more sub-fixes) has been implemented and passed all reviews. Minimum contents of the consolidated audits are:

- Findings by reviewers: they are grouped by severity with clarifications/details (fixed in this PR / tracked as issue #N / accepted with reason)
- Agent autonomous decisions taken without human input, each classified as helpful / harmful / neutral
- The prompt-quality score: fix cycles, checkpoint saves, preventable review findings, autonomous decisions
- Unimplemented recommendations and where each one was routed

The score is the method's feedback loop. A step with zero fix cycles means the prompt was complete; a checkpoint save means the prompt was wrong and the checkpoint caught it; a preventable finding means the prompt had a gap the reviewers filled. Track them per phase (§6.5).

## 6.3 Evidence beats opinion

Reality matters. No reviewer catches a heap exhaustion that appears after three weeks of data, a stack overflow on one of specific case (like a new board), or a client that drops a chunked response. 

Here is a method for systems that run on hardware or against live services:

- The agent deploys and posts the raw evidence into the PR: version endpoint, health telemetry, response headers, binary size against its partition.
- Evidence must exercise the acceptance criteria as written. A `curl … | head -20` proves the endpoint answers; it does not prove a full-length response completes on the smallest environment (a board in the source project case). 
- Long-duration behaviour gets a periodic health line in the logs and a weekly scripted sample committed alongside the state file. Most production-only failures on the source project were visible in telemetry weeks before they crashed anything.

## 6.4 Phase closure

Every phase ends with one closure step whose PR contains:

1. Issue sweep - every open issue tagged to the phase classified resolved / deferred (to a named milestone) / new
2. Plan-versus-delivery comparison and a review-findings summary: what did reviewers catch that prompts should have prevented?
3. New lessons and critical rules - and the lint rules that let old prose rules be deleted
4. Method update: new failure patterns into the pitfalls list, checkpoint learnings into the prompt template
5. State file re-verified: `Last verified` date, open issues, stale documents, unimplemented recommendations
6. KPI row appended (see the 6.5 below) and the models/tools used recorded, with any behavour change noticed
7. Every recommendation routed: issue or state-file entry, no third option

Lesson to learn: skipping closure is how the source project arrived at a plan that contradicted its decision log and a calendar that assumed an already-fixed bug was open.

## 6.5 KPIs

| KPI | Measures | Target | Red flag |
| --- | --- | --- | --- |
| Fix cycles per step | Prompt quality | 0 low / ≤1 medium / ≤2 high | >3 on any step |
| Steps per feature phase | Scoping accuracy | 6–8 | >12 |
| Wall-clock per step | Execution efficiency | ≤3 h operator time | consistently >4 h |
| Checkpoint saves | Checkpoints catching prompt errors | >0 | 0 for a whole phase (checkpoints too weak) |
| Preventable review findings | Prompt gaps | falling phase over phase | rising |
| Verification-to-production ratio | Process weight | ≤2:1 sessions | ≥5:1 (the stall signature) |

Capture timestamps when they happen, not reconstructed at closure.

## 6.6 Project calendars from cadence

Time spent on project/implementation comes from reality, not from desires or wishes. Calendar for the project implementation is driven by past experience that is a measured cadence, never out of wishes. 

Derive dates from measured throughput, not from the plan's step count:

1. Count merged steps and calendar days over the last comparable stretch (same kind of work - refactoring steps run three to six times faster than runtime steps).
2. Multiply remaining steps by the measured days per step; add the plan's own per-step estimates where they are higher.
3. State the uncertainty. On the source project it was ±40 %, dominated by review-round count on high-tier steps (one PR took four rounds) and by irreversible steps that must not be compressed.
4. Publish the fallback calendar for reduced availability at the same time (×1.6 for three sessions a week instead of five).
5. If a date must hold, name what ships at that date honestly (`v1.0-rc1` at step 9 of 12) rather than redefining "complete".
