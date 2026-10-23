## AI-Assisted Reviews

When reviewing on behalf of a human, end the review with this footer:

Use `.config/capabilities/rules/ai-co-author.md` for the model, harness, and provider email.

```md
<!-- Include a 3 line dash -->

---

<!-- Use the co-author rule. In Markdown, render the footer as subscript when supported.-->

<sub>Co-authored-by: <Model full Name and version> via <Harness> <noreply@provider-domain></sub>
```
