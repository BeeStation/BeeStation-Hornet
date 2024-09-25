@echo off
:: Nuke this task once the Del the World unit test passes. This exists to fix those errors easily.

call "%~dp0\..\tools\build\build.bat" --wait-on-error dm-test -DREFERENCE_TRACKING_FAST %*
