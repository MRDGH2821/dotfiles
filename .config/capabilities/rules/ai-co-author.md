## AI Co-authored-by Trailer (MANDATORY)

Every AI-assisted commit MUST include this trailer:

```txt
Co-authored-by: <Model full Name and version> via <Harness> <noreply@provider-domain>
```

Use the email address for the model provider, not the harness provider.

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

If a provider is missing, search its official documentation or public
repositories for a documented address; never guess from the provider's domain.

Use the full model name and version supplied by the session. If the exact
version is unavailable, use the most specific known name and do not guess.
Use the common harness name. Add one trailer per AI model; never omit it.

Example:

```txt
fix(cspell): resolve configuration issue

Co-authored-by: GPT-4o via Cursor <noreply@openai.com>
```
