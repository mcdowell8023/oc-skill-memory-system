#!/bin/bash
set -e
echo "=== OpenClaw Memory System Health Check ==="

PASS=0
FAIL=0

# Check 1: openclaw memory status
echo ""
echo "[1/3] Checking memory status..."
if openclaw memory status 2>&1 | grep -q "ready\|indexed"; then
    echo "  ✅ Memory index is ready"
    ((PASS++))
else
    echo "  ❌ Memory index not ready. Run: openclaw memory index --force"
    ((FAIL++))
fi

# Check 2: Test semantic search
echo ""
echo "[2/3] Testing semantic search..."
RESULT=$(openclaw memory search "test query" 2>&1 || true)
if echo "$RESULT" | grep -q -i "error\|not available\|failed"; then
    echo "  ❌ Semantic search failed: $RESULT"
    ((FAIL++))
else
    echo "  ✅ Semantic search working"
    ((PASS++))
fi

# Check 3: Obsidian CLI (optional)
echo ""
echo "[3/3] Checking Obsidian CLI (optional)..."
if command -v obsidian &>/dev/null; then
    echo "  ✅ Obsidian CLI installed: $(obsidian --version 2>&1 | head -1)"
    ((PASS++))
else
    echo "  ⚠️  Obsidian CLI not installed (optional fallback)"
    echo "     Install with: npm install -g obsidian-cli-official"
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ] && echo "🎉 All checks passed!" || exit 1
