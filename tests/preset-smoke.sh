#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_ROOT="${ROOT_DIR}/build/preset-smoke"
mkdir -p "$BUILD_ROOT"
ENGINE="${ATSCV_ENGINE:-lualatex}"
command -v "$ENGINE" >/dev/null 2>&1 || { echo "ERROR: $ENGINE not found"; exit 1; }
command -v pdftotext >/dev/null 2>&1 || { echo "ERROR: pdftotext not found"; exit 1; }
shopt -s nullglob
files=("${ROOT_DIR}"/examples/preset-*.tex)
((${#files[@]})) || { echo "ERROR: no preset examples found"; exit 1; }
fail=0
for tex in "${files[@]}"; do
  name="$(basename "$tex" .tex)"; out="$BUILD_ROOT/$name"; mkdir -p "$out"
  echo "Compiling $name"
  if "$ENGINE" -interaction=nonstopmode -halt-on-error -file-line-error -output-directory="$out" "$tex" >"$out/$name.log" 2>&1; then
    pdf="$out/$name.pdf"; txt="$out/$name.txt"; pdftotext "$pdf" "$txt"
    grep -q "ATSCV PRESET loaded" "$out/$name.log" && grep -q "ATSCV CONFIG preset=" "$out/$name.log" && grep -q "ATSCV CONFIG color=" "$out/$name.log" && grep -q "ATSCV CONFIG style=" "$out/$name.log" && grep -q "ATSCV CONFIG language=" "$out/$name.log" || fail=1
    if [[ "$name" == *-de ]]; then grep -q "Zusammenfassung" "$txt" && grep -q "Berufserfahrung" "$txt" || fail=1; else grep -q "Summary" "$txt" && grep -q "Professional Experience" "$txt" || fail=1; fi
    [[ $fail -eq 0 ]] && echo "PASS: $name" || echo "FAIL: $name"
  else
    echo "FAIL: $name"; fail=1
  fi
done
[[ $fail -eq 0 ]] && echo "preset-smoke passed" || { echo "preset-smoke failed"; exit 1; }
