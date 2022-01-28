@echo off
call "%~dp0\..\tools\build\build.bat" --wait-on-error lint %*
call "%~dp0\..\tools\build\build.bat" --wait-on-error tgui-test %*
call "%~dp0\..\tools\build\build.bat" --wait-on-error dm-test -DCITESTING -DALL_MAPS %*
