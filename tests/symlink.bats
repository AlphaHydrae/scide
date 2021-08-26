#!/usr/bin/env bats
load "helper"

function setup() {
  common_setup
}

function teardown() {
  common_teardown
}

@test "run screen with a symlink to a .screenrc configuration file" {
  echo "foo" > bar
  ln -s bar .screenrc
  run scide
  assert_success
  refute_output
  assert_screen_called "$screen_mock" -U -c .screenrc
  assert_screen_config .screenrc foo
}
