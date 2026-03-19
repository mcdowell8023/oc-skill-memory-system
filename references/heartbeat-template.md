# Heartbeat Diary Template

Add the following section to your `HEARTBEAT.md` to enable automatic session diary writing.

## Configuration

```markdown
## 📓 Diary Auto-Write (Memory System)

**Enabled:** yes
**Frequency:** Every 1 hour (during active heartbeats)
**Token cost:** ~500 tokens per write (append + incremental index)

### Rule

During each heartbeat cycle, if there has been meaningful activity since the last diary entry:

1. **Append** a timestamped entry to `memory/YYYY-MM-DD.md`:
   ```
   ## HH:MM — [Brief summary]
   - Key decisions made
   - Tasks completed or dispatched
   - Important context to remember
   - Any errors or lessons learned
   ```

2. **Incremental index** (if semantic mode is active):
   ```bash
   openclaw memory index
   ```
   (Without `--force`, this only indexes new/changed files.)

3. **Skip** if no meaningful activity occurred — don't write empty entries.

### Toggle

To disable diary writing temporarily, change `Enabled: no` above.
To adjust frequency, change the interval (minimum recommended: 30 minutes).
```

## Notes

- The diary write happens **inside** the heartbeat handler, not as a separate cron job
- Token cost is low because entries are short and incremental indexing is fast
- If `memory_search` is unavailable, skip the index step (diary files are still readable via direct read mode)
