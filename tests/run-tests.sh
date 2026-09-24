#!/usr/bin/env bash
# run-tests.sh - regression tests for templates/scope-gate.py and templates/lint-prompts-starter.sh.
# Each case runs in a throwaway git repository. Exit 0 only if every case gives its expected exit code.
set -uo pipefail
HERE=$(cd "$(dirname "$0")/.." && pwd)
GATE="$HERE/templates/scope-gate.py"
LINT="$HERE/templates/lint-prompts-starter.sh"
pass=0; fail=0
check() { # $1 name, $2 expected exit, $3 actual exit
  if [[ "$2" == "$3" ]]; then pass=$((pass+1)); printf 'ok    %-58s exit %s\n' "$1" "$3"
  else fail=$((fail+1)); printf 'FAIL  %-58s expected %s, got %s\n' "$1" "$2" "$3"; fi
}
new_repo() { # fresh repo on main with a.txt b.txt c.txt, branch "step" checked out
  cd "$(mktemp -d)" && git init -q -b main . && git config user.name t && git config user.email t@t
  printf 'a\n' > a.txt; printf 'b\n' > b.txt; printf 'c\n' > c.txt; printf '*.log\n' > .gitignore
  git add -A && git commit -qm base && git checkout -qb step
  printf 'a.txt\nb.txt\n' > /tmp/allowed.$$
}
gate() { python3 "$GATE" --allowed /tmp/allowed.$$ --target main "$@" >/dev/null 2>&1; echo $?; }

# ---------- scope gate ----------
new_repo; echo x >> a.txt;                                   check "gate: one allowed file changed (unstaged)" 0 "$(gate)"
new_repo;                                                     check "gate: nothing changed" 0 "$(gate)"
new_repo; echo x >> c.txt; git commit -qam c;                 check "gate: out-of-scope change committed" 1 "$(gate)"
new_repo; echo x >> c.txt; git add c.txt;                     check "gate: out-of-scope change staged" 1 "$(gate)"
new_repo; echo x >> c.txt;                                    check "gate: out-of-scope change unstaged" 1 "$(gate)"
new_repo; echo new > d.txt;                                   check "gate: out-of-scope file untracked" 1 "$(gate)"
new_repo; echo x >> c.txt; git add c.txt; git checkout -q -- c.txt 2>/dev/null; printf 'c\n' > c.txt
                                                              check "gate: staged change reverted in worktree only" 1 "$(gate)"
new_repo; echo out > gen.out; printf 'gen.out\n' >> /tmp/allowed.$$
                                                              check "gate: approved generated output" 0 "$(gate)"
new_repo; git rm -q c.txt;                                    check "gate: out-of-scope deletion" 1 "$(gate)"
new_repo; git mv c.txt a2.txt; printf 'a2.txt\n' >> /tmp/allowed.$$
                                                              check "gate: rename from unapproved path" 1 "$(gate)"
new_repo; git mv b.txt b2.txt; printf 'b2.txt\n' >> /tmp/allowed.$$
                                                              check "gate: rename, both paths approved" 0 "$(gate)"
new_repo; echo x > 'my file.txt'; printf 'my file.txt\n' >> /tmp/allowed.$$
                                                              check "gate: allowed name with a space" 0 "$(gate)"
new_repo; echo x > debug.log;                                 check "gate: ignored file is not reported" 0 "$(gate)"
new_repo; git checkout -q main; echo m >> c.txt; git commit -qam m; git checkout -q step; echo x >> a.txt; git commit -qam a
                                                              check "gate: main moved on after branching (merge-base)" 0 "$(gate)"
new_repo; r=$(python3 "$GATE" --allowed /tmp/allowed.$$ --base nosuchref >/dev/null 2>&1; echo $?)
                                                              check "gate: invalid base" 2 "$r"
new_repo; git checkout -q main; echo m >> c.txt; git commit -qam m; other=$(git rev-parse HEAD); git checkout -q step
r=$(python3 "$GATE" --allowed /tmp/allowed.$$ --base "$other" >/dev/null 2>&1; echo $?)
                                                              check "gate: base not an ancestor of HEAD" 2 "$r"

# ---------- linter ----------
lint() { bash "$LINT" "$@" >/dev/null 2>&1; echo $?; }
new_repo
printf '# Step\n\n## §9 - Post-merge bookkeeping (tag and close only)\n' > clean.md; check "lint: clean input" 0 "$(lint clean.md)"
printf '## §9 - Post-Merge Deliverables\n' > l1.md;          check "lint: L1 post-merge title" 1 "$(lint l1.md)"
printf '## Device testing (for Human)\n' > l2.md;            check "lint: L2 (for Human) header" 1 "$(lint l2.md)"
printf 'see v7.7.1.2 prompt for scope\n' > l3.md;            check "lint: L3 cross-prompt reference" 1 "$(lint l3.md)"
printf 'curl http://192.168.0.199/api\n' > l4.md;            check "lint: L4 retired address" 1 "$(lint l4.md)"
printf 'esphome compile old-config-name.yaml\n' > l5.md;     check "lint: L5 renamed config" 1 "$(lint l5.md)"
printf 'run.sh --check then run.sh --write\n' > w.md;        check "lint: WARN only" 0 "$(lint w.md)"
printf '## Device testing (for Human)\nbody\n' > p.md; git add p.md; git commit -qm p
                                                              check "lint: baseline, unchanged existing violation" 0 "$(lint --baseline HEAD p.md)"
printf 'intro\nmore\n## Device testing (for Human)\n' > p.md
                                                              check "lint: baseline, existing violation moved" 0 "$(lint --baseline HEAD p.md)"
printf '## Device testing (for Human)\nsee v1.2.3.4 prompt again\n' > p.md
                                                              check "lint: baseline, new violation next to existing" 1 "$(lint --baseline HEAD p.md)"
printf 'This is an example: ## Device testing (for Human)\n' > q.md; git add q.md; git commit -qm q
printf '## Device testing (for Human)\n' > q.md
                                                              check "lint: baseline, substring is not the same violation" 1 "$(lint --baseline HEAD q.md)"
printf '## Device testing (for Human)\t\n' > p.md
                                                              check "lint: baseline, line differs by trailing tab" 1 "$(lint --baseline HEAD p.md)"
                                                              check "lint: invalid baseline ref" 128 "$(lint --baseline nosuchref p.md)"

rm -f /tmp/allowed.$$
echo "----"; echo "$pass passed, $fail failed"
[[ $fail -eq 0 ]]
