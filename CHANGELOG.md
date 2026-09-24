# Changelog

## v2.1 - 2026-09 (corrections)

- Factual corrections: pull-request count; what the audits found and what was left open; the lint evidence stated with its sample size; the source project's lint rules listed as they are; the quote in Section 2.6 attributed to the architect session; the May-September gap described as a pause, not a process failure.
- New Section 2.7 (the assumption audit before any plan), a decision-log rule in 3.4, a secrets warning in 4.7, and review-orchestration advice in 6.1.
- "Ten sections" renamed to "the prompt skeleton"; "two-step prompt" renamed to "setup-and-review prompt"; inline/online, reviewer tier and audit timing made consistent; broken anchor fixed.
- Templates: the consolidated audit is completed after the last review round, before merge; the lint starter separates the source project's rules from candidates.
- Author byline, `LICENSE.txt`, `CITATION.cff`.

## v2.0 - 2026-09 (rewrite)

**Structure.** One README, seven chapters of 10–15 minutes each, a `templates/` folder you copy, and an `examples/` folder that cites the source project by path and commit. Version 1's 100 KB guide and eight raw project documents are superseded.

**New content, all from evidence after 2026-04-06 (the last v1 commit):**

- Chapter 1: agent capability matrix; context-window arithmetic for file size and reading budgets; measured cost per step (7–8 LLM sessions, 1.5–3 h); why multi-vendor is a diversity and failsafe decision, not a redundancy decision.
- Chapter 2: in-PR deliverables as the merge gate (nothing documented "after merge"); risk tiers that set producer-side auditor counts and prompt style (reviewer count is a per-project constant); the source-of-truth hierarchy.
- Chapter 3: the five-layer knowledge model with per-session reading budgets; handoff-inside-the-PR; restart-after-pause protocol (three sources that may disagree: repo, docs, last conversation); "memory recorded a plan as done" as a named failure.
- Chapter 4: two prompt styles (prescriptive vs intent-and-acceptance) chosen by risk; "every embedded fact is a liability"; compile-before-dispatch for embedded code; measured values as placeholders; symbol anchors; tool side-effects in the scope whitelist.
- Chapter 5: the eight producer failure modes; the live-extract gate; doctrinal value pinning; lint-first enforcement with a rule budget; the audit arms race and the meta-freeze rule; per-batch process metrics.
- Chapter 6: assess-then-fix review prompt; consolidated audit with a prompt-quality score; calendars derived from measured cadence with ±40 % uncertainty; phase closure that routes every recommendation.
- Chapter 7: twelve pitfalls, each with a recognition signal and a prevention, and an early-warning dashboard of three numbers.

**Removed from v1.** Raw project files (changelog, bugs-and-lessons, architecture plan, phase plan, session log, prompt index, handoff, audit). They were 85 % of v1's size and were project-specific by construction. Excerpts that carry general lessons are in `examples/`.

## v1.0 - 2026-04-06

Initial publication: practitioner's guide (101 KB) and eight reference documents from the ESP32-GW-multi-sensor project at v7.6.0.x (Phase D).
