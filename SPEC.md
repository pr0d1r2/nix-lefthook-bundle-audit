# SPEC — nix-lefthook-bundle-audit

## §D — Description

A lefthook-compatible git hook that runs `bundle exec bundle-audit check --update` on pre-commit and pre-push to surface known Ruby gem vulnerabilities early in the development workflow. Distributed as a lefthook remote config (`lefthook-remote.yml`) so any project using lefthook can add it with a single YAML block. Built with Nix for reproducible development environments and tested with bats on both Linux and macOS. Target users are Ruby developers who use Nix and lefthook and want automated bundler-audit checks wired into their git hooks.

## §V — Invariants

1. `lefthook-remote.yml` must define both `pre-commit` and `pre-push` commands for `bundle-audit`.
2. Both hooks must run `bundle exec bundle-audit check --update || true`.
3. The pre-commit hook must scope to `{Gemfile,Gemfile.lock}` via `glob`.
4. Both hooks must have a `timeout` value.
5. The `|| true` suffix must ensure the hook never blocks a commit or push (advisory-only).
6. All bats tests must pass on Linux and macOS (`tests/unit/`).
7. Every implementation file must have a 1-to-1 bats unit test.
8. `dev.sh` must export `BATS_LIB_PATH` and conditionally run `lefthook install` when `.git/hooks/pre-commit` is absent.
9. The Nix flake must support four systems: `aarch64-darwin`, `x86_64-darwin`, `x86_64-linux`, `aarch64-linux`.
10. CI runs on `ubuntu-latest` for all events; `macos-latest` on push and workflow_dispatch only.
11. YAML files must pass yamllint (document-start disabled, max line length 120).
12. EditorConfig enforced: LF endings, final newline, no trailing whitespace, UTF-8, 2-space indent.
13. File size limits enforced: 4096 bytes default; 65536 for `.lock` files.
14. Shell scripts must not contain functions; logic must be in separate scripts (modularity rule).
15. Shell scripts must never be called directly (`./script.sh`); always prepend `bash` (noexec rule).

## §I — Interfaces

### Public config — `lefthook-remote.yml`

Consumed by downstream projects via lefthook remotes:

```yaml
remotes:
  - git_url: https://github.com/pr0d1r2/nix-lefthook-bundle-audit
    ref: main
    configs:
      - lefthook-remote.yml
```

Defines:

| key | pre-commit | pre-push |
|---|---|---|
| `glob` | `{Gemfile,Gemfile.lock}` | (none) |
| `run` | `bundle exec bundle-audit check --update \|\| true` | same |
| `timeout` | `60s` | `60s` |

### Dev shell — `flake.nix`

Provides `devShells.default` and `devShells.ci` via `nix-dev-shell-agentic`. Includes `lefthook-bats-unit` and `lefthook-commit-msg-lint` wrapper scripts. Shell hook is `dev.sh` with `@BATS_LIB_PATH@` placeholder substituted at eval time.

### Shell hook — `dev.sh`

```
export BATS_LIB_PATH="@BATS_LIB_PATH@/share/bats"
[ -f .git/hooks/pre-commit ] || lefthook install
```

### Environment variables

| variable | scope | purpose |
|---|---|---|
| `BATS_LIB_PATH` | dev shell | path to bats support/assert libraries |
| `LEFTHOOK_EXECUTE_PERMISSIONS_ALLOWED` | lefthook | regex for paths allowed to have execute bits |
| `STUB_LOG` | tests only | path where stubs log calls |
| `STUB_EXIT` | tests only | exit code returned by stubs |

### Config files

| file | format | purpose |
|---|---|---|
| `config/lefthook/file_size_limits.yml` | YAML | per-extension file size limits for lefthook check |
| `.yamllint` | YAML | yamllint configuration |
| `.editorconfig` | INI | editor style rules |

## §T — Tasks

| status | id | goal |
|---|---|---|
| `.` | T1 | Add `.envrc` file with `use flake` and `watch_file` entries per direnv skill |
| `.` | T2 | Add local shellcheck lefthook command for `.sh` and `.bats` files (pre-commit staged, pre-push all) |
| `.` | T3 | Add local statix, deadnix, and nixfmt lefthook commands for `.nix` files |
| `.` | T4 | Add `.gitignore` for common Nix artifacts (`result`, `.direnv/`) |
| `.` | T5 | Add bats test for `lefthook-remote.yml` validating YAML structure is parseable |
| `.` | T6 | Add bats test verifying `flake.nix` lists all four supported systems |
| `.` | T7 | Test that pre-push intentionally omits `glob` (document the design decision or add glob) |
| `.` | T8 | Add markdown linter to lefthook for `.md` files per linter skill |

## §B — Bugs / Known Issues

1. **No `.envrc` tracked in git.** The direnv skill requires an `.envrc` with `use flake` and `watch_file` entries, but no such file exists in the repository. Developers must manually create one or rely on `nix develop`.
2. **Advisory-only by design, but undocumented.** The `|| true` suffix means real vulnerabilities never block commits or pushes. This is a deliberate trade-off but the README does not explain the rationale or how to override it for stricter enforcement.
3. **Pre-push has no glob restriction.** Pre-commit scopes to `{Gemfile,Gemfile.lock}` changes, but pre-push runs unconditionally. If this is intentional (run full audit on push regardless of changed files), it should be documented; if not, it is a missed filter.
4. **Missing local linter hooks.** The lefthook/nix and lefthook/sh agent skills require shellcheck, statix, deadnix, and nixfmt commands in `lefthook.yml`, but only remote checks are configured. Local `.sh`, `.bats`, and `.nix` files are not linted by local lefthook commands.
5. **`PROMPT.md` tracked in repo.** This file contains the spec-generation prompt, which is a build/meta artifact rather than project documentation. It may confuse contributors.
6. **Shallow git history.** The repository was cloned with `--depth`, so `git log` shows only the latest merge commit. This limits local bisect and blame capabilities.
