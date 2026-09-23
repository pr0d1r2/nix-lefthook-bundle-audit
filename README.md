# nix-lefthook-bundle-audit

<!-- hallucinogen:autonomy-disclaimer start -->
> Read [LLM-DISCLAIMER](docs/LLM-DISCLAIMER.md) first. This repository is
> tended by an autonomous loop, and that file says what the loop may do here,
> what it may not, and what to check before trusting anything in this tree.
<!-- hallucinogen:autonomy-disclaimer end -->

[![CI](https://github.com/pr0d1r2/nix-lefthook-bundle-audit/actions/workflows/ci.yml/badge.svg)](https://github.com/pr0d1r2/nix-lefthook-bundle-audit/actions/workflows/ci.yml)

> This code is LLM-generated and validated through an automated integration process using [lefthook](https://github.com/evilmartians/lefthook) git hooks, [bats](https://github.com/bats-core/bats-core) unit tests, and GitHub Actions CI.

Lefthook-compatible [bundler-audit](https://github.com/rubysec/bundler-audit) hook for pre-commit and pre-push.

Runs `bundle exec bundle-audit check --update` on Gemfile changes.

## Usage

Add to your `lefthook.yml`:

```yaml
remotes:
  - git_url: https://github.com/pr0d1r2/nix-lefthook-bundle-audit
    ref: main
    configs:
      - lefthook-remote.yml
```

Requires `bundle` and `bundler-audit` gem in your project's Gemfile.

## Development

```bash
nix develop
bats --recursive tests/unit/
```

## License

MIT
