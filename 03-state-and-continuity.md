# 3. State and continuity

This chapter is the answer to "how does the next session know where the last one stopped and what is next." And this is done like this: 

**A new session must be able to start from one short file and one handoff document, NEVER from a re-explanation by the human.** 

Or to write this differently - the state that is not committed to the repository __does not exist__. 

## 3.1 The five-layer knowledge model

This is the fact - documentation grows faster than any context window, __especially__ when documentation is written by AI. Layer it by how often it is read, and give each session type a reading budget.

| Layer | Content | Size | Who reads it |
| --- | --- | --- | --- |
| 1 - Current state | `CURRENT-STATE.md`: version, last three steps, next three steps, open defects, measurements, unimplemented recommendations, stale documents | ~2 K tokens | Read first on every session by every agent |
| 2 - Decisions | `decision-log.md`: one line per architectural decision, dated, with a link to the source | ~3 K tokens | Planning sessions |
| 3 - Method | Prompt-writing rules, the process guide, this repository's templates | ~15 K tokens | Planning and prompt-production sessions |
| 4 - Phase context | The step's prompt bundle plus the critical-rules subset it cites | 10–20 K tokens | Coding agents and reviewers |
| 5 - History | Lessons, postmortems, gap catalogs, old phase results, session logs | 100 K+ tokens | Investigation only; findings are promoted to layers 1–2 |

Approximate reading budgets based on the source project: 
- planning ≈ layers 1–3 plus the relevant slice of 5 (40–60 K tokens)
- prompt production ≈ layers 1–2 plus the current phase plan (15–25 K)
- agent execution ≈ layer 1 plus its bundle (10–15 K)
- review ≈ layer 1 plus the diff plus the checklist (5–10 K). 

Loading layer 5 into an execution session is a defect and complete anti-pattern.

## 3.2 `CURRENT-STATE.md`

__What `CURRENT-STATE.md` is__: one file at the repository root, updated inside every PR that changes shipped state, carrying a `Last verified` date. 

Sections in the file, in order: 

- version and phase
- what just shipped (last three steps with PR numbers)
- what is next
- open issues by severity
- measurements the plan depends on (using data from the current project - heap, sizes, test counts - with the date they were taken and the build they came from)
- which build runs on each deployment target (version and commit), kept separate from what is on `main`
- unimplemented recommendations with where each is routed
- stale documents that must not be trusted until updated
- a short architecture quick-reference
- KPI baselines.

Two rules keep the `CURRENT-STATE.md` honest:

- **Freshness.** If `Last verified` is more than one step old, the session runs verification before trusting a single number in it.
- **Routing.** Every recommendation from any postmortem, closure, or review lands either as a tracked issue or as a line in the "unimplemented recommendations" table. There is no third option. The source project lost a critical health-check recommendation for six weeks because it lived in an archived postmortem no prompt ever listed as required reading; the failure it would have caught then cost three days effort.

Template for this file: [`templates/CURRENT-STATE.template.md`](templates/CURRENT-STATE.template.md).

## 3.3 Handoffs

Each step's bundle includes a **session handoff** with the following sections: 

- what the step does and does not do
- risk tier
- the state snapshot it was written against
- the critical rules that apply
- a risk table with mitigations
- and "context that carries forward" for the next step. 

The handoff for step N+1 is written or amended *inside step N's PR* if step N discovered anything that changes it. As an example: if your step/version is v8.2.1.4 next step is v8.2.1.5. If during the completion of v8.2.1.4 it is necessary to modify session handoff for v8.2.1.5 to update for the current reality/state, it is done during the v8.2.1.4 step/PR by the coding agent acting on proper instructions.

That is the checkpoint mechanism: every merge leaves the next session's starting point already written.

A handoff is self-contained. If its scope section says "see the previous prompt", that is a blocking defect of the document - the next session may not have that prompt, and a lint rule should catch the phrase (see [Chapter 5](05-keeping-the-producer-honest.md)).

## 3.4 The decision log

One line per decision: date, an identifier, the decision in one sentence, a link to document where the reasoning lives. Nothing else. Planning sessions read it in a minute; the full Architecture Decision Record (ADR) is opened only when a decision is being reconsidered. Every session that makes an architectural choice appends a line as a deliverable of that session.

One more rule: a plan or calendar that changes a logged decision writes the superseding line in the log first. Otherwise the newest conversation silently overrides the log, and nobody notices until two documents disagree.

## 3.5 Restarting after a pause

A pause of more than a few weeks in a project's development changes things. Three sources that used to agree - the repository, the planning documents and the last conversation - may not agree anymore. Treat them as three separate sources and check each one.

Restart protocol, in this order (the source project is the example):

1. **Environment.** Check that every system you deploy to is responsive and reports the version you last deployed (in the source project - the firmware version flashed on each board). Check that the toolchain is still at the pinned version - auto-updated toolchains quietly drop local patches. Run one build that changes nothing. Check that every AI agent platform still connects.
2. **Repository.** Read `git log` since the last commit you know, the open issues and milestones, and the `Last verified` date in the state file. Important: anything the last conversation called "done" that is not in the log or on the tracker is *not done*.
3. **Documents.** For each plan the next phase depends on, ask: is it older than the last refactor? Does it contradict the state file? Rank the sources by the hierarchy in [Section 2.5](02-operating-model.md#25-source-of-truth-hierarchy) and write down which one is wrong.
4. **Conversation.** Read the last working session from start to finish - not a summary. List what it produced (prompt bundles, edit lists, closure commands) and check each item against step 2. Whatever was never applied becomes the first PR.
5. **One housekeeping PR.** It corrects the stale documents, closes issues for work that already shipped, applies the fixes that were never applied, and updates `Last verified` with the results of step 1. Only after it merges does the next code step go out.

> **From the source project.** The restart found: a bundle of eight prompt fixes that was produced and never committed; three issues still open for work that shipped in May; the project's memory notes recording those closures as done; a critical bug listed as open in three documents while the code had fixed it; and a v1.0 date set on the assumption that the bug was still open. The housekeeping PR that fixes all of this is about one day of work. Finding the same facts in the middle of a code step would have cost far more.

Checklist: [`templates/restart-checklist.md`](templates/restart-checklist.md).

## 3.6 What chat memory is for

Model memory and project notes are useful for tone, preferences, and orientation - __they are not state__. 

Two rules: 
- never let a memory note record a *plan* in the past tense
- never let a session act on a memory claim about repository state without checking the repository.

Both failures happened on the source project within one session.
