## Commit policy

### Branch naming strategy

Before creating a branch, follow the branch naming strategy in the project-root
`CONTRIBUTING.md` (`#branch-naming-strategy`).

Before creating a pull or merge request, check whether the branch has an open
request and whether its name follows the branch-naming strategy.

- If an open request already exists, leave the branch name unchanged and notify
  the user if it does not comply.
- Treat common names such as `main`, `master`, and release branches as
  protected. Leave protected branches unchanged and ask the user how to proceed.
- For other branches, check remote protection. If protection cannot be
  determined, ask the user rather than assume the branch is unprotected.
- For an unprotected, non-compliant branch without an open request, propose a
  compliant name and wait for approval. If declined, stop unless the user
  explicitly authorizes an exception.
- For a pushed branch, explain that a native remote rename removes the old
  remote name and ask for approval before using it. After approval, use a native
  rename when available and update the local branch and upstream.
- If native remote rename is unavailable, propose pushing the new name while
  retaining the old remote branch. Obtain separate approval before deleting the
  old remote branch.

### Commit Messages

Every commit MUST be atomic (one logical change), and every commit message MUST use Conventional Commits format: `<type>(<scope>): <description>`.
Consult `cog.toml` for valid scopes and release hooks; it is the source of truth.

Version bumps use cocogitto (`cog bump`). Inspect the configured hooks before
running a release command.
