#!/usr/bin/env bash
# lint-prompts-starter.sh - minimal prompt linter (see lint-rules-starter.md).
# Usage: lint-prompts-starter.sh [--baseline <git ref>] <file>...
#   --baseline REF   fail only on ERROR lines that are not already present in REF's version of the file
# Exit 1 on any new ERROR; WARN lines never fail the run.
# Edit the pattern lists below for your project. Each rule is one defect class that has recurred.
set -euo pipefail

# Rules: id<TAB>extended-regex<TAB>meaning  (fields separated by a TAB so the regex may contain '|')
ERROR_RULES=(
  $'L1\tPost-Merge Deliverables\tdocumentation deferred to after merge (allowed title: "Post-merge bookkeeping (tag and close only)")'
  $'L2\t^#.*\\(for Human\\)\tagent-doable work assigned to the human in a section header'
  $'L3\t[Ss]ee (v[0-9]+(\\.[0-9]+)+ )?(prompt|step) \tcross-prompt reference; scope and constraints must be inlined'
  $'L4\t192\\.168\\.0\\.199\tretired target address (replace with your own retired addresses)'
  $'L5\told-config-name\\.yaml\trenamed config file (replace with your own)'
)
WARN_RULES=(
  $'L6\t--check.*--write\tidentity check before regeneration; confirm the order is intentional'
)

baseline=""
if [[ "${1:-}" == "--baseline" ]]; then baseline="$2"; shift 2; fi
[[ $# -gt 0 ]] || { echo "usage: $0 [--baseline REF] <file>..." >&2; exit 2; }

scan() { # $1 = text, $2 = rule; prints "id<TAB>line<TAB>content"
  local id re
  IFS=$'\t' read -r id re _ <<< "$2"
  printf '%s' "$1" | grep -nE -- "$re" | while IFS=: read -r ln content; do printf '%s\t%s\t%s\n' "$id" "$ln" "$content"; done || true
}

status=0
for f in "$@"; do
  text=$(cat "$f")
  base_text=""; [[ -n "$baseline" ]] && base_text=$(git show "$baseline:$f" 2>/dev/null || true)
  for rule in "${ERROR_RULES[@]}"; do
    IFS=$'\t' read -r id _ meaning <<< "$rule"
    while IFS=$'\t' read -r rid ln content; do
      [[ -z "$rid" ]] && continue
      if [[ -n "$base_text" ]] && printf '%s' "$base_text" | grep -qF -- "$content"; then
        echo "EXISTING $rid $f:$ln: $content"          # already in baseline: reported, not failing
      else
        echo "ERROR    $rid $f:$ln: $content    <- $meaning"; status=1
      fi
    done < <(scan "$text" "$rule")
  done
  for rule in "${WARN_RULES[@]}"; do
    IFS=$'\t' read -r id _ meaning <<< "$rule"
    while IFS=$'\t' read -r rid ln content; do
      [[ -z "$rid" ]] && continue
      echo "WARN     $rid $f:$ln: $content    <- $meaning"
    done < <(scan "$text" "$rule")
  done
done
exit $status
