# LLM-Assisted Software Development — A Working Method (v2)

A short, project-agnostic guide to building software with AI coding agents from more than one vendor, without losing control of quality, state, or your own time. Every rule in it was paid for on a real project: an open-source ESP32 sensor-gateway firmware developed almost entirely through AI agents from early 2026 to September 2026 — 230+ pull requests, more than ten development phases, six LLM platforms in five roles, and one four-month stall that taught more than the successes did.

**Who this is for.** One engineer, or a small team, who wants AI agents to do most of the typing while a human keeps the architecture, the evidence, and the merge button. It assumes you can read code and run a build. It does not assume any particular language, framework, or vendor.

**How to read it.** Seven chapters, each 10–15 minutes. Read 1–3 before you start a project; 4–5 when you write your first prompts; 6–7 when your first phase closes. The `templates/` folder is what you actually copy into your repo.

## The chapters

| # | Chapter | The one thing it settles |
| --- | --- | --- |
| 1 | [Before you start](01-before-you-start.md) | What agents can and cannot do, why context windows decide your file sizes, and what the method costs per step |
| 2 | [The operating model](02-operating-model.md) | Phases → steps → one PR each; five roles across several vendors; the pull request as the only source of truth |
| 3 | [State and continuity](03-state-and-continuity.md) | How a new session knows where the last one stopped, without you re-explaining the project — and how to restart after a long pause |
| 4 | [Writing prompts that hold](04-writing-prompts.md) | The ten-section prompt, checkpoints that stop instead of "fixing", scope guards, and when to prescribe code versus specify intent |
| 5 | [Keeping the prompt-writer honest](05-keeping-the-producer-honest.md) | Why the session that writes prompts drifts from its own rules, and the mechanical gates (not more prose) that stop it |
| 6 | [Review, verify, close](06-review-verify-close.md) | Multi-reviewer pipelines, evidence over opinion, phase closure, KPIs, and calendars derived from measured cadence |
| 7 | [Pitfalls you will meet](07-pitfalls.md) | Twelve failure patterns with the recognition signal and the prevention for each |

Then: [`templates/`](templates/) (state file, prompt skeleton, handoff, decision log, audit, restart checklist, lint starter) and [`examples/esp32-gateway/`](examples/esp32-gateway/README.md) (real excerpts from the source project, with commit references).

## What changed from version 1

Version 1 (April 2026) was a 100 KB practitioner's guide plus raw project documents. It described a method that worked for refactoring phases and then broke on the next feature phase: the prompt-writing sessions stopped following the guide they were given, four rounds of audits found the defects, the fixes were documented and never applied, and the project shipped zero lines of firmware for four months. Version 2 is rewritten around what that stall proved:

- Every fact embedded in a prompt is a liability; the method now minimises facts and pins each one to a live query.
- Rules written as prose attenuate with volume; rules enforced by a linter do not. Defect classes that got a lint rule stopped recurring; those handled by "read the guide more carefully" recurred every time.
- A prompt that contains finished code has moved verification from the compiler to human reviewers. Compile it before dispatch, or specify intent and let the agent write it.
- Verification effort must be tiered by risk, or it grows until it exceeds production effort and the project stops.
- State lives in the repository. Chat memory, planning notes, and "we decided" are not state until they are committed.

The full list is in [CHANGELOG.md](CHANGELOG.md).

## Results the source project measured

| Measure | Before the method | With the method |
| --- | --- | --- |
| Fix cycles per step (review rounds after the first PR) | 2–6 | 0–1 on refactoring phases; ≈1.0 on runtime-firmware phases |
| Sustained cadence, runtime-firmware steps | — | one merged step per ~1.4 calendar days; ~3 h operator time per step |
| Largest file an agent could edit reliably | failed above ~800 lines | monoliths (4,300-line header, 4,000-line JS) split into 8–12 fragments |
| Defect classes stopped by CI lint | 0 | 7 rule classes (stale IPs, filenames, forbidden section titles, cross-prompt references, ordering) |
| Cost of skipping the method's gates | — | four months, a verification-to-production ratio of roughly 8–10:1, one compile error found by two auditors that a syntax check would have caught in seconds |

## Origin

This guide grew out of the [ESP32-GW-multi-sensor](https://github.com/GCV-Sleeper-Service/ESP32-GW-multi-sensor) project — a multi-board BLE sensor gateway with an embedded dashboard, built on ESPHome/ESP-IDF, developed by one operator directing Claude, GitHub Copilot, OpenAI Codex, Gemini, and Perplexity in defined roles. The project's own methodology documents (`Docs/development-process-guide.md`, `Docs/writing-guide/`, `Docs/llm-assisted-development-guide.md`, `Docs/templates/`) are the primary sources; the `examples/` folder cites them by path and commit.

## License

MIT.
