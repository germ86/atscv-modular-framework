#!/usr/bin/env bash
set -euo pipefail

if ! command -v lualatex >/dev/null 2>&1; then
  echo "ERROR: lualatex not found on PATH. Install TeX Live with lualatex to run compile-all." >&2
  exit 1
fi

shopt -s nullglob
examples=(examples/*.tex)
if [[ ${#examples[@]} -eq 0 ]]; then
  echo "ERROR: no .tex files found in examples/." >&2
  exit 1
fi

build_root="build/compile-all"
mkdir -p "$build_root"

failures=0
for tex_file in "${examples[@]}"; do
  name="$(basename "$tex_file" .tex)"
  out_dir="$build_root/$name"
  mkdir -p "$out_dir"

  echo "[compile-all] Compiling $tex_file"
  if ! lualatex -interaction=nonstopmode -halt-on-error -file-line-error \
    -output-directory="$out_dir" "$tex_file" >/tmp/compile-all-$name.log 2>&1; then
    echo "[compile-all] FAILED: $tex_file" >&2
    sed -n '1,120p' "/tmp/compile-all-$name.log" >&2
    failures=$((failures + 1))
  fi
done

if [[ $failures -gt 0 ]]; then
  echo "[compile-all] $failures file(s) failed to compile." >&2
  exit 1
fi

echo "[compile-all] All example .tex files compiled successfully."
