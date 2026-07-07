@echo off
cd /d "%~dp0\..\tgui"
bun eslint . --fix %*
