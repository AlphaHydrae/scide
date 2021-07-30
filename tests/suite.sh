#!/usr/bin/env bats

function setup() {
  echo -n "" > "$SCREEN_MOCK_DATA_FILE"
}

function screen_mock_executions() {
  cat "$SCREEN_MOCK_DATA_FILE"
}

@test "it works" {
  run scide
  [ "$status" -eq 0 ]
  [ "$(screen_mock_executions)" = "screen .screenrc" ]
}
