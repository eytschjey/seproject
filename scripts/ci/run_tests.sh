#!/usr/bin/env bash
set -euo pipefail

# Always resolve the repository root relative to this script's directory
# so it can be executed directly from scripts/ci/ or any other directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

GODOT_BIN="${GODOT_BIN:-godot}"

if ! command -v "$GODOT_BIN" >/dev/null 2>&1 && [ ! -x "$GODOT_BIN" ]; then
  echo "ERROR: Godot executable not found at '$GODOT_BIN'. Set GODOT_BIN=/path/to/godot." >&2
  exit 1
fi

echo "Using Godot: $("$GODOT_BIN" --version)"

TESTS=(
  "res://tests/TestRiverCrossing.gd"
  "res://tests/TestNinePortals.gd"
  "res://tests/TestQueens.gd"
  "res://tests/TestKnightsTour.gd"
  "res://tests/TestDreadbury.gd"
  "res://tests/TestMidnightBridge.gd"
  "res://tests/TestProgressStore.gd"
  "res://tests/TestJournal.gd"
  "res://tests/TestPlayerController.gd"
  "res://tests/TestMainMenu.gd"
  "res://tests/TestLevel01Scene.gd"
  "res://tests/TestLevel01Transition.gd"
  "res://tests/TestLevel02Scene.gd"
  "res://tests/TestLevel03Scene.gd"
  "res://tests/TestLevel04Scene.gd"
  "res://tests/TestLevel05Scene.gd"
  "res://tests/TestLevel06Scene.gd"
  "res://tests/TestLevel07Scene.gd"
)

SCENES=(
  "scenes/ui/MainMenu.tscn"
  "scenes/ui/Journal.tscn"
  "scenes/player/Player.tscn"
  "scenes/props/Cat.tscn"
  "scenes/levels/Level01_Tutorial.tscn"
  "scenes/levels/Level02_NinePortals.tscn"
  "scenes/levels/Level03_SunCourtyard.tscn"
  "scenes/levels/Level04_KnightsChasm.tscn"
  "scenes/levels/Level05_DreadburyManor.tscn"
  "scenes/levels/Level06_Cat.tscn"
  "scenes/levels/Level07_MidnightBridge.tscn"
)

failed=0

echo ""
echo "=== Running ${#TESTS[@]} Headless Test Suites ==="
for test_script in "${TESTS[@]}"; do
  echo "--> Running $test_script"
  if ! "$GODOT_BIN" --headless -s "$test_script"; then
    echo "FAIL: $test_script" >&2
    failed=$((failed + 1))
  fi
done

echo ""
echo "=== Validating ${#SCENES[@]} Scenes ==="
for scene_path in "${SCENES[@]}"; do
  echo "--> Validating $scene_path"
  if ! "$GODOT_BIN" --headless --validate --quit "$scene_path"; then
    echo "FAIL: $scene_path" >&2
    failed=$((failed + 1))
  fi
done

echo ""
if [ "$failed" -gt 0 ]; then
  echo "CI verification FAILED ($failed failure(s))." >&2
  exit 1
fi

echo "All ${#TESTS[@]} test suites and ${#SCENES[@]} scene validations PASSED!"
