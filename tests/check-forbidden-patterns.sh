#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "running check-forbidden-patterns"

forbidden='tagpdf|DeclareDocumentMetadata|pdfmanagement-testphase|accsupp|accessibility|multicol|tabular|minipage|parbox|fontawesome|scrlttr2'

if rg -n -i --glob '*.tex' --glob '*.sty' --glob '*.cls' "$forbidden" .; then
  echo "ERROR: forbidden patterns detected" >&2
  exit 1
fi

echo "check-forbidden-patterns passed"
