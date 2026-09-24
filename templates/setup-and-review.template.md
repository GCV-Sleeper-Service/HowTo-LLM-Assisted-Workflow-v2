# Setup and review - <step id>

_Two blocks. Block A goes to the coding agent before the agent prompt. Block B goes to the reviewers after the inline reviews land. Never paste block B to the agent._

## Block A - agent setup (paste first, then the agent prompt)

If there is no checkout yet, clone the repository once first.

```
1) Confirm the checkout has no unrelated work (git -C <repo path> status --short is empty), then:
   git -C <repo path> fetch origin main
   git -C <repo path> checkout -b <feature branch> origin/main
   Stop on any failure.
2) Make an empty bootstrap commit, push the branch, open a DRAFT PR to main titled
   "<step id>: <title> (Fixes #<issue>)"
3) Post the PR URL immediately
4) Read the required files in the order the prompt gives, run the §2 gate, then start
5) Commit only to this branch, never to main
6) When done: mark the PR ready for review
7) PR description: Pre-implementation verification, Per-item verification,
   Acceptance criteria, Files modified (with the scope-gate output), Round summary
```

## After the inline reviews - one line to the agent, verbatim every time

> Please analyze the code reviews and comments for the PR. Assess if they are warranted; if yes, implement the necessary fixes. Post a comment summarizing your assessment and the work performed.

## Block B - reviewer checklist (external reviewers)

Step: <step id> · Risk tier: <LOW | MEDIUM | HIGH> · PR: <url>

Read the diff and the PR body. For each item below, answer pass / fail / not applicable with a one-line reason. Quote offending content verbatim. Propose a concrete fix for every fail. "Looks good" is not a review.

| # | Check |
| --- | --- |
| 1 | Every §7 acceptance criterion is met, with evidence in the PR body (not restated, shown) |
| 2 | The scope-gate output in the PR body says PASS, and the diff agrees with it; generated files were regenerated, not hand-edited |
| 3 | Every checkpoint output in the PR body matches its expected value |
| 4 | <step-specific check: the interface contract, the data path, the migration, …> |
| 5 | <step-specific check> |
| 6 | <step-specific check> |
| 7 | Device or system evidence exercises the acceptance criterion as written (full-length, smallest target) |
| 8 | Session log, consolidated audit, state file and changelog are in the branch |
| 9 | No credentials, tokens or private data in the diff, the PR body or posted logs |
| 10 | Findings classified by severity; each one has a proposed fix |

Severity: HIGH = wrong behavior, data loss, security, or a broken gate; MEDIUM = wrong but contained; LOW = wording, style, or a missing note.
