# AI (LLM)-Assisted Software Development — A Working Method (v2)

**Why this guide exists.** It is deep conviction of the author of the project that people who will engage with agentic AI software development sooner or later will release necessity of similar guide for their own project. Thus the purpose of this guide - to save them time and flustration and offer something that works - a project-agnostic guide for building software with AI architecting and coding agents from more than one vendor, without losing control of quality, state, or your own time. 

Every rule in the guide was taken from a real project: an open-source ESP32 sensor-gateway firmware developed almost entirely through AI agents that started  early 2026. The project by September 2026 (at the moment of writing this guide) has 230+ pull requests, more than ten development phases, six LLM platforms in five roles, and had quite number of setbacks that taught more than the successes did.

**Who this is for.** An architect-engineer, or a small team, who wants AI agents to do most of the coding while a human keeps the architecture, the evidence, and the merge button. Assumptions - you can read code and run a build. The guide is designed to be agnostic - it does not assume any particular language, framework, or vendor.

**How to read it.** Guide has seven chapters, on each you spend about 10–15 minutes to read. Read chapters 1–3 before you start a project, go to chapters 4–5 when you write your first prompts, finally - to chapters 6–7 when your first phase closes. 
The `templates/` folder is what you use for your repo.

## The chapters

| # | Chapter | The one thing it settles |
| --- | --- | --- |
| 1 | [Before you start](01-before-you-start.md) | Limitations - what AI agents can and cannot do, why context windows decide your file sizes, and what the method costs per step |
| 2 | [The operating model](02-operating-model.md) | Project hierarchy: phases → steps → one PR each; five roles you assign to AI agents across several vendors; determine the only source of truth - the pull request  |
| 3 | [State and continuity](03-state-and-continuity.md) | Continuity - how a new session knows where the last one stopped, without you re-explaining the project to AI — and how to restart after a long pause |
| 4 | [Writing prompts that hold](04-writing-prompts.md) | The ten-section prompt, checkpoints that stop instead of "fixing", scope guards, and when to prescribe code versus specify intent |
| 5 | [Keeping the prompt-writer honest](05-keeping-the-producer-honest.md) | Examines why the session that writes prompts drifts from its own rules, and the mechanical gates (not more prose) that stop it |
| 6 | [Review, verify, close](06-review-verify-close.md) | Multi-reviewer pipelines, evidence over opinion, phase closure, KPIs, and calendars derived from measured cadence |
| 7 | [Pitfalls you will meet](07-pitfalls.md) | Twelve failure patterns with the recognition signal and the prevention for each |

Then: [`templates/`](templates/) (state file, prompt skeleton, handoff, decision log, audit, restart checklist, lint starter) and [`examples/esp32-gateway/`](examples/esp32-gateway/README.md) (real excerpts from the source project, with commit references).

## What changed from version 1

Version 1 (written in April 2026) was a 100 KB practitioner's guide developed during the project, as well as raw project documents. It described a method that worked for refactoring phases. However it broke on the next feature phase: the prompt-writing sessions stopped following the guide they were given - four rounds of audits found the defects in the produced promts, the fixes were documented and never applied. Version 2 of the guide is rewritten with the following in mind:

- Every fact embedded in a prompt is a liability; the method now minimises facts and pins each one to a live query.
- Rules need to been forced by a linter instead of written as prose that attenuate with volume: defect classes that got a lint rule stopped recurring; those expressed as "read the guide more carefully" recurred every time.
- A prompt that contains finished code has moved verification from the compiler to human reviewers. Compile it before dispatch, or specify intent and let the agent write it.
- Verification effort must be tiered by risk, or it grows until it exceeds production effort and the project stops.
- State lives in the repository that is the fact and source of truth. Chat memory, planning notes, and "we decided" are not state until they are committed.

The full list is in [CHANGELOG.md](CHANGELOG.md).

## Results the source project measured

| Measure | Before the method | With the method |
| --- | --- | --- |
| Fix cycles per step (review rounds after the first PR) | 2–6 | 0–1 on refactoring phases; ≈1.0 on runtime-firmware phases |
| Sustained cadence, runtime-firmware steps | — | one merged step per ~1.4 calendar days; ~3 h operator time per step |
| Largest file an agent could edit reliably | failed above ~800 lines | monoliths (4,300-line header, 4,000-line JS) split into 8–12 fragments |
| Defect classes stopped by CI lint | 0 | 7 rule classes (stale IPs, filenames, forbidden section titles, cross-prompt references, ordering) |

## Origin

This guide grew out of the [ESP32-GW-multi-sensor](https://github.com/GCV-Sleeper-Service/ESP32-GW-multi-sensor) project — a multi-board BLE sensor gateway with an embedded dashboard, built on ESPHome/ESP-IDF, developed by one operator directing Claude, GitHub Copilot, OpenAI Codex, Gemini, and Perplexity in defined roles. The project's own methodology documents (`Docs/development-process-guide.md`, `Docs/writing-guide/`, `Docs/llm-assisted-development-guide.md`, `Docs/templates/`) are the primary sources; the `examples/` folder cites them by path and commit.

## License

MIT.
