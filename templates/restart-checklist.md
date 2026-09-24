# Restart checklist (after a pause longer than a few weeks)

Treat the repository, the planning documents, and the last conversation as three sources that may disagree. Work through them in this order; the output is one housekeeping PR.

## 1. Environment (operator)

- [ ] Every deployment target answers and reports the version last deployed to it (record each: name, address, version)
- [ ] Toolchain at the pinned version; local patches/overrides still present (`--check` mode only - never re-apply blind)
- [ ] One no-op build of the primary target passes
- [ ] Every agent platform connects (execution agent, inline reviewers, external reviewers)

## 2. Repository

- [ ] `git log` since the last commit you remember; any branches ahead of main
- [ ] Open issues and milestones; issues open for work that shipped; duplicate milestones
- [ ] `CURRENT-STATE.md` `Last verified` date and its open-issue list versus the code (grep the fix)
- [ ] Lint and preflight pass on main

## 3. Documents

- [ ] For every plan the next phase depends on: date versus last refactor; contradictions with the state file or decision log; platform claims cited to current sources
- [ ] Rank conflicts by the source-of-truth hierarchy; write down which document is wrong

## 4. Last conversation

- [ ] Read it end to end, not the summary
- [ ] List its deliverables (bundles, edit lists, closure commands, decisions)
- [ ] Check each against §2; anything not landed is not done - including anything a memory note or summary says was done

## 5. Housekeeping PR (doc-only, coding agent)

- [ ] Apply unapplied fixes from §4
- [ ] Correct stale documents from §3; add superseding decision-log lines
- [ ] Bump `Last verified` with the §1 results
- [ ] Post-merge: close shipped-but-open issues, merge duplicate milestones
- [ ] Only then dispatch the next code step - the lowest-risk one available
