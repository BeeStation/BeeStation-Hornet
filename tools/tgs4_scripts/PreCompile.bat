@echo off
cd /D "%~dp0"
set TG_BOOTSTRAP_CACHE=%cd%
IF NOT %1 == "" (
	rem TGS4: we are passed the game directory on the command line
	cd %1
) ELSE IF EXIST "..\Game\B\beestation.dmb" (
	rem TGS3: Game/B/beestation.dmb exists, so build in Game/A
	cd ..\Game\A
) ELSE (
	rem TGS3: Otherwise build in Game/B
	cd ..\Game\B
)
set CBT_BUILD_MODE=TGS
tools\build\build
