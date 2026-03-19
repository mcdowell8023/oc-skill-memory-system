#!/bin/bash
# Alias for self-test.sh — run from tests/ directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec "$SCRIPT_DIR/../scripts/self-test.sh" "$@"
