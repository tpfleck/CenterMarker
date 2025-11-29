#!/usr/bin/env bash
set -euo pipefail
echo "Running basic checks for CenterMarker addon"

# Show a little diagnostic information to help CI troubleshooting
echo "PWD: $(pwd)"
echo "Listing top-level files:"; ls -1 || true

# Check that the .toc file exists
if [ ! -f "CenterMarker.toc" ]; then
  echo "Warning: CenterMarker.toc not found in repo root"
fi

# If luacheck is installed, run it; otherwise show a message
if command -v luacheck >/dev/null 2>&1; then
  echo "Running luacheck with .luacheckrc..."
  # Run luacheck and fail the script on any warnings/errors so CI blocks on issues
  luacheck . --config .luacheckrc
  rc=$?
  if [ $rc -ne 0 ]; then
    echo "luacheck found issues (exit code $rc). Failing CI."
    exit $rc
  fi
else
  echo "Error: luacheck not installed — failing CI. Install luacheck to enable linting."
  exit 1
fi

echo "Basic checks complete."
