#!/usr/bin/env bats
load "helper"

function run_with_b_option() {
  run scide -b "$1"
}

function run_with_bin_option() {
  run scide --bin "$1"
}

function run_with_scide_bin_env_var() {
  SCIDE_BIN="$1" run scide
}

function setup() {
  common_setup
}

run_variants="run_with_b_option run_with_bin_option run_with_scide_bin_env_var"

@test "run a custom screen binary with the -b|--bin option or \$SCIDE_ENV environment variable" {
  for run_func in $run_variants; do
    setup_mocks
    touch .screenrc
    cp "$screen_mock" foo
    $run_func foo
    assert_success
    assert_screen_called "./foo" -U -c .screenrc
  done
}

@test "the screen command in the PATH is preferred rather than a relative script" {
  for run_func in $run_variants; do
    setup_mocks
    touch .screenrc
    cp "$screen_mock" screen
    $run_func screen
    assert_success
    assert_screen_called "$screen_mock" -U -c .screenrc
  done
}

@test "specifying an explicit relative script takes precedence over the screen command in the PATH" {
  for run_func in $run_variants; do
    setup_mocks
    touch .screenrc
    cp "$screen_mock" screen
    $run_func ./screen
    assert_success
    assert_screen_called ./screen -U -c .screenrc
  done
}

@test "cannot run a non-existent screen binary with the -b|--bin option or the \$SCIDE_BIN environment variable" {
  for run_func in $run_variants; do
    setup_mocks
    $run_func foo
    assert_failure 100
    assert_screen_not_called
  done
}

@test "cannot run a non-executable screen binary with the -b|--bin option or the \$SCIDE_BIN environment variable" {
  for run_func in $run_variants; do
    setup_mocks
    touch non_executable_screen
    $run_func non_executable_screen
    assert_failure 101
    assert_screen_not_called
  done
}
