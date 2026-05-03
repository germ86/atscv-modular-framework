#!/usr/bin/env bash
set -euo pipefail
mkdir -p build
chmod +x tests/*.sh
echo "KEY=VALUE" > .env.example
