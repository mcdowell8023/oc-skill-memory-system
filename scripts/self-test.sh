#!/bin/bash
set -e
echo "=== OpenClaw Memory System Self-Test ==="
echo ""

PASS=0
FAIL=0
TOTAL=4

# Test 1: Config file has memorySearch
echo "[1/$TOTAL] Checking openclaw.json memorySearch config..."
CONFIG="$HOME/.openclaw/openclaw.json"
if [ -f "$CONFIG" ] && python3 -c "
import json
with open('$CONFIG') as f:
    c = json.load(f)
assert c.get('memorySearch', {}).get('provider') == 'local', 'provider not local'
print('provider=local, model=' + c['memorySearch'].get('model', 'N/A'))
" 2>&1; then
    echo "  ✅ Config correct"
    ((PASS++))
else
    echo "  ❌ memorySearch not configured. Run scripts/setup.sh"
    ((FAIL++))
fi

# Test 2: Memory index exists and is queryable
echo ""
echo "[2/$TOTAL] Checking memory index..."
if openclaw memory status 2>&1 | grep -qi "ready\|indexed\|vector"; then
    echo "  ✅ Index ready"
    ((PASS++))
else
    echo "  ❌ Index not ready. Run: openclaw memory index --force"
    ((FAIL++))
fi

# Test 3: memory-mode.txt exists or can be created
echo ""
echo "[3/$TOTAL] Checking memory-mode.txt..."
MODE_FILE="$HOME/.openclaw/workspace/memory-mode.txt"
if [ -f "$MODE_FILE" ]; then
    echo "  ✅ memory-mode.txt exists: $(head -1 "$MODE_FILE")"
    ((PASS++))
else
    echo "  ⚠️  memory-mode.txt not found, creating default..."
    cat > "$MODE_FILE" << 'EOF'
mode=语义
last_changed=$(date +%Y-%m-%dT%H:%M+08:00)
reason=self-test 初始化
changed_by=system
EOF
    echo "  ✅ Created with default mode=语义"
    ((PASS++))
fi

# Test 4: memory/ directory exists with at least one file
echo ""
echo "[4/$TOTAL] Checking memory directory..."
MEM_DIR="$HOME/.openclaw/workspace/memory"
if [ -d "$MEM_DIR" ] && [ "$(ls -A "$MEM_DIR" 2>/dev/null | head -1)" ]; then
    COUNT=$(ls "$MEM_DIR"/*.md 2>/dev/null | wc -l)
    echo "  ✅ memory/ exists with $COUNT .md files"
    ((PASS++))
else
    echo "  ❌ memory/ directory empty or missing"
    ((FAIL++))
fi

echo ""
echo "==========================================="
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
echo "==========================================="
[ "$FAIL" -eq 0 ] && echo "🎉 All self-tests passed!" || echo "⚠️  Some tests failed. See above for details."
exit $FAIL
