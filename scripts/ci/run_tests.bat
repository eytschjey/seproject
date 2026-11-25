@echo off
setlocal enabledelayedexpansion

REM Resolve repository root relative to this script's directory
REM so it can be run directly from scripts\ci\ or any other directory.
set "SCRIPT_DIR=%~dp0"
pushd "%SCRIPT_DIR%..\.." >nul

if "%GODOT_BIN%"=="" (
    set "GODOT_BIN=godot"
)

where "%GODOT_BIN%" >nul 2>&1
if errorlevel 1 (
    if not exist "%GODOT_BIN%" (
        echo ERROR: Godot executable not found at '%GODOT_BIN%'. Set GODOT_BIN=C:\path\to\godot.exe
        popd >nul
        exit /b 1
    )
)

for /f "delims=" %%v in ('"%GODOT_BIN%" --version') do set "GODOT_VER=%%v"
echo Using Godot: !GODOT_VER!

set "FAILED=0"

echo.
echo === Running 18 Headless Test Suites ===
for %%T in (
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
) do (
    echo --^> Running %%~T
    "%GODOT_BIN%" --headless -s %%~T
    if errorlevel 1 (
        echo FAIL: %%~T
        set /a FAILED+=1
    )
)

echo.
echo === Validating 11 Scenes ===
for %%S in (
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
) do (
    echo --^> Validating %%~S
    "%GODOT_BIN%" --headless --validate --quit %%~S
    if errorlevel 1 (
        echo FAIL: %%~S
        set /a FAILED+=1
    )
)

popd >nul
echo.
if !FAILED! GTR 0 (
    echo CI verification FAILED (!FAILED! failure^(s^)^).
    exit /b 1
)

echo All 18 test suites and 11 scene validations PASSED!
exit /b 0
