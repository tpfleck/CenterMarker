#!/usr/bin/env bash
set -euo pipefail
echo "Running basic checks for CenterMarker addon"

# Check that the .toc file exists
if [ ! -f "CenterMarker.toc" ]; then
  echo "Warning: CenterMarker.toc not found in repo root"
fi

# If luacheck is installed, run it; otherwise show a message
if command -v luacheck >/dev/null 2>&1; then
  echo "Running luacheck..."
  luacheck . || true
else
  echo "luacheck not installed — skipping Lua linting (install luacheck to enable)."
fi

echo "Basic checks complete." 
