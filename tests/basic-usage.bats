#!/usr/bin/env bats
load "helper"

function setup() {
  setup_mocks
}

@test "run screen in UTF-8 mode with the .screenrc configuration file in the current directory by default" {
  run scide
  [ "$status" -eq 0 ]
  [ "$(screen_mock_executions)" = "screen -U .screenrc" ]
}
