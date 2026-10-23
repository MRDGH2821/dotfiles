## AI Co-authored-by Trailer (MANDATORY)

> **Every commit made with AI assistance MUST include a `Co-authored-by` trailer. No exceptions.**

**Format:**

```txt
Co-authored-by: <Model full Name and version> via <Harness> <noreply@provider-domain>
```

**Provider attribution addresses:**

Choose the address for the model provider. The harness can come from a different provider.

<!-- smt -->

| Provider                | noreply address          |
| ----------------------- | ------------------------ |
| Anthropic (Claude)      | `noreply@anthropic.com`  |
| Cursor                  | `cursoragent@cursor.com` |
| Google (Gemini)         | `noreply@google.com`     |
| Meta (Llama)            | `noreply@meta.com`       |
| Microsoft (Copilot)     | `noreply@microsoft.com`  |
| Mistral                 | `noreply@mistral.ai`     |
| OpenAI (GPT / o-series) | `noreply@openai.com`     |
| xAI (Grok)              | `noreply@x.ai`           |

If the provider is not listed, search its official documentation or public repositories
for a documented attribution email address. Use that address rather than guessing one
from the provider's domain.

**Examples:**

```txt
feat(pre-commit): add spell checking to commit messages

Co-authored-by: Claude Sonnet 4.6 via opencode <noreply@anthropic.com>
```

```txt
fix(cspell): resolve configuration issue

Co-authored-by: GPT-4o via Cursor <noreply@openai.com>
```

**Rules:**

- Use the **full model name and version** supplied by the current session (e.g. `Claude Sonnet 4.6`, not just `Claude`)
- Use the **harness name** as it is commonly known (e.g. `Codex`, `opencode`, `Cursor`, `Copilot`, `Zed`). The harness is the application or CLI running the model.
- If the exact model version is unavailable, use the most specific known model name (e.g. `Claude Sonnet`). Do not guess a version.
- One trailer per AI model involved
- **Never omit this trailer** when the commit was AI-assisted — this is how git history stays honest
