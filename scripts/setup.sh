#!/bin/bash
set -e
echo "=== OpenClaw Memory System Setup ==="

CONFIG="$HOME/.openclaw/openclaw.json"

if [ ! -f "$CONFIG" ]; then
    echo "ERROR: $CONFIG not found. Is OpenClaw installed?"
    exit 1
fi

# ── Step 1: 配置 local embedding ──────────────────────────────────────────
echo ""
echo "→ Step 1: Configuring local embedding (memorySearch)..."

python3 - << 'PYEOF'
import json, os

config_path = os.path.expanduser("~/.openclaw/openclaw.json")
with open(config_path, 'r') as f:
    config = json.load(f)

# 写到正确位置 agents.defaults.memorySearch
config.setdefault('agents', {}).setdefault('defaults', {})['memorySearch'] = {
    "provider": "local",
    "model": "hf:ggml-org/embeddinggemma-300m-qat-q8_0-GGUF/embeddinggemma-300m-qat-Q8_0.gguf"
}

# 清理旧版顶层 memorySearch（如果存在）
config.pop('memorySearch', None)

with open(config_path, 'w') as f:
    json.dump(config, f, indent=2, ensure_ascii=False)

print("✅ memorySearch configured at agents.defaults.memorySearch")
PYEOF

# ── Step 2: 检测 Obsidian CLI（降级方案） ────────────────────────────────
echo ""
echo "→ Step 2: Checking Obsidian CLI (fallback search)..."

if command -v obsidian &>/dev/null; then
    echo "✅ obsidian CLI found: $(which obsidian)"
    # Ubuntu/Linux 需要 --no-sandbox
    if obsidian --no-sandbox vaults 2>/dev/null | grep -q "vault\|doc\|name"; then
        echo "✅ Obsidian CLI working (--no-sandbox mode)"
    else
        echo "⚠️  obsidian CLI found but may need Obsidian app running in background"
        echo "   Make sure Obsidian is open and CLI toggle is enabled:"
        echo "   Settings → General → Advanced → Command Line Interface = ON"
    fi
else
    echo "⚠️  obsidian CLI not found"
    echo "   Fallback search will NOT be available without it."
    echo "   To install, run in OpenClaw:"
    echo "   openclaw skills install obsidian-cli-official"
    echo ""
    echo "   On Ubuntu 24.04, also apply the --no-sandbox fix:"
    echo "   See references/obsidian-linux-setup.md for details"
fi

# ── Step 3: 创建 memory-mode.txt ─────────────────────────────────────────
echo ""
echo "→ Step 3: Initializing memory-mode.txt..."

WORKSPACE="$HOME/.openclaw/workspace"
MODE_FILE="$WORKSPACE/memory-mode.txt"

if [ ! -f "$MODE_FILE" ]; then
    DATE=$(date +%Y-%m-%dT%H:%M%z)
    cat > "$MODE_FILE" << EOF
mode=语义
last_changed=${DATE}
reason=初始化默认值
changed_by=system
EOF
    echo "✅ memory-mode.txt created (mode=语义)"
else
    echo "✅ memory-mode.txt already exists: $(grep '^mode=' "$MODE_FILE")"
fi

# ── Step 4: 重建索引 ──────────────────────────────────────────────────────
echo ""
echo "→ Step 4: Building memory index..."
openclaw memory index --force 2>&1 | tail -5

echo ""
echo "=== Setup complete! ==="
echo "Run scripts/health-check.sh to verify everything is working."
