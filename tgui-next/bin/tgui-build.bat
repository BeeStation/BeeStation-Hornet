@echo off
cd "%~dp0\.."
call yarn install --check-files
call yarn run build
timeout /t 9
