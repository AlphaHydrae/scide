#!/usr/bin/env bats
load "helper"

function setup() {
  common_setup
}

@test "run screen in UTF-8 mode with the .screenrc configuration file in the current directory" {
  echo "foo" > .screenrc
  run scide
  assert_success
  refute_output
  assert_screen_called "$screen_mock" -U -c .screenrc
  assert_screen_config .screenrc foo
}

@test "cannot run screen without a .screenrc configuration file in the current directory" {
  run scide
  assert_failure 102
  assert_output ".screenrc not found in current directory $PWD"
  assert_screen_not_called
}

@test "cannot run screen if the .screenrc configuration file in the current directory is not readable" {
  (umask 777 && touch .screenrc)
  run scide
  assert_failure 103
  assert_output ".screenrc in $PWD is not readable"
  assert_screen_not_called
}
