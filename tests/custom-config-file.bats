#!/usr/bin/env bats
load "helper"

function setup() {
  common_setup
}

@test "run screen with the specified .screenrc configuration file" {
  mkdir -p foo/bar
  echo foo > foo/bar/.screenrc
  run scide foo/bar/.screenrc
  assert_success
  refute_output
  assert_screen_called "$screen_mock" -U -c foo/bar/.screenrc
  assert_screen_config foo/bar/.screenrc foo
}

@test "cannot run screen with a custom .screenrc configuration file if it is not readable" {
  mkdir -p foo/bar
  (umask 777 && touch foo/bar/.screenrc)
  run scide foo/bar/.screenrc
  assert_failure 103
  assert_output "foo/bar/.screenrc is not readable"
  assert_screen_not_called
}

@test "run screen with a .screenrc configuration file in the specified directory" {
  mkdir -p foo/bar
  echo bar > foo/bar/.screenrc
  run scide foo/bar
  assert_success
  refute_output
  assert_screen_called "$screen_mock" -U -c foo/bar/.screenrc
  assert_screen_config foo/bar/.screenrc bar
}

@test "cannot run screen with a custom .screenrc configuration file in the specified directory if that directory is not traversable" {
  mkdir -p foo/bar
  touch foo/bar/.screenrc
  chmod a-x foo/bar
  run scide foo/bar
  assert_failure 103
  assert_output "directory foo/bar is not traversable"
  assert_screen_not_called
}

@test "cannot run screen with a custom .screenrc configuration file in the specified directory if that file does not exist" {
  mkdir -p foo/bar
  run scide foo/bar
  assert_failure 102
  assert_output ".screenrc not found in directory foo/bar"
  assert_screen_not_called
}

@test "cannot run screen with a custom .screenrc configuration file in the specified directory if that file is not readable" {
  mkdir -p foo/bar
  (umask 777 && touch foo/bar/.screenrc)
  run scide foo/bar
  assert_failure 103
  assert_output "foo/bar/.screenrc is not readable"
  assert_screen_not_called
}

@test "cannot run screen with a custom .screenrc configuration file if it is neither a file nor a directory" {
  mkdir -p foo/bar
  python3 -c "import socket as s; sock = s.socket(s.AF_UNIX); sock.bind('$PWD/foo/bar/.screenrc')"
  run scide foo/bar/.screenrc
  assert_failure 104
  assert_output "foo/bar/.screenrc is not a file or directory"
  assert_screen_not_called
}
