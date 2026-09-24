# Changelog

## v2.3 - 2026-09 (follow-up review)

Changes made in response to a follow-up review of v2.2 at `c776ada` (24 September 2026). Every finding was reproduced before being acted on. The main one was that v2.2 announced template fixes that were not in the commit.

- Templates, now actually changed: the PRE-PR gate calls `scope-gate.py`, which checks committed, staged, unstaged and untracked changes against the allowed set (an allowed file need not change; renames need both paths allowed; git errors fail the gate); §1 verifies the feature branch instead of checking out `main`; generated outputs are in the MAY list and may only be regenerated, never hand-edited; checkpoints are executable and distinguished from failing tests; the failure comment reports changes already made and `git status`; the assumption audit has a platform-capability table; handoff and state templates record commit SHAs and deployed builds; the restart checklist re-validates old fixes and keeps code fixes out of the documentation PR; the templates index lists every file.
- `lint-prompts-starter.sh`: baseline mode compares the same rule on the exact same line, so text elsewhere in the old file can no longer hide a new violation; an invalid baseline ref fails.
- New `tests/run-tests.sh`: 29 regression cases for the scope gate and the linter, each in a throwaway repository, run in CI. They fail against the v2.2 linter.
- Minimum workflow: "Update the state, then merge."
- Chapters 1, 2, 3, 4, 6, 7: time figures labeled as estimates and cadence as measured; the file-size threshold is the project's choice, with the source project's number as an example; hierarchy items 1-2 scoped and the worked example corrected (code shows the fix exists, a measurement shows it works); prompt-production reading includes the method layer; agents take instructions only from the prompt and the files it names; the checkpoint-save KPI no longer sets a minimum; lint keeps one line of intent everywhere; two broken §2.7 links fixed.

## v2.2 - 2026-09 (external review)

Changes made in response to an independent review of v2.1 (24 September 2026); the review's findings were verified before being acted on.

- Templates: `setup-and-review.template.md` and `lint-prompts-starter.sh` were added. **Correction (v2.3):** this entry also announced fixes to the existing templates - the scope gate, the checkpoint-failure comment, generated artifacts, the capability-citation table, commit SHAs in the handoff and state templates. They were lost while the patch was being prepared and are not in the v2.2 commit. They are in v2.3.
- Chapter 2: the source-of-truth list is scoped to "what is the project's state"; behavior is settled by version-identified measurements and intent by the approved plan; documentation-only steps may use fewer reviewers if decided in advance.
- Chapter 4: checkpoints (stop) distinguished from ordinary failing tests (fix within scope); executable checks preferred over comment expectations; new Section 4.9 on permissions and release (least privilege, protected main, named deployment targets, untrusted content, rollback evidence).
- Chapter 5: a linted rule keeps one line of intent; only its explanation is deleted.
- Chapter 6: KPI wording no longer treats zero fix cycles as proof of completeness; the structured review is identified as one of the five, not a sixth.
- Chapter 1 and README: "every session starts from zero" softened to "assume no reliable state"; file-size figures and reviewer-detection percentages labeled as this project's observations and estimates; results table renamed "recorded"; a legend for observed / recommended / mandatory statements; a new one-page minimum workflow (`00-minimum-workflow.md`); an adaptation table for other kinds of development; an authorship disclosure.
- Copyedits from the review.

## v2.1 - 2026-09 (corrections)

- Factual corrections: pull-request count; what the audits found and what was left open; the lint evidence stated with its sample size; the source project's lint rules listed as they are; the quote in Section 2.6 attributed to the architect session; the May-September gap described as a pause, not a process failure.
- New Section 2.7 (the assumption audit before any plan), a decision-log rule in 3.4, a secrets warning in 4.7, and review-orchestration advice in 6.1.
- "Ten sections" renamed to "the prompt skeleton"; "two-step prompt" renamed to "setup-and-review prompt"; inline/online, reviewer tier and audit timing made consistent; broken anchor fixed.
- Templates: the consolidated audit is completed after the last review round, before merge; the lint starter separates the source project's rules from candidates.
- Author byline, `LICENSE.txt`, `CITATION.cff`.

## v2.0 - 2026-09 (complete rewrite)

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
