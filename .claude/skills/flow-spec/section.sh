#!/usr/bin/env bash
# Prints one section of the Garblo Flow Spec as plain text.
# Usage: bash .claude/skills/flow-spec/section.sh <anchor>     e.g. uc-03, data, design
#        bash .claude/skills/flow-spec/section.sh --list       anchors and titles
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
spec="$root/docs/tasks/mobile/Garblo Flow Spec.html"

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <anchor> | --list" >&2
  exit 2
fi

if [[ "$1" == "--list" ]]; then
  grep -A1 -E '<section[^>]*id=' "$spec" | grep eyebrow | sed -E 's/<[^>]+>//g; s/^ +//; s/&amp;/\&/g' |
    paste -d'|' <(grep -oE '<section[^>]*id="[^"]+"' "$spec" | sed -E 's/.*id="([^"]+)"/\1/') -
  exit 0
fi

# Top-level anchors are <section id="...">; inner anchors (bl-*, ...) live inside one.
if ! grep -q "<section[^>]*id=\"$1\"" "$spec"; then
  line="$(grep -n "id=\"$1\"" "$spec" | head -1 | cut -d: -f1 || true)"
  if [[ -z "$line" ]]; then
    echo "No anchor '$1'. Run with --list." >&2
    exit 1
  fi
  echo "'$1' is an inner anchor at line $line; printing 40 lines from there." >&2
  sed -n "${line},$((line + 40))p" "$spec" | sed -E 's/<[^>]+>/ /g; s/[ \t]+/ /g' | grep -v '^\s*$'
  exit 0
fi

awk -v id="$1" 'index($0, "id=\"" id "\"") && /<section/ {p=1} p {print} p && /<\/section>/ {exit}' "$spec" |
  sed -E 's/<(br|\/p|\/li|\/tr|\/h[1-6]|\/div)[^>]*>/\n/g; s/<[^>]+>/ /g;
          s/&amp;/\&/g; s/&rsaquo;/›/g; s/&lt;/</g; s/&gt;/>/g; s/&nbsp;/ /g; s/[ \t]+/ /g' |
  grep -v '^\s*$'
