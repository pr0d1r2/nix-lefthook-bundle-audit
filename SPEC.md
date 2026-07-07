# SPEC -- nix-lefthook-bundle-audit

## D -- Description

Lefthook-compatible git hook running `bundle exec bundle-audit check --update` on pre-commit/pre-push. Distributed as `lefthook-remote.yml`. Built with Nix, tested with bats on Linux and macOS.

## V -- Invariants

1. `lefthook-remote.yml` defines pre-commit and pre-push commands for bundle-audit.
2. Both hooks run `bundle exec bundle-audit check --update || true`.
3. Pre-commit scopes to `{Gemfile,Gemfile.lock}` via glob.
4. Both hooks have a timeout value.
5. `|| true` ensures hooks never block commits/pushes (advisory-only).
6. All bats tests pass on Linux and macOS.
7. Every implementation file has a 1-to-1 bats unit test.
8. `dev.sh` exports BATS_LIB_PATH; runs `lefthook install` when HOME is set and hooks absent.
9. Nix flake supports aarch64-darwin, x86_64-darwin, x86_64-linux, aarch64-linux.
10. CI: ubuntu-latest always; macos-latest on push/workflow_dispatch only.
11. YAML passes yamllint; EditorConfig enforced.
12. File size limits: 4096 default, 65536 for .lock.
13. Shell: no functions (modularity); no direct execution (noexec).

## I -- Interfaces

### lefthook-remote.yml

| key | pre-commit | pre-push |
|---|---|---|
| glob | {Gemfile,Gemfile.lock} | (none) |
| run | bundle exec bundle-audit check --update \|\| true | same |
| timeout | 60s | 60s |

### flake.nix

devShells.default and devShells.ci via nix-dev-shell-agentic. Shell hook is dev.sh with @BATS_LIB_PATH@ substituted.

### dev.sh

Exports BATS_LIB_PATH. Runs `lefthook install` when HOME is set and .git/hooks/pre-commit absent.

### Environment variables

| variable | purpose |
|---|---|
| BATS_LIB_PATH | path to bats support/assert libraries |
| LEFTHOOK_EXECUTE_PERMISSIONS_ALLOWED | regex for allowed execute-bit paths |

## T -- Tasks

| id | goal |
|---|---|
| T1 | Add .envrc with use flake and watch_file entries |
| T2 | Add shellcheck lefthook for .sh/.bats files |
| T3 | Add statix, deadnix, nixfmt lefthook for .nix files |
| T4 | Add .gitignore for Nix artifacts |
| T5 | Add bats test for lefthook-remote.yml YAML structure |
| T6 | Add bats test verifying flake.nix lists all four systems |
| T7 | Test/document pre-push glob omission |
| T8 | Add markdown linter for .md files |

## B -- Bugs / Known Issues

| id | date | cause | fix |
|---|---|---|---|
| B1 | 2026-07-07 | No .envrc in repo | Pending T1 |
| B2 | 2026-07-07 | || true rationale undocumented | Pending README update |
| B3 | 2026-07-07 | Pre-push missing glob filter | Pending decision |
| B4 | 2026-07-07 | Missing local linter hooks | Pending T2-T3 |
| B5 | 2026-07-07 | PROMPT.md tracked in repo | Meta artifact |
| B6 | 2026-07-07 | Shallow git history | Limits bisect/blame |
| B7 | 2026-07-07 | CI: HOME unset by --ignore-environment; bats test assumed HOME set; SPEC.md had non-ASCII and exceeded size limit | Set HOME in test; trim SPEC.md |
