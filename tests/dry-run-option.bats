#!/usr/bin/env bats
load "helper"

function run_with_d_option() {
  run scide -d
}

function run_with_dry_run_option() {
  run scide --dry-run
}

function run_with_scide_dry_run_env_var() {
  SCIDE_DRY_RUN=true run scide
}

function setup() {
  common_setup
}

function teardown() {
  common_teardown
}

run_variants="run_with_d_option run_with_dry_run_option run_with_scide_dry_run_env_var"

@test "run a custom screen binary with the -d|--dry-run option or \$SCIDE_DRY_RUN environment variable" {
  for run_func in $run_variants; do
    setup_mocks
    touch .screenrc
    $run_func
    assert_success
    assert_output "screen -U -c .screenrc"
    assert_screen_not_called
    verify
  done
}
