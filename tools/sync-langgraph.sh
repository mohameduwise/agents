#!/usr/bin/env bash
# Clone or update a read-only reference copy of langchain-ai/langgraph.
#
# Default location: <parent of this repo>/langchain-ai/langgraph
#   e.g. ~/code/agents  ->  ~/code/langchain-ai/langgraph
# Override with:  LANGGRAPH_REF=/some/path tools/sync-langgraph.sh
#
# Shallow (depth 1) to stay small (~20 MB). Safe to run repeatedly.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dest="${LANGGRAPH_REF:-$(dirname "$repo_root")/langchain-ai/langgraph}"
url="https://github.com/langchain-ai/langgraph"

if [ -d "$dest/.git" ]; then
  git -C "$dest" fetch --depth 1 --quiet origin main
  git -C "$dest" reset --hard --quiet FETCH_HEAD
else
  mkdir -p "$(dirname "$dest")"
  GIT_LFS_SKIP_SMUDGE=1 git clone --depth 1 --quiet "$url" "$dest"
fi

version="$(grep -m1 '^version' "$dest/libs/langgraph/pyproject.toml" | cut -d'"' -f2)"
echo "langgraph reference: $dest"
echo "commit: $(git -C "$dest" log -1 --format='%h %cs %s')"
echo "langgraph version: $version"
