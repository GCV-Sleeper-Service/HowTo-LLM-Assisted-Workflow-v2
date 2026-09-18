# 3. State and continuity

**A new session must be able to start from one short file and one handoff document, never from a re-explanation by the human.** State that is not committed to the repository does not exist. This chapter is the answer to "how does the next session know where the last one stopped and what is next."

## 3.1 The five-layer knowledge model

Documentation grows faster than any context window. Layer it by how often it is read, and give each session type a reading budget.

| Layer | Content | Size | Who reads it |
| --- | --- | --- | --- |
| 1 — Current state | `CURRENT-STATE.md`: version, last three steps, next three steps, open defects, measurements, unimplemented recommendations, stale documents | ~2 K tokens | Every session, first |
| 2 — Decisions | `decision-log.md`: one line per architectural decision, dated, with a link to the source | ~3 K tokens | Planning sessions |
| 3 — Method | Prompt-writing rules, the process guide, this repository's templates | ~15 K tokens | Prompt-production sessions only |
| 4 — Phase context | The step's prompt bundle plus the critical-rules subset it cites | 10–20 K tokens | Coding agents and reviewers |
| 5 — History | Lessons, postmortems, gap catalogues, old phase results, session logs | 100 K+ tokens | Investigation only; findings are promoted to layers 1–2 |

Reading budgets: planning ≈ layers 1–3 plus the relevant slice of 5 (40–60 K tokens); prompt production ≈ layers 1–2 plus the current phase plan (15–25 K); agent execution ≈ layer 1 plus its bundle (10–15 K); review ≈ layer 1 plus the diff plus the checklist (5–10 K). Loading layer 5 into an execution session is a defect.

## 3.2 `CURRENT-STATE.md`

One file at the repository root, updated inside every PR that changes shipped state, carrying a `Last verified` date. Sections, in order: version and phase; what just shipped (last three steps with PR numbers); what is next; open issues by severity; measurements the plan depends on (heap, sizes, test counts — with the date they were taken); unimplemented recommendations with where each is routed; stale documents that must not be trusted until updated; a short architecture quick-reference; KPI baselines.

Two rules keep it honest:

- **Freshness.** If `Last verified` is more than one step old, the session runs verification before trusting a single number in it.
- **Routing.** Every recommendation from any postmortem, closure, or review lands either as a tracked issue or as a line in the "unimplemented recommendations" table. There is no third option. The source project lost a critical health-check recommendation for six weeks because it lived in an archived postmortem no prompt ever listed as required reading; the failure it would have caught then cost three days.

Template: [`templates/CURRENT-STATE.template.md`](templates/CURRENT-STATE.template.md).

## 3.3 Handoffs

Each step's bundle includes a **session handoff**: what the step does and does not do, its risk tier, the state snapshot it was written against, the critical rules that apply, a risk table with mitigations, and "context that carries forward" for the next step. The handoff for step N+1 is written or amended *inside step N's PR* if step N discovered anything that changes it. That is the checkpoint mechanism: every merge leaves the next session's starting point already written.

A handoff is self-contained. If its scope section says "see the previous prompt", that is a blocking defect — the next session may not have that prompt, and a lint rule should catch the phrase (Chapter 5).

## 3.4 The decision log

One line per decision: date, an identifier, the decision in one sentence, a link to where the reasoning lives. Nothing else. Planning sessions read it in a minute; the full ADR is opened only when a decision is being reconsidered. Every session that makes an architectural choice appends a line as a deliverable of that session.

> **From the source project.** Decisions PLAN-001 to PLAN-011 were logged in one planning session on 2026-05-07. Four months later, a calendar was proposed that contradicted PLAN-005 (phase order) and the cloud-target decision without anyone noticing — because the calendar was made in a conversation, not against the log. The fix is procedural: a calendar or plan that changes a logged decision writes the superseding line first.

## 3.5 Restarting after a pause

A pause longer than a few weeks turns three things that used to agree into three sources that may not: the repository, the planning documents, and the last conversation. Treat them as such.

Restart protocol, in order:

1. **Environment.** Confirm every system you deploy to still answers and reports the version you last flashed; confirm the toolchain is at the pinned version (auto-updated toolchains silently drop local patches); run one no-op build; confirm each agent platform still connects.
2. **Repository.** `git log` since the last known commit; open issues and milestones; the state file's `Last verified` date. Anything the last conversation said was "done" that is not in the log or on the tracker is *not done*.
3. **Documents.** For each plan the next phase depends on: does its date predate the last refactor? Does it contradict the state file? Rank by the source-of-truth hierarchy and record which is wrong.
4. **Conversation.** Read the last working session end to end. Extract its deliverables (bundles, edit lists, closure commands) and check each against step 2. Unapplied deliverables become the first PR.
5. **One housekeeping PR** that corrects stale documents, closes shipped-but-open issues, applies unapplied fixes, and bumps `Last verified` with the step-1 results. Only then dispatch the next code step.

> **From the source project.** The restart in September 2026 found: a bundle of eight prompt fixes produced on 1 September and never committed; three issues open for work shipped in May; the project's memory notes recording the closures as done; a critical bug listed as open in three documents and resolved in the code; and a v1.0 date set on the assumption that the bug was still open. The housekeeping PR was one day. Discovering the same facts mid-step would have been a week.

Checklist: [`templates/restart-checklist.md`](templates/restart-checklist.md).

## 3.6 What chat memory is for

Model memory and project notes are useful for tone, preferences, and orientation. They are not state. Two rules: never let a memory note record a *plan* in the past tense, and never let a session act on a memory claim about repository state without checking the repository. Both failures happened on the source project within one session.
