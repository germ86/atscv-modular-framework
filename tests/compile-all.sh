#!/usr/bin/env bash
set -euo pipefail

if ! command -v lualatex >/dev/null 2>&1; then
  echo "ERROR: lualatex is required" >&2
  exit 1
fi

mkdir -p tests/.build
for tex in examples/*.tex; do
  echo "[compile-all] compiling ${tex}"
  log_file="tests/.build/$(basename "${tex%.tex}").log"
  lualatex -interaction=nonstopmode -halt-on-error -output-directory=tests/.build "$tex" >"$log_file" 2>&1 || {
    first_match="$(grep -n -m1 "Undefined control sequence\|LaTeX Error\|Fatal error\|Emergency stop" "$log_file" || true)"
    if [[ -n "$first_match" ]]; then
      line_no="${first_match%%:*}"
      start=$(( line_no > 20 ? line_no - 20 : 1 ))
      end=$(( line_no + 20 ))
      echo "[compile-all] first error near line ${line_no} in ${log_file}"
      sed -n "${start},${end}p" "$log_file"
    else
      cat "$log_file"
    fi
    exit 1
  }
done

echo "[compile-all] success"
