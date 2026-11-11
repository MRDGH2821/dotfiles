## AI-assisted work logs

Record each AI-assisted change in `.agents/logs/YYYY-MM-DD.md`. Use this format, with one entry per request:

```markdown
# Agent logs YYYY-MM-DD

## YYYY-MM-DDTHH:MM:SS+HH:MM

**Prompt:**
<request that initiated the work>

**Prompt author:**
<author name>

**Description:**
<what changed>

**Model & Harness:**
<full model name and version> via <harness>
```

Get timestamps with `date --iso-8601=seconds`. Use `git config get user.name` for the prompt author when available. Append additional entries for that date in timestamp order.
