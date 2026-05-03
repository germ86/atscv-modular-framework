#!/usr/bin/env bash
set -euo pipefail

if ! command -v lualatex >/dev/null 2>&1; then
  echo "ERROR: lualatex is required" >&2
  exit 1
fi

mkdir -p tests/.build
for tex in examples/*.tex; do
  echo "[compile-all] compiling ${tex}"
  lualatex -interaction=nonstopmode -halt-on-error -output-directory=tests/.build "$tex" >/tmp/atscv-compile.log 2>&1 || {
    cat /tmp/atscv-compile.log
    exit 1
  }
done

echo "[compile-all] success"
