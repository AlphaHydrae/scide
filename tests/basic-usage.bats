#!/usr/bin/env bats
load "helper"

function setup() {
  common_setup
}

@test "scide runs screen in UTF-8 mode with the .screenrc configuration file in the current directory by default" {
  touch .screenrc
  run scide
  assert_success
  assert_screen_called_with -U .screenrc
}

@test "scide refuses to run screen without a .screenrc configuration file in the current directory by default" {
  run scide
  assert_failure 102
  assert_screen_not_called
}
