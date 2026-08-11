#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"
    REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
}

@test "remote hooks keep the advisory bundle-audit command" {
    run grep -F 'run: bundle exec bundle-audit check --update || true' \
        "$REPO_ROOT/lefthook-remote.yml"
    assert_success
    count=$(grep -Fc 'run: bundle exec bundle-audit check --update || true' "$REPO_ROOT/lefthook-remote.yml")
    [ "$count" -eq 2 ]
}

@test "remote hooks have the documented scope and timeout" {
    run grep -F 'glob: "{Gemfile,Gemfile.lock}"' \
        "$REPO_ROOT/lefthook-remote.yml"
    assert_success
    [ "$(grep -Fc 'timeout: 60s' "$REPO_ROOT/lefthook-remote.yml")" -eq 2 ]
    run awk '/^pre-push:/,/^$/ { if ($1 == "glob:") found=1 } END { exit found }' \
        "$REPO_ROOT/lefthook-remote.yml"
    assert_failure
}
