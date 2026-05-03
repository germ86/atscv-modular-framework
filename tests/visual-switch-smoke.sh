#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_ROOT="${ROOT_DIR}/build/visual-switch-smoke"
ENGINE="${ATSCV_ENGINE:-lualatex}"

mkdir -p "$BUILD_ROOT"

command -v "$ENGINE" >/dev/null 2>&1 || { echo "ERROR: $ENGINE not found"; exit 1; }

shopt -s nullglob
files=("${ROOT_DIR}"/examples/visual-switch-*.tex)
((${#files[@]})) || { echo "ERROR: no visual-switch examples found"; exit 1; }

required_patterns=(
  "ATSCV MODULE loaded color=.*"
  "ATSCV MODULE loaded style=.*"
  "ATSCV MODULE loaded layout=.*"
  "ATSCV CONFIG color=.*"
  "ATSCV CONFIG style=.*"
  "ATSCV CONFIG layout=.*"
)

for tex in "${files[@]}"; do
  name="$(basename "$tex" .tex)"
  out_dir="$BUILD_ROOT/$name"
  log_file="$out_dir/$name.log"
  mkdir -p "$out_dir"

  echo "Compiling $name"

  "$ENGINE" \
    -interaction=nonstopmode \
    -halt-on-error \
    -file-line-error \
    -output-directory="$out_dir" \
    "$tex" >"$log_file" 2>&1 || {
      echo "FAIL: $name"
      echo "Log: $log_file"
      echo "--- Last 120 log lines ($name) ---"
      tail -n 120 "$log_file" || true
      exit 1
    }

  for pattern in "${required_patterns[@]}"; do
    if ! grep -Eq "$pattern" "$log_file"; then
      echo "FAIL: $name"
      echo "Missing pattern: $pattern"
      echo "Log: $log_file"
      echo "--- Last 120 log lines ($name) ---"
      tail -n 120 "$log_file" || true
      exit 1
    fi
  done

  echo "PASS: $name"
done

echo "visual-switch-smoke passed"
