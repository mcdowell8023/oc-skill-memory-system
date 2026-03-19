# Daily Diary Format

Each day's memory is stored in `memory/YYYY-MM-DD.md`. Follow this format for consistency.

## Template

```markdown
# YYYY-MM-DD — [Day summary in ≤10 words]

## HH:MM — [Activity title]
- What happened
- Decisions made
- Key context

## HH:MM — [Next activity]
- Details...

---
## End of Day Summary
- **Completed:** list of finished tasks
- **Pending:** carry-over items for tomorrow
- **Lessons:** anything worth remembering long-term (→ consider adding to MEMORY.md)
```

## Example

```markdown
# 2026-03-19 — Memory system setup and NAS backup fix

## 09:30 — Session start
- User asked to configure memory system
- Ran setup.sh, index built successfully (247 files, 12s)
- Set memory mode to 语义 (default)

## 11:15 — NAS backup investigation
- Dispatched 移公 to check rsync logs
- Root cause: disk full on /backup (98%)
- Cleaned old snapshots, freed 120GB

## 14:00 — Heartbeat diary configured
- Added diary rule to HEARTBEAT.md
- Frequency: 1 hour
- First auto-write confirmed working

---
## End of Day Summary
- **Completed:** memory system configured, NAS backup fixed
- **Pending:** monitor NAS disk usage over next week
- **Lessons:** always check disk space before assuming rsync failure is network-related
```

## Guidelines

- Use 24-hour time format with timezone implied (configured in workspace)
- Keep entries concise — this is a log, not a novel
- Include decisions and reasoning, not just actions
- End-of-day summary is optional but recommended for long/busy days
- If session ends unexpectedly, write what you can on next startup
