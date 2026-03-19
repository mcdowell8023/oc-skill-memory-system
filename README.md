# openclaw-skill-memory-system

> Give your OpenClaw agent persistent memory that actually works.

## What This Solves

OpenClaw agents wake up fresh every session. Without a memory system, they lose all context — past decisions, user preferences, project history — everything. Users end up repeating themselves constantly.

This skill configures a complete memory pipeline: local vector embeddings for semantic search, file-based direct read as a baseline, and Obsidian CLI as a full-text fallback. Combined with a heartbeat diary that writes session logs automatically, your agent never forgets.

## Architecture

The memory system operates on four layers, each progressively more capable:

| Layer | Method | When Used | Speed |
|-------|--------|-----------|-------|
| **Write** | Append to `memory/YYYY-MM-DD.md` | Every session end, important events | Instant |
| **Direct Read** | Read `memory/*.md` files directly | Fallback, or when precision matters | Fast |
| **Semantic Search** | Local embedding via `memory_search` | Default retrieval mode | ~200ms |
| **Full-text Fallback** | Obsidian CLI keyword search | When vector index is unavailable | ~500ms |

The agent automatically degrades through these layers if a higher layer fails, and notifies the user when switching modes.

## Prerequisites

| Requirement | Required | Notes |
|------------|----------|-------|
| **OpenClaw** | ✅ Yes | v1.0+ with `memory` command support |
| **Python 3** | ✅ Yes | For setup scripts |
| **`obsidian-cli-official` skill** | ⚠️ Recommended | Enables full-text fallback search. Install with `openclaw skills install obsidian-cli-official` |
| **Obsidian app** (desktop) | ⚠️ Recommended | Must run in background for CLI search. Enable: Settings → General → Advanced → Command Line Interface = ON |
| **~600MB disk** | ✅ Yes | For EmbeddingGemma model download |
| **~2GB RAM** | ✅ Yes | For embedding inference |

> **Linux / Ubuntu 24.04:** Obsidian requires `--no-sandbox` flag due to Electron sandbox restrictions. The setup script handles this automatically. See `references/obsidian-linux-setup.md` for details.

## Quick Install

Copy the prompt from the [Copy-paste section](#-copy-paste-this-into-openclaw-to-install) below directly into your OpenClaw chat. The agent will handle everything.

## Manual Setup

### 1. Configure Local Embedding

Edit `~/.openclaw/openclaw.json`:

```json
{
  "memorySearch": {
    "provider": "local",
    "model": "hf:ggml-org/embeddinggemma-300m-qat-q8_0-GGUF/embeddinggemma-300m-qat-Q8_0.gguf"
  }
}
```

### 2. Build the Index

```bash
openclaw memory index --force
```

### 3. Verify

```bash
openclaw memory status
# Expected: provider=local, files indexed, Vector: ready
```

### 4. (Optional) Install Obsidian CLI Fallback

```bash
npm install -g obsidian-cli-official
```

Then point it at your workspace vault so the agent can use keyword search when vector search is down.

### 5. Configure Heartbeat Diary

Add the diary writing rule from `references/heartbeat-template.md` to your `HEARTBEAT.md`. This ensures session logs are written automatically every hour.

### 6. Run Self-test

```bash
cd /path/to/openclaw-skill-memory-system
./scripts/self-test.sh
```

All 4 checks should pass.

## Memory Mode Switching

Your agent supports three retrieval modes, switchable by voice command:

| Command | Mode | How It Works |
|---------|------|-------------|
| `记忆模式：语义` | Semantic | Vector similarity search via `memory_search` (default) |
| `记忆模式：全文` | Full-text | Keyword search via Obsidian CLI |
| `记忆模式：直读` | Direct read | Reads `memory/*.md` files directly |

The current mode is persisted in `memory-mode.txt`. The agent announces every switch.

## Known Limitations

- **First index build** downloads the embedding model (~300MB). Subsequent builds are fast.
- **Obsidian CLI fallback** requires Node.js and a configured vault path.
- **Heartbeat diary** adds ~500 tokens/hour of overhead. Adjust frequency in `HEARTBEAT.md` if needed.
- **Vector search quality** depends on the embedding model. The default (EmbeddingGemma 300M) is good for mixed Chinese/English text but not perfect for very short queries.
- **No cross-machine sync** — memory files live locally. Use git or syncthing if you need multi-device access.

## 🤖 Copy-paste this into OpenClaw to install

```
Install the OpenClaw memory system skill. Steps:
1. Configure local embedding: set memorySearch.provider = "local" in openclaw.json with model "hf:ggml-org/embeddinggemma-300m-qat-q8_0-GGUF/embeddinggemma-300m-qat-Q8_0.gguf"
2. Run: openclaw memory index --force
3. Verify: openclaw memory status (should show provider=local, files indexed, Vector: ready)
4. (Optional) Install Obsidian CLI fallback: npm install -g obsidian-cli-official, then configure vault
5. Add heartbeat diary rule to HEARTBEAT.md (use template from references/heartbeat-template.md)
6. Run self-test: scripts/self-test.sh

After setup, you can switch memory retrieval mode by saying:
- "记忆模式：语义" → memory_search (default)
- "记忆模式：全文" → obsidian search
- "记忆模式：直读" → direct file read
```

## License

MIT
