#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_ROOT="${ROOT_DIR}/build/preset-smoke"
ENGINE="${ATSCV_ENGINE:-lualatex}"

mkdir -p "$BUILD_ROOT"

command -v "$ENGINE" >/dev/null 2>&1 || { echo "ERROR: $ENGINE not found"; exit 1; }
command -v pdftotext >/dev/null 2>&1 || { echo "ERROR: pdftotext not found"; exit 1; }

shopt -s nullglob
files=("${ROOT_DIR}"/examples/preset-*.tex)
((${#files[@]})) || { echo "ERROR: no preset examples found"; exit 1; }

failed=0
for tex in "${files[@]}"; do
  name="$(basename "$tex" .tex)"
  out_dir="$BUILD_ROOT/$name"
  log_file="$out_dir/$name.log"
  mkdir -p "$out_dir"

  echo "Compiling $name"
  preset_failed=0

  if ! "$ENGINE" \
    -interaction=nonstopmode \
    -halt-on-error \
    -file-line-error \
    -output-directory="$out_dir" \
    "$tex" >"$log_file" 2>&1; then
    echo "FAIL: $name"
    echo "Log: $log_file"
    if [[ -f "$log_file" ]]; then
      echo "--- Last 50 log lines ($name) ---"
      tail -n 50 "$log_file"
      echo "--- First error block ($name) ---"
      awk '''/Undefined control sequence|LaTeX Error|Package .* Error|Emergency stop|Fatal error/{print; for(i=0;i<8;i++){if(getline>0) print}; exit}''' "$log_file" || true
      echo "--- Extracted LaTeX errors ($name) ---"
      grep -E "Undefined control sequence|LaTeX Error|Package .* Error|Emergency stop|Fatal error" "$log_file" || true
    fi
    failed=1
    continue
  fi

  pdf="$out_dir/$name.pdf"
  txt="$out_dir/$name.txt"
  if ! pdftotext "$pdf" "$txt"; then
    echo "FAIL: $name"
    echo "Reason: pdftotext failed for $pdf"
    failed=1
    continue
  fi

  grep -q "ATSCV PRESET loaded" "$log_file" || preset_failed=1
  grep -q "ATSCV CONFIG preset=" "$log_file" || preset_failed=1
  grep -q "ATSCV CONFIG color=" "$log_file" || preset_failed=1
  grep -q "ATSCV CONFIG style=" "$log_file" || preset_failed=1
  grep -q "ATSCV CONFIG language=" "$log_file" || preset_failed=1

  if [[ "$name" == *-de ]]; then
    grep -q "Zusammenfassung" "$txt" || preset_failed=1
    grep -q "Berufserfahrung" "$txt" || preset_failed=1
  else
    grep -q "Summary" "$txt" || preset_failed=1
    grep -q "Professional Experience" "$txt" || preset_failed=1
  fi

  if [[ $preset_failed -eq 0 ]]; then
    echo "PASS: $name"
  else
    echo "FAIL: $name"
    echo "Log: $log_file"
    echo "Reason: marker/text assertions failed"
    failed=1
  fi
done

if [[ $failed -eq 0 ]]; then
  echo "preset-smoke passed"
else
  echo "preset-smoke failed"
  exit 1
fi
