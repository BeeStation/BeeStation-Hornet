@echo off
cd /d "%~dp0\..\tgui"
yarn eslint . --fix %*
