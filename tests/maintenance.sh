#!/usr/bin/env bash
set -euo pipefail
for s in check-forbidden-patterns font-check module-smoke color-module-smoke style-module-smoke layout-module-smoke language-module-smoke compile-all extract-text ats-validate human-scan-check ctan-check; do bash tests/$s.sh; done
