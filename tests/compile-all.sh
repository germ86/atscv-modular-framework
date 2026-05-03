#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build"
EXAMPLES_DIR="${ROOT_DIR}/examples"

ENGINE="${ATSCV_ENGINE:-lualatex}"

echo "atscv compile-all"
echo "Root: ${ROOT_DIR}"
echo "Engine: ${ENGINE}"
echo "Examples: ${EXAMPLES_DIR}"
echo "Build: ${BUILD_DIR}"

if ! command -v "${ENGINE}" >/dev/null 2>&1; then
  echo "ERROR: ${ENGINE} not found. Install LuaLaTeX / texlive-luatex." >&2
  exit 1
fi

if [ ! -d "${EXAMPLES_DIR}" ]; then
  echo "ERROR: examples directory not found: ${EXAMPLES_DIR}" >&2
  exit 1
fi

mkdir -p "${BUILD_DIR}"

found=0
failed=0

while IFS= read -r texfile; do
  found=1

  rel="${texfile#${ROOT_DIR}/}"
  base="$(basename "${texfile}" .tex)"
  jobname="${base}"

  echo
  echo "Compiling ${rel}"

  if "${ENGINE}" \
      -interaction=nonstopmode \
      -halt-on-error \
      -file-line-error \
      -output-directory="${BUILD_DIR}" \
      -jobname="${jobname}" \
      "${texfile}"; then
    echo "PASS: ${rel}"
  else
    echo "FAIL: ${rel}"
    failed=1
  fi
done < <(find "${EXAMPLES_DIR}" -type f -name "*.tex" | sort)

if [ "${found}" -eq 0 ]; then
  echo "ERROR: no .tex files found in ${EXAMPLES_DIR}" >&2
  exit 1
fi

if [ "${failed}" -ne 0 ]; then
  echo "compile-all failed" >&2
  exit 1
fi

echo
echo "compile-all passed"
