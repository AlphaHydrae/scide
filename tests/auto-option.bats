#!/usr/bin/env bats
load "helper"

function setup() {
  common_setup
}

function teardown() {
  common_teardown
}

function run_with_a_option() {
  run scide -a
}

function run_with_auto_option() {
  run scide --auto
}

function run_with_scide_auto_env_var() {
  SCIDE_AUTO="true" run scide
}

function setup() {
  common_setup
}

run_variants="run_with_a_option run_with_auto_option run_with_scide_auto_env_var"

default_screenrc=$(cat <<-EOF
source \$HOME/.screenrc
screen -t editor 0
stuff "\$EDITOR\\012"
screen -t shell 1
select editor
EOF
)

@test "run screen with an automatically generated configuration with the -a|--auto option or \$SCIDE_AUTO environment variable" {
  for run_func in $run_variants; do
    setup_mocks
    $run_func
    assert_success
    refute_output
    assert_screen_called_with_tmp_config "$screen_mock" -U > .config-file-path
    config_file="$(cat .config-file-path)"
    assert_screen_config "$config_file" "$default_screenrc"
    refute [ -e "$config_file" ]
    verify
  done
}

@test "run screen with an automatically generated configuration based on ~/.config/scide/.screenrc" {
  custom_default_screenrc="$(printf "foo\nbar\n")"
  for run_func in $run_variants; do
    setup_mocks
    mkdir -p .config/scide
    echo -n "$custom_default_screenrc" > .config/scide/.screenrc
    HOME="$PWD" $run_func
    assert_success
    refute_output
    assert_screen_called_with_tmp_config "$screen_mock" -U > .config-file-path
    config_file="$(cat .config-file-path)"
    assert_screen_config "$config_file" "$custom_default_screenrc"
    refute [ -e "$config_file" ]
    verify
  done
}

@test "scide uses the .screenrc configuration file in the current directory instead of generating one with the -a|--auto option or \$SCIDE_AUTO environment variable" {
  for run_func in $run_variants; do
    setup_mocks
    echo foo > .screenrc
    $run_func
    assert_success
    refute_output
    assert_screen_called "$screen_mock" -U -c .screenrc
    assert_screen_config .screenrc foo
    verify
  done
}

@test "cannot run screen with an automatically generated configuration if ~/.config/scide/.screenrc is not readable" {
  for run_func in $run_variants; do
    setup_mocks
    mkdir -p .config/scide
    echo -n "$custom_default_screenrc" > .config/scide/.screenrc
    chmod 100 .config/scide
    chmod 200 .config/scide/.screenrc
    HOME="$PWD" $run_func
    assert_failure 103
    assert_output "default configuration file ${PWD}/.config/scide/.screenrc is not readable"
    assert_screen_not_called
    verify
  done
}
