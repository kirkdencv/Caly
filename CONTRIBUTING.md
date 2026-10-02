# Contributing to Caly

## Commit messages

Caly uses the [Conventional Commits](https://www.conventionalcommits.org/)
format so the public history stays readable:

```text
<type>(optional-scope): <short imperative summary>
```

Use a lowercase type, keep the summary concise, do not end it with a period,
and describe one logical change per commit.

| Type | Use it for | Example |
| --- | --- | --- |
| `feat` | A user-visible capability | `feat(today): add swipe-to-delete with undo` |
| `fix` | A defect correction | `fix(api): preserve food text after timeout` |
| `docs` | Documentation only | `docs: refresh local setup instructions` |
| `test` | Adding or correcting tests | `test(today): cover interrupted food typing` |
| `refactor` | Internal restructuring without behavior changes | `refactor(storage): centralize date keys` |
| `style` | Formatting or visual polish without logic changes | `style(login): refine mascot spacing` |
| `perf` | Performance improvements | `perf(history): avoid repeated storage reads` |
| `build` | Dependencies or build configuration | `build: register mascot assets` |
| `ci` | Continuous-integration configuration | `ci: run backend tests on pull requests` |
| `chore` | Repository maintenance | `chore: update ignored local files` |

Breaking changes add `!` after the type or scope and explain the migration in
the commit body:

```text
feat(api)!: require versioned interpretation routes
```

## Commit hygiene

- Commit only working, reviewed changes.
- Run the relevant Flutter and backend tests before committing.
- Never change author or commit dates to simulate development activity.
- Do not split a single logical change merely to increase the commit count.
- Do not commit `.env`, API keys, credentials, signing files, or generated
  build output.
- Prefer a focused follow-up commit over rewriting history that has already
  been merged into the public default branch.

## Pull requests

Use a short Conventional Commit-style title. In the description, include the
problem, the implementation, how it was tested, and any known limitations.
