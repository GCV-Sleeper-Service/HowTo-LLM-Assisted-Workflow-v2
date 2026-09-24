# 4. Writing prompts that hold

What is a prompt for the coding agent? 

**A prompt is a contract with a literal-minded executor: bounded scope, verifiable checkpoints, executable acceptance criteria, and as few embedded facts as the job allows.** 

There are two styles, chosen by risk tier. Both use the same skeleton: a header and preamble, a short lessons block, and nine numbered sections.

## 4.1 The bundle: three files per step/PR

1. **Agent prompt** - the instructions the coding agent executes.
2. **Setup-and-review prompt** - the agent setup block the operator pastes first, plus the reviewer checklist keyed to this step's changes.
3. **Session handoff** - state snapshot, risk table, what carries forward (described in the [Chapter 3](03-state-and-continuity.md)).

Producing the bundle is __the__ most expensive part of a step and the place where quality is decided: a precise bundle merges on the first attempt; a vague one costs three to six review rounds and wasted time. 

So - eliminate problems before they occur, not fix them afterwards.

## 4.2 The prompt skeleton

| § | Section | What it must contain |
| --- | --- | --- |
| 0 | Header + execution preamble | Step id, date, prerequisite state, risk tier; the five literal-execution rules (do not optimize, do not remove constraints, touch only scoped files, stop on doubt, stop on context exhaustion) |
| L | Lessons for this step | Only the errata and lessons that apply here, one line each |
| 1 | Repository and required reading | Clone command (if needed); files to read, in order, each with *why* - never "read the docs" |
| 2 | Pre-implementation verification gate | Commands with expected outputs that prove the world/state matches the prompt's assumptions; any mismatch → STOP |
| 3 | Scope boundary | Files the coding agent MAY modify (complete list, including every file your version-bump or generator tooling touches); files MUST NOT modify; actions forbidden |
| 4 | Critical rules for this step | The subset of the critical rules list that applies to this step, with numbers so reviewers can cite them |
| 5 | Do-NOT list | Prohibitions derived from past failures, specific to this step |
| 6 | Implementation | Task groups with a ⛔ CHECKPOINT after each; all documentation deliverables (state file, changelog, session log, handoff, audit) are task groups here, not a later section |
| 7 | Acceptance criteria | Checkable, executable where possible; includes the in-PR deliverables |
| 8 | PR description skeleton | Pre-implementation verification output, per-item verification table, criteria, files modified, round summary |
| 9 | Post-merge bookkeeping | Tag and close issues - nothing else. Naming this section "post-merge deliverables" teaches the agent that documentation is post-merge; the source project's first batch failed on exactly that title |

Skeleton: [`templates/agent-prompt.template.md`](templates/agent-prompt.template.md).

## 4.3 Checkpoints that stop

Checkpoints are your friend - they reduced fix cycles from 2–6 to 0–1 on the source project. But, they need to be written properly - they work only when written as queries with expected outputs and stop-don't-fix semantics.

Example:

```bash
grep -c 'authFetch' dashboard/core/history.js
# Expected: 3
```

Above code is stable across merges vs "Line 47 should contain `authFetch`" breaks on the next commit. 

When a checkpoint fails, the agent posts this and does nothing else:

```
⛔ CHECKPOINT FAILED - <name>
Expected: <value or condition>
Actual:   <command output>
Command:  <verbatim>
Action:   STOPPING. NO code changes made. Awaiting operator decision.
```

An agent that explains away a mismatch instead of posting the template has fallen into the plausible-narrative trap; the template is what prevents it. 

Two more rules from the source project that were learned the hard way: 
- pair every edit to a generated artifact's source with the regeneration command *before* the identity check (`--write` then `--check`, never the reverse)
- count *definitions* not usages when a symbol appears in the prompt's own sample code, or the expected count will be wrong.

## 4.4 Scope guards, including tool side-effects

- List files, not descriptions. Include every file that canonical tooling modifies as a side effect: a version-bump script on the source project touched six source files and regenerated six artifacts, and an agent that ran it - correctly - then hit a scope checkpoint and stopped. 
- Whitelist the side-effects; do not make the agent choose between the tool and the scope.
- Never reference another prompt for scope ("see step 3's list"). Inline it inside the prompt. A lint rule should fail the PR if it finds the phrase.

## 4.5 Every embedded fact is a liability

Observation: IPs, filenames, function signatures, delay constants, struct sizes, line numbers - each one is a thing the prompt producer _can get wrong_ and the agent will execute without doubt and checking. On the source project a stale address and a renamed config file cost one full device-test cycle; a delay constant copied from an old prompt (1 ms instead of the measured 5 ms) reached a PR before a reviewer caught it.

Rules that help to avoid such problems:

- **Extract at production time, from the state file or a live grep - never from memory.** [Chapter 5](05-keeping-the-producer-honest.md) makes this a gate.
- **Pin every numeric constant** to either a measurement procedure the agent runs or a live source the prompt greps. A changelog template that pre-fills "(36 bytes)" is a defect; `(<MEASURED> bytes)` with the measurement step is correct.
- **Anchor by symbol, not line number.** `firmware/core/nvs-persistence.h: maybe_yield_nvs_scan_()` plus a re-verify grep survives every merge; `nvs-persistence.h:248` is wrong by the next one.
- **Fewer facts are better than more checks.** The alternative - verification tables and auditors for every fact - leads to an arms race you lose on cost and time.

## 4.6 Two prompt styles, chosen by risk

**Prescriptive.** The prompt contains the finished code and exact insertion points. Use it for high-tier steps where an agent's freedom is itself the risk (migrations, boot paths, anything irreversible) - and _only_ if the embedded code has been compiled or syntax-checked against the real tree before dispatch. A prompt with C++ in markdown has moved verification from the compiler to prose reviewers; two auditors on the source project found a declaration-order error that a syntax-only compile would have caught in seconds.

**Intent and acceptance.** The prompt gives scope, interface contracts with grep-at-execution checkpoints, and acceptance criteria as executable checks (grep counts, compile pass, curl output, resource deltas). The agent writes the code; CI compiles it; reviewers review a real diff. Use it for low and medium tiers. It removes the embedded-fact classes at the source rather than auditing them, at the cost of possibly one extra review round on a real diff - which is cheaper than an audit round on prose.

Trial the second style on one low-risk step, count escapes against the prescriptive baseline, and let the data decide the mix.

## 4.7 Most system testing belongs to the agent

Anything an agent _can_ do from a shell/execution environment - build, deploy, wait, curl, check the output, parse, post to the PR - it does and _should_ do. The operator does only what needs eyes or hands: visual checks, long-duration observation, physical recovery. Prompts that push testing to the operator lose the evidence trail and the agent's chance to catch its own regression.

Deployment commands are non-interactive (example from the project - an interactive `run` tails live logs and will hang the agent), wrapped in a timeout, and preceded and followed by a clean build. Evidence - the curl output, the health line, the size of the binary - goes into the PR body verbatim.

One warning about evidence: it ends up in a PR that other people can read. Keep credentials, tokens and private keys out of prompts, PR bodies and posted logs. Give them to the agent through environment variables or the platform's secret store, and look at what a command prints before its output is pasted anywhere.

## 4.8 Self-containedness test

A simple test before you handle the prompt to the agent: imagine hand the prompt to someone who has never seen the project, together with the repository and nothing else. Would they know what to touch, what not to touch, and what "done" means? If they would need any other document to answer one of those three questions, the prompt is not finished.
