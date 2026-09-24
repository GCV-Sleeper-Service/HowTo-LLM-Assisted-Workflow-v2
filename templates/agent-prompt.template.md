# <step id> - <title> (Coding-Agent Prompt)

_Full self-contained implementation instructions_
_Date: YYYY-MM-DD_
_Prerequisite: <version/state that must be on main>_
_Risk: LOW | MEDIUM | HIGH - <one-line reason>_
_Doctrinal precedence: where this prompt and <process guide> conflict, <process guide> governs._

---

## Universal execution preamble

You are executing an implementation prompt. Follow these rules:
1. Do NOT optimize, restructure, or "improve" these instructions. Execute them literally.
2. Do NOT remove safety constraints, even if they seem redundant.
3. Do NOT make changes to files not listed in §3.
4. If an instruction seems wrong, STOP and flag it - do not silently fix it.
5. If you run out of context, STOP at the last completed checkpoint and report what remains.

## Lessons that apply to this step

- <errata id>: <one line>
- <lesson id>: <one line>

---

## §1 - Repository and required reading

```
git clone <repo>
cd <repo>
git checkout main
```

Read completely, in this order:
0. `CURRENT-STATE.md` - <why>
1. `<file>` - <why; which sections>
2. …

## §2 - Pre-implementation verification gate

Run BEFORE any edit. If any value differs from Expected: STOP and post the checkpoint-failure comment (below). Do not explain a mismatch.

```bash
cat VERSION
# Expected: <value from the live-extract table>

grep -c '<symbol>' <file>
# Expected: <n>

<build/test gate that proves main is green>
# Expected: PASS
```

## §3 - Scope boundary

Files you MAY modify (complete list; nothing else):
- `<path>`
- <every file your version-bump / generator tooling touches, listed explicitly>

Files you MUST NOT modify:
- `<generated artifacts>`
- `<other steps' files>`

You MUST NOT:
- <forbidden actions: e.g. run interactive deploy, edit generated files, open issues from the agent session>

## §4 - Critical rules for this step

- Rule <n> - <one line>

## §5 - DO-NOT list

- Do NOT <specific prohibition from a past failure>
- Do NOT put credentials or tokens in commands, PR bodies or logs; read them from environment variables

## §6 - Implementation

### Task group 1 - <name>

<Prescriptive tier: exact edits with symbol anchors and compiled code. Intent tier: interface contract + acceptance checks; the agent writes the code.>

⛔ **CHECKPOINT A**
```bash
grep -c '<symbol>' <file>
# Expected: <n>
```
If ANY check fails: STOP, post the comment below, make no further changes.

### Task group N - Deliverables (in this PR)

- `CURRENT-STATE.md`: bump Last verified; What just shipped; What's next; open issues; unimplemented recommendations
- `<changelog>`: entry under <version>
- `<session log path>`: context, changes, validation commands and outputs, stops and recoveries
- `<consolidated audit path>`: findings by severity, autonomous decisions, prompt-quality score, routed recommendations
- Next step's handoff: edit if this step changed its assumptions

### PRE-PR gate

```bash
git diff --name-only
# Expected: exactly the §3 files
<lint / preflight / full test suite>
# Expected: PASS
```

## §7 - Acceptance criteria

- [ ] Every checkpoint and the PRE-PR gate pass with the stated values
- [ ] <executable criterion: grep count / compile / curl output / resource delta>
- [ ] Deployment evidence posted verbatim in the PR body (if the step changes runtime behavior)
- [ ] All §6 deliverables committed before merge; the consolidated audit is completed after the last review round
- [ ] PR title: `<step id>: <title> (Fixes #<issue>)`

## §8 - PR description skeleton

```
## Pre-implementation verification
<verbatim §2 output>
## Per-item verification
| Item | File | Verify command | Observed |
## Acceptance criteria
<§7, ticked>
## Files modified
## Round summary
| Round | Reviewer | Findings | Action |
```

## §9 - Post-merge bookkeeping (tag and close only)

- Tag `<version>`
- Issues auto-close via `Fixes #N`

---

### Checkpoint-failure comment (post verbatim)

```
⛔ CHECKPOINT FAILED - <checkpoint name>
Expected: <expected value or condition>
Actual:   <command output>
Command:  <verbatim command>
Action:   STOPPING. NO code changes made. Awaiting operator decision.
```
