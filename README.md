# Examples from the source project

Excerpts from [GCV-Sleeper-Service/ESP32-GW-multi-sensor](https://github.com/GCV-Sleeper-Service/ESP32-GW-multi-sensor) at commit `b64cd77` (2026-05-10, v7.7.1.1) unless stated. They are quoted to show the shape of a working artifact, not as instructions for another project.

## 1. A checkpoint with expected outputs (Chapter 4)

From `Docs/session-log-2026-05-08-v7.7.1.1.md`, the agent's recorded checkpoint results after rewriting two HTTP handlers to stream instead of buffering:

```
grep -c 'send_snapshot_series_chunk_' firmware/core/web-handler.h -> 2
grep -c 'httpd_resp_send_chunk' firmware/core/web-handler.h -> 8
grep -c 'csv\.reserve' firmware/core/web-handler.h -> 0
bash scripts/assemble-sensor-history.sh --check -> PASS
```

Counts, not line numbers; a zero-count check that proves the old pattern is gone; an identity check on the generated artifact.

## 2. The stop-don't-fix comment (Chapter 4)

From `Docs/development-process-guide.md` §3.2:

```
⛔ CHECKPOINT FAILED — <checkpoint name>
Expected: <expected value or condition>
Actual:   <command output>
Command:  <verbatim command>
Action:   STOPPING. NO code changes made. Awaiting operator decision.
```

The guide adds: agents that explain away a checkpoint failure instead of posting this are exhibiting the plausible-narrative trap; the comment forces structured reporting.

## 3. Scope versus tooling side-effects (Chapter 4)

From the same session log, "Stops and recoveries" §3: the prompt listed four mutable files and also required running `scripts/bump-version.sh`, which modifies `dashboard/core/app-shell.js`, `firmware/core/config.h`, `firmware/core/data-model.h`, `scripts/render_sensor_config.py`, and `tests/fixtures/generate-fixtures.js`. The agent ran the canonical script, hit the scope gate, and documented the contradiction rather than pretending the list was complete. The next batch's prompts whitelisted every side-effect file.

## 4. Code in prose (Chapters 4, 5)

`prompts/phase7/v7.7.1.4-agent-prompt-gpt-codex.md` at `b64cd77` directs the agent to add a retention-budget calculator "after the per-device persist functions" while a later task group modifies one of those functions to call the calculator — a C++ declaration-order compile error. Two of three independent auditors of PR #233 found it (`prompts/handoff/phase7/pr-233-third-independent-audit-report-*.md`); the audit template noted no automated check was possible "without a real compile" and scoped it out. The fix (move the insertion point; add a `grep -n` ordering check) was written on 2026-09-01 and is the first item of the restart housekeeping PR. A syntax-only compile of the assembled fragment before dispatch would have found it in seconds.

## 5. In-PR deliverables as the merge gate (Chapter 2)

From `Docs/development-process-guide.md` §2.5: the branch must contain the code, the `CURRENT-STATE.md` update, the changelog entry, the consolidated audit, next-step handoff edits, and every recommendation routed — before the PR may be marked ready. Post-merge work is tagging and closing issues. "If you find yourself opening 'documentation update' PRs the day after a merge, that is the drift this rule prevents."

## 6. Generated artifacts (Chapter 1)

From `AGENTS.md`: five generated files, each with its source and build command, under the heading "Generated Files (NEVER edit directly)", followed by: "Editing generated files instead of sources is a blocking defect." The firmware is nine C++ fragments assembled by a script into one header; the dashboard is twelve core modules and nine components bundled into one JS file and one HTML file.

## 7. Lint in CI (Chapter 5)

`.github/workflows/prompt-lint.yml` runs `scripts/lint-prompts.sh --baseline <base sha>` on every PR touching `prompts/**`. Rules L1–L5 and L7 (stale addresses, wrong filenames, cross-prompt references, forbidden section titles, interactive deploy, missing timeouts) fail the PR; L6 (pipeline order) warns. Added 2026-05-09 (PR #231) after the second batch of prompts repeated defect classes the first batch had already documented in prose.

## 8. The state file (Chapter 3)

`CURRENT-STATE.md` at `b64cd77`: last-verified date, next action, version and phase, last three steps with PR numbers, next five steps, open issues by severity with target step, recently resolved, a validation snapshot with before/after heap and stack numbers, the six-target fleet table with addresses and measurements, unimplemented recommendations with routing, stale documents, an architecture quick reference, and KPI baselines for three phases. About 8 KB — readable in a minute by every session.
