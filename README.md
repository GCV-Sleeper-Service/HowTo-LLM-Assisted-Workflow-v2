# AI (LLM)-Assisted Software Development - A Working Method (v2)

By **Irakli Natsvlishvili** · [LinkedIn](https://www.linkedin.com/in/irakli) · September 2026

**Why this guide exists.** It is the deep conviction of the author that people who engage with agentic AI software development will sooner or later realize they need a similar guide for their own project. Thus the purpose of this guide - to save them time and frustration and offer something that works - a project-agnostic guide for building software with AI architecting and coding agents from more than one vendor, without losing control of quality, state, or your own time. 

Every rule in the guide was taken from a real project: an open-source ESP32 sensor-gateway firmware developed almost entirely through AI agents, started in early 2026. The project by September 2026 (at the moment of writing this guide) has more than 180 pull requests, more than ten development phases, six LLM platforms in five roles, and quite a number of setbacks that taught more than the successes did.

**Who this is for.** An architect-engineer, or a small team, who wants AI agents to do most of the coding while a human keeps the architecture, the evidence, and controls the merge button. Assumptions - you can read code and run a build. The guide is designed to be agnostic - it does not assume any particular language, framework, or vendor.

**How to read it.** The guide has seven chapters; each takes about 10–15 minutes to read. Read chapters 1–3 before you start a project, go to chapters 4–5 when you write your first prompts, finally - to chapters 6–7 when your first phase closes. 
The `templates/` folder is what you use for your repo.

**How to read the rules.** Three kinds of statement appear in the guide, and they carry different weight: something *observed on the source project* (a number, an incident), a *recommended default* (five reviewers, a size threshold, a reading budget - adapt these), and a *mandatory constraint* (state lives in the repository, checkpoints stop the agent, every AI output is checked before it is used). Where a sentence is categorical, it is one of the third kind or it is the author's opinion, marked as such.

**Smallest version.** If your change is small, use [the minimum workflow](00-minimum-workflow.md) - one page - and add the other roles and artifacts only when the risk calls for them.

## One warning-recommendation by the author

To readers of this guide - if you have only one rule to remember when doing AI-assisted software development, it would be the following:

__Don't trust AI outputs implicitly!__

The author can't stress the above rule strongly enough! 

You __must__ architect your systems and projects in such a way to **treat AI outputs as untrusted external services.** You **must know** what the expected output of every step is, and have a check that confirms it before you build on it - a build, a test, a grep count, a measurement from the running system, a review. 

With the above said...

## The chapters

| # | Chapter | The one thing it settles |
| --- | --- | --- |
| 0 | [The minimum workflow](00-minimum-workflow.md) | One page for small changes: what to keep, what to skip, and when to add the rest back |
| 1 | [Before you start](01-before-you-start.md) | Limitations - what AI agents can and cannot do, why context windows decide your file sizes, and what the method costs per step |
| 2 | [The operating model](02-operating-model.md) | Project hierarchy: phases → steps → one PR each; five roles you assign to AI agents across several vendors; the pull request as the only place a step is done |
| 3 | [State and continuity](03-state-and-continuity.md) | Continuity - how a new session knows where the last one stopped, without you re-explaining the project to AI - and how to restart after a long pause |
| 4 | [Writing prompts that hold](04-writing-prompts.md) | The prompt skeleton, checkpoints that stop instead of "fixing", scope guards, and when to prescribe code versus specify intent |
| 5 | [Keeping the prompt-writer honest](05-keeping-the-producer-honest.md) | Examines why the session that writes prompts drifts from its own rules, and the mechanical gates (not more prose) that stop it |
| 6 | [Review, verify, close](06-review-verify-close.md) | Multi-reviewer pipelines, evidence over opinion, phase closure, KPIs, and calendars derived from measured cadence |
| 7 | [Pitfalls you will meet](07-pitfalls.md) | Twelve failure patterns with the recognition signal and the prevention for each |

Then: [`templates/`](templates/) (state file, prompt skeleton, setup-and-review, handoff, decision log, audit, restart checklist, lint starter and a minimal runnable linter) and [`examples/esp32-gateway/`](examples/esp32-gateway/README.md) (real excerpts from the source project, with commit references).

## What changed from version 1

Version 1 (written in April 2026) was a 100 KB practitioner's guide developed during the project, as well as raw project documents. It described a method that worked for refactoring phases. However it broke on the next feature phase: the prompt-writing sessions stopped following the guide they were given, and four rounds of audits were needed to find the defects in the produced prompts. Version 2 acts on these lessons and was rewritten with the following in mind:

- Every fact embedded in a prompt is a liability. The method now keeps facts to a minimum and pins each one to a live query.
- Rules need to be enforced by a linter instead of written as prose, because prose rules lose force as their number grows. In the batches after the linter went in, the linted defect classes did not come back; the ones that relied on "read the guide more carefully" did.
- A prompt that contains finished code moves verification from the compiler to human reviewers. So - compile it before you hand the prompt to the agent, or describe the intent and let the agent write the code.
- Verification effort must be tiered by risk; otherwise it grows until it exceeds production effort.
- State lives in the repository - that is the fact and the source of truth. Chat memory, planning notes, and "we decided" are not state until they are committed.

The full list is in [CHANGELOG.md](CHANGELOG.md).

## Results the source project recorded

Observed on one project; the time figures are the operator's estimates, not timed measurements.

| Measure | Before the method | With the method |
| --- | --- | --- |
| Fix cycles per step (review rounds after the first PR) | 2–6 | 0–1 on refactoring phases; ≈1.0 on runtime-firmware phases |
| Sustained cadence, runtime-firmware steps | - | one merged step per ~1.4 calendar days; ~3 h operator time per step (est.) |
| Largest file an agent could edit reliably (on this project) | failed above ~800 lines | monoliths (4,300-line header, 4,000-line JS) split into 8–12 fragments |
| Prompt defect classes enforced by CI lint | 0 | 7 rules (6 blocking, 1 warning): "post-merge deliverables" section titles, testing handed to the human, cross-prompt references, a stale board address, a wrong config filename, pipeline order |

## Origin

This guide grew out of the [ESP32-GW-multi-sensor](https://github.com/GCV-Sleeper-Service/ESP32-GW-multi-sensor) project - a multi-board BLE sensor gateway with an embedded dashboard, built on ESPHome/ESP-IDF, developed by one operator directing Claude, GitHub Copilot, OpenAI Codex, Gemini, and Perplexity in defined roles. The project's own methodology documents (`Docs/development-process-guide.md`, `Docs/writing-guide/`, `Docs/llm-assisted-development-guide.md`, `Docs/templates/`) are the primary sources; the `examples/` folder cites them by path and commit.


## Using the guide outside embedded projects

The method was built on an embedded project. What applies to other projects unchanged are the state file, bounded steps, checkpoints, the review discipline and the closure routine. What must be adapted is the evidence and reality:

| Project/Context | Keep | Replace or add |
| --- | --- | --- |
| Web and backend services | Everything in chapters 2-6 | Board evidence → API and integration checks, service telemetry, staging, rollout and rollback |
| Data pipelines and migrations | State file, decision log, migration rehearsal | Data-quality contracts, reconciliation, idempotency, restore validation |
| Libraries and tools | PR structure, decision log | Compatibility matrix, public-API stability, release checks |
| Prototypes and scripts | The minimum workflow only | Three prompt files and a fixed review pipeline cost more than the change |
| Large teams or regulated work | As a supporting layer | Ownership, concurrent changes, formal requirements and the applicable assurance controls; one state file and a single "next step" need rethinking with several teams |

These are adaptation notes, not results: the guide has been used on one project.

## About the author

Irakli Natsvlishvili - sole author and architect of the [ESP32-BLE Gateway project](https://github.com/GCV-Sleeper-Service/ESP32-GW-multi-sensor/)

How this guide was written: the text was drafted with AI assistance (Claude), working from the project's own documents, session records and audits, and then checked, corrected and edited/rewritten by the author, who owns every claim in it. That is the method the guide describes, applied to the guide itself.

## License

MIT - see [LICENSE.txt](LICENSE.txt).