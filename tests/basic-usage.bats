#!/usr/bin/env bats
load "helper"

function setup() {
  common_setup
}

@test "run screen in UTF-8 mode with the .screenrc configuration file in the current directory" {
  touch .screenrc
  run scide
  assert_success
  assert_screen_called "$screen_mock" -U -c .screenrc
}

@test "cannot run screen without a .screenrc configuration file in the current directory" {
  run scide
  assert_failure 102
  assert_screen_not_called
}
