# 1. Before you start

**Decide three things before the first prompt: what each agent is allowed to do, how big a file an agent may edit, and how many sessions per step you can afford.** Everything else in this guide is downstream of those three.

## 1.1 What agents can and cannot do

The table is deliberately blunt. Every "cannot" row cost the source project at least one day.

| Agents reliably do | Agents reliably do not |
| --- | --- |
| Turn a precise, bounded instruction into working code, tests, and matching docs | Hold state between sessions — every session starts from zero and reconstructs the world from what you hand it |
| Apply a known pattern consistently across many files | Verify their own assumptions unless a command in the prompt forces it |
| Find defects when given a focused checklist and a diff | Resist a plausible explanation; they will build a sophisticated theory before running the one-line check that falsifies it |
| Run builds, tests, deployments, and post the output | Notice that a fact in the prompt is stale — a wrong IP, a renamed file, a moved function is executed as written |
| Write the tedious parts of documentation from real command output | Remember recommendations made in a previous session; a recommendation not turned into a tracked item is gone |
| Review each other's work — different models catch different defect classes | "Optimise" a prompt safely; asked to shorten another model's prompt, they strip the safety constraints first |

The consequence for design: **the operator supplies accurate context, bounded instructions, and verification gates; the agent supplies labour.** When one of the three is missing the output is confident, plausible, and wrong.

## 1.2 Context windows decide your file sizes

An agent edits a file it can hold whole. On the source project, agents began making partial edits and missing cross-references once files passed roughly 800 lines; the two monoliths (a 4,300-line C++ header and a 4,000-line JavaScript file) each needed a dedicated refactoring phase to split into 8–12 fragments assembled at build time. Those two phases cost a month and delivered no features.

Rules that follow:

- **Plan the split when a file crosses ~2,000 lines, not when agents start failing.** The failure looks like rising fix cycles (0–1 → 3+), not like a context error.
- **Prefer many small files with a deterministic assembly step over one large file.** Agents edit fragments; a script produces the artifact; a CI check confirms the artifact matches the fragments. Generated files are never edited by hand.
- **Budget reading, not just editing.** A planning session that reads a 15 K-token methodology guide, a 30 K-token phase plan, and a prompt bundle has spent 60–80 K tokens before producing anything. Chapter 3 gives each session type a reading budget.
- **Prompts count against the same window.** A 30 KB prompt that embeds the finished code leaves the agent little room to read the code it is changing.

## 1.3 What a step costs

Measured on the source project, one merged step of runtime code — prompt, agent run, five reviews, device test, merge — took **1.5–3 hours of operator time and 7–8 LLM sessions**. Sustained cadence over 25 days of runtime-firmware work was one merged step per 1.4 calendar days. Mechanical refactoring steps ran at three to six per day; feature steps with hardware validation did not.

Plan with those numbers, not with the demo-day numbers. The most expensive resource is not tokens but the operator's attention during review orchestration and the high-capability model's rate limit during planning. Two rules:

- **Use the most capable (and most limited) model only for planning and prompt production.** Execution and review run on mid-tier models with tool access; the prompt does the reasoning for them.
- **Size a phase so its prompt production fits one planning session.** If producing the prompts for a phase exhausts the planning model's allocation, the phase is too big.

## 1.4 Why more than one vendor

Not for redundancy — for diversity. On the source project one reviewer caught roughly 60 % of defects, three caught ~85 %, five ~92 %, and the incremental catches from reviewers four and five were rare but occasionally critical (a socket-level security defect found by exactly one of five). Different model families fail differently; the same family reviewing its own output shares its blind spots.

The price is orchestration: triggering five reviewers on three platforms and correlating their findings took 30–60 minutes per step by hand. Automate the triggering before you add a sixth reviewer.

## 1.5 The operator's job

You are not a passenger. Across a phase you will: write or approve every prompt, read every review, run every physical test an agent cannot, decide every merge, and maintain the one file that tells the next session where things stand. If you cannot give a project that attention on the days it runs, the method degrades into unreviewed agent output — which is worse than no agents.

> **From the source project.** The operator's own note after four months: "the sessions that produce prompts for the coding agents did not themselves follow the developed guide." The agents had done exactly what the prompts said. The prompts were wrong. Chapter 5 is about that.

## 1.6 Checklist before the first phase

- [ ] Every generated artifact has a source and a build step; nobody edits artifacts
- [ ] No source file over ~2,000 lines, or a refactoring step is the first step
- [ ] A build, a test suite, and a deployment you can run from a shell — agents will run them
- [ ] Roles assigned: which model plans, which executes, which reviews (Chapter 2)
- [ ] `CURRENT-STATE.md`, `AGENTS.md`, a decision log, and CI path filtering exist (templates in this repo)
- [ ] A realistic cadence target written down (start from 1 step per 1–2 days for anything that touches runtime behaviour)
