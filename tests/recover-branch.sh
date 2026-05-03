#!/usr/bin/env bash
set -euo pipefail

echo "== Current git status =="
git status --short --branch

echo

echo "== Fetching origin =="
git fetch origin

current_branch="$(git rev-parse --abbrev-ref HEAD)"
base_branch="fix/stabilize-main-ci"
timestamp_branch="${base_branch}-$(date -u +%Y%m%d-%H%M%S)"

if git show-ref --verify --quiet "refs/heads/${base_branch}"; then
  new_branch="$timestamp_branch"
else
  new_branch="$base_branch"
fi

echo "== Current branch: ${current_branch} =="
echo "== Creating recovery branch: ${new_branch} =="
git checkout -b "$new_branch"

echo "== Staging changes =="
git add -A

commit_message="Stabilize CI and preset smoke tests"
if git diff --cached --quiet; then
  echo "No changes to commit; continuing without commit."
else
  git commit -m "$commit_message"
fi

echo "== Pushing branch to origin =="
git push -u origin "$new_branch"

echo
echo "Recovery branch ready: ${new_branch}"
echo "Open a new PR from ${new_branch} into main"
