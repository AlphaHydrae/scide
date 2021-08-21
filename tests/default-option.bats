#!/usr/bin/env bats
load "helper"

function setup() {
  common_setup
}

function teardown() {
  common_teardown
}

function run_with_t_option() {
  run scide -a -t "$1"
}

function run_with_default_option() {
  run scide --auto --default "$1"
}

function run_with_scide_default_env_var() {
  SCIDE_AUTO="true" SCIDE_DEFAULT="$1" run scide
}

function setup() {
  common_setup
}

run_variants="run_with_t_option run_with_default_option run_with_scide_default_env_var"

default_screenrc=$(printf "foo\nbar\n")

@test "run screen with a custom default configuration with the -t|--default option or \$SCIDE_DEFAULT environment variable" {
  for run_func in $run_variants; do
    setup_mocks
    echo "$default_screenrc" > default
    $run_func default
    assert_success
    refute_output
    assert_screen_called_with_tmp_config "$screen_mock" -U > .config-file-path
    config_file="$(cat .config-file-path)"
    assert_screen_config "$config_file" "$default_screenrc"
    refute [ -e "$config_file" ]
    verify
  done
}

@test "cannot run screen with a custom default configuration that is not readable" {
  for run_func in $run_variants; do
    setup_mocks
    mkdir -p foo/bar
    echo "$default_screenrc" > foo/bar/default
    chmod 100 foo/bar
    chmod 200 foo/bar/default
    $run_func foo/bar/default
    assert_failure 103
    assert_output "default configuration file foo/bar/default is not readable"
    assert_screen_not_called
    verify
  done
}
