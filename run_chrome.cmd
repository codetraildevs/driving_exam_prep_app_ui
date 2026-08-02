@echo off
setlocal
REM ============================================================
REM  Dev helper: run the Flutter web app in Chrome.
REM
REM  WHY THIS EXISTS:
REM  If Chrome is already running, Flutter cannot attach its
REM  --remote-debugging-port flag (Chrome just reuses the existing
REM  instance and ignores it), and the run fails with:
REM    "Failed to establish connection with the web debug service"
REM  This script closes Chrome first, then launches the app so the
REM  debug connection always works.
REM
REM  NOTE: It closes ALL your Chrome windows/tabs - save work first!
REM  Extra args are passed through, e.g.:
REM    run_chrome.cmd --web-port=8080
REM ============================================================

REM  Work from the project root no matter where the script is run from.
cd /d "%~dp0"

echo [run-chrome] Closing existing Chrome instances...
taskkill /F /IM chrome.exe /T >nul 2>&1
if %errorlevel% equ 128 (
  echo [run-chrome] No Chrome was running - continuing.
) else (
  echo [run-chrome] Chrome closed.
)
REM  Give Chrome a moment to release the debugging port. 2>&1 keeps
REM  "timeout" from failing when stdin is redirected (e.g. from bash).
timeout /t 1 /nobreak >nul 2>&1

echo [run-chrome] Launching: flutter run -d chrome
call flutter run -d chrome %*

echo.
echo [run-chrome] Flutter exited (code %errorlevel%)
pause
