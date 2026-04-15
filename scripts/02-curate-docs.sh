#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="/tmp/sync-workspace"

echo "🪚 Pasando la amoladora (Curación)..."
cd "$WORKSPACE"

# 1. Volamos archivos inútiles usando fd con regex case-insensitive
fd -t f -i "^(changelog|license|code_of_conduct|contributing|security).*\.md$" -X rm -f 2>/dev/null || true

# 2. Volamos archivos vacíos (0 bytes)
fd -t f -S -1b -X rm -f 2>/dev/null || true

echo "✅ Curación completada."