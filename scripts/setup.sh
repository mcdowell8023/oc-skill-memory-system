#!/bin/bash
set -e
echo "=== OpenClaw Memory System Setup ==="

CONFIG="$HOME/.openclaw/openclaw.json"

if [ ! -f "$CONFIG" ]; then
    echo "ERROR: $CONFIG not found"
    exit 1
fi

python3 - << 'PYEOF'
import json, os

config_path = os.path.expanduser("~/.openclaw/openclaw.json")
with open(config_path, 'r') as f:
    config = json.load(f)

config['memorySearch'] = {
    "provider": "local",
    "model": "hf:ggml-org/embeddinggemma-300m-qat-q8_0-GGUF/embeddinggemma-300m-qat-Q8_0.gguf"
}

with open(config_path, 'w') as f:
    json.dump(config, f, indent=2, ensure_ascii=False)

print("✅ memorySearch configured")
PYEOF

echo "Building memory index..."
openclaw memory index --force

echo "=== Setup complete! Run scripts/health-check.sh to verify ==="
