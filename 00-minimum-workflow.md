# 0. One page minimum workflow

Use this for a start - a small change, a prototype, or a first try of the method. This procedure keeps the parts that protect you and leaves the parts that only pay off at scale for later. When the risk goes up - data, boot paths, anything irreversible, anything a customer runs - move to the full method described in chapters 2-6.

## The eight rules to follow

1. **One change, one branch, one PR**. Write down what "done" means before anyone touches code. If you cannot write it, the task is not ready.
2. **Give the agent current context.** The state file (`CURRENT-STATE.md`) and the files the task touches - nothing else. If the state file is older than the last change, refresh it first.
3. **Write executable acceptance criteria.** Commands with expected outputs that can be measured: a build or a test with pass or fail outcome, a grep count. "It works" is not a criterion.
4. **Let the agent implement on the branch.** Agent runs the build and tests itself and posts the output. If an assumption in the task turns out to be wrong, it stops and says so; it does not adjust the check to fit.
5. **Get one independent review.** A model from another family than the one that wrote the code, or a human. Findings are classified by severity; the agent assesses each one before fixing it (reviewers are sometimes wrong, that includes human reviewers too).
6. **Collect the evidence.** The acceptance-criteria outputs go into the PR body verbatim. For anything that runs on hardware or against a live service, the evidence comes from the running system, not from the code.
7. **Merge, then update the state.** You - the human - do the merge; the agent never does. The state file, the changelog entry and a three-line note on what changed and what was learned are part of the same PR, not a later one.
8. **Write down decisions.** Anything you decided along the way gets one line in the decision log, dated, with a link to where the reasoning is.

## What you are skipping, and when to add it back

| Skipped here | Add it when |
| --- | --- |
| Separate planning and prompt-producing sessions ([Chapter 2](02-operating-model.md)) | The task needs more than one step, or the prompt is longer than the change |
| The three-file prompt bundle and checkpoints between task groups ([Chapter 4](04-writing-prompts.md)) | The agent starts making partial edits, or a step touches something you cannot easily undo |
| Producer gates and lint ([Chapter 5](05-keeping-the-producer-honest.md)) | The same kind of prompt mistake happens twice |
| Five reviewers and the consolidated audit ([Chapter 6](06-review-verify-close.md)) | A defect reaches a running system that a second reviewer would have caught |
| Phase closure and KPIs ([Chapter 6](06-review-verify-close.md)) | You have finished more than a handful of steps and want to know whether the method is paying for itself |

The one rule that does not get skipped, at any size: nothing an AI produced is trusted until a check you defined in advance has confirmed it.
