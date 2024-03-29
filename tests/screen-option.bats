#!/usr/bin/env bats
load "helper"

function run_with_s_option() {
  run scide -s "$1"
}

function run_with_screen_option() {
  run scide --screen "$1"
}

function run_with_scide_screen_env_var() {
  SCIDE_SCREEN="$1" run scide
}

function setup() {
  common_setup
}

function teardown() {
  common_teardown
}

run_variants="run_with_s_option run_with_screen_option run_with_scide_screen_env_var"

@test "run screen with custom options with the -s|--screen option or \$SCIDE_SCREEN environment variable" {
  for run_func in $run_variants; do
    setup_mocks
    echo foo > .screenrc
    $run_func "-a -b"
    assert_success
    refute_output
    assert_screen_called "$screen_mock" -a -b -c .screenrc
    assert_screen_config .screenrc foo
    verify
  done
}
