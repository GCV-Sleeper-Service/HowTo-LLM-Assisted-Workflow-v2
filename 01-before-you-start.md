# 1. Before you start

__Decide three things before the first prompt:__
- what each agent is allowed to do
- how big a file an agent may edit
- how many sessions per step you will need and can afford

Everything else in this guide is downstream of those three.

## 1.1 What agents can and cannot do

The table is blunt on purpose and deliberately. Why? Because every "cannot/do not" in the rows below cost the source project at least one day wasted.

| Agents reliably do | Agents reliably do not |
| --- | --- |
| Translate a precise, bounded instruction into working code, tests, and matching docs | Hold state between sessions! Every session starts from zero and reconstructs the world from what you hand it |
| Apply a __known to them pattern__ consistently across many files | Verify their own assumptions unless a command in the prompt forces it |
| Find defects when given a focused specific checklist and a diff  | Resist a plausible explanation - they will build a sophisticated and easy to believe theory __before__ running the one-line check that falsifies it |
| Run builds, tests, deployments, and post the output | Notice that a fact stated in the prompt can be stale — a wrong IP, a renamed file, a moved function is executed as written without checking first |
| Write the tedious parts of documentation from real command output | Remember recommendations or requirements made in a previous session (first line above) - a recommendation not turned into a tracked item is gone! |
| Review each other's work — different models catch different defect classes | "Optimise" a prompt safely, without affecting the quality/deliverables. When asked to shorten another model's prompt, they strip the safety constraints first! |

The consequence for design: **the operator supplies factual and accurate context, bounded instructions, and verification gates; the agent supplies labour.** 

When one of above three is missing, the output is: confident, plausible (and believable), and wrong!

## 1.2 Context windows decide your file sizes

Why this is important - an agent edits a file it can hold whole. On the source ESP32 project, agents began making partial edits and started missing cross-references once files passed roughly 800 lines. In the project there were two monoliths (a 4,300-line C++ header and a 4,000-line JavaScript file). As a result, each needed a dedicated refactoring phase to split into 8–12 fragments assembled at build time. 

Those two phases translated into a month time spent into refactor and delivered zero features. So, avoid this costly lesson by following the rules:


- **File sizes to edit: plan the split when a file crosses ~2,000 lines, not when agents start failing.** When agents start failing, it is already late - the failure looks like rising fix cycles due to coding errors (from 0–1 to 3+), not like a context error.
- **Many vs. One: prefer many small files with a deterministic assembly step over one large file.** Process: agents edit fragments; a script produces the artifact; a CI check confirms the artifact matches the fragments. Important: generated files are never edited by hand.
- **Agent budget: reading too, not just editing.** A planning session that reads a 15 K-token methodology guide, a 30 K-token phase plan, and a prompt bundle has spent 60–80 K tokens before producing *anything*. See chapter 3 on session types and reading budgets.
- **Prompt sizes - they count against the same context window.** Example - a 30 KB prompt that embeds the finished code leaves the agent's context window little room to read the code it is changing.

__One important note__ - context window size is dependent on many factors - model, model version, vendor, provider/platform, subscription type, etc. Models from the same vendor with the same version/release can have different context sizes when offered directly from the vendor or through other platform or tool (like VSC plugin) - it would be beneficial to check and find out about this in advance.

## 1.3 What a step costs

The cost is measured basically in Operator's time spent on a step. Measured on the source ESP32 project, one merged step of runtime code — prompt, agent run, reviews, device test, merge — took **1.5–3 hours of operator time and 7–8 LLM sessions**. Sustained cadence over 25 days of runtime-firmware work was one merged step per 1.4 calendar days. Mechanical refactoring steps ran at three to six per day.

Your numbers for your own project most likely will be different. But the important takeaway is following - the most expensive resource is your time. It is not tokens but the operator's attention during review orchestration as well as the high-capability model's rate limit and context window during planning. From these two rules emerge:

- **Use the most capable (and most limited/expensive) and highest context window size model only for planning and prompt production.** Execution/coding and reviews run on mid-tier models with tool access; the prompt provided to them does the reasoning for them - they just need to follow _properly written_ prompt.
- **Size a phase so its prompt production fits one planning session.** If producing the prompts for a phase exhausts the planning model's allocation, the phase is too big and needs to be splitted.

## 1.4 Why more than one vendor and models

Not for redundancy — for diversity and failsafe. On the source project one reviewer caught roughly 60 % of defects, three caught ~85 %, five ~92 %, and the incremental catches from reviewers four and five were rare but occasionally critical (example - a socket-level security defect found just by one reviewer from five). Different model families fail differently; the same family reviewing its own output shares its blind spots. So - employ different models from different vendors.

The price is the time spent on reviews: triggering five reviewers on three platforms and correlating their findings took 30–60 minutes per step.

## 1.5 The operator's job

You - __the Operator__ - are the driver behind the wheel, not a passenger. Here are partial list of responsibilities of the operator across a phase: 

- read and approve every prompt that was produced by the prompt producing session
- read every review left by agent reviewers
- run every test on a physical hardware that an agent cannot run or emulate
- decide every merge
- and maintain the one file that tells the next session where things stand. 

**If you cannot give a project that attention on the days it runs, this/guide method degrades into UNVERIFIED/UNTESTED/UNCONFIRMED agent output — which is WORSE than doing development with no agents - see the [One warning-recommendation by the author in the readme](README.md#one-warning-recommendation-by-the-author).**

> **From the source project.** The operator's own note after four months: "this is interesting... the sessions that produce prompts for the coding agents did not themselves follow the guide they produced!"

The agents had done exactly what the prompts said. But the prompts were wrong! Chapter 5 is about that.

## 1.6 Checklist before the first phase

- [ ] Every generated artifact has a source and a build step; nobody edits artifacts
- [ ] No source file over ~2,000 lines. If more than that, a refactoring step is your first step
- [ ] The operators and the agent operate in the same environment - a build, a test suite, and a deployment for example can run from a shell — agents will run them as well
- [ ] Roles assigned to models: Planner model, Runner/Coder and Reviews (see Chapter 2)
- [ ] `CURRENT-STATE.md`, `AGENTS.md`, a decision log, and CI path filtering exist (see templates in this repo)
- [ ] __Write down__ your plans and a realistic cadence target (start from 1 step per 1–2 days for anything that touches runtime behavior)
