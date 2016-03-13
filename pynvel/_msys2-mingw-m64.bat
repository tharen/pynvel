@echo off
:: Setup the build environment for a MSYS2 base project.

set srcroot=%~dp0

set USERPROFILE=c:\users\tharen
set HOMEDRIVE=c:
set HOMEPATH=\users\tharen
set HOME=%HOMEDRIVE%%HOMEPATH%

set progsroot=C:\progs
set PATH=%windir%\system32\;%PATH%
set PATH=%PATH%;%progsroot%\cmake\bin
:: MSYSGit includes sh.exe which conflicts with mingw32-make
set PATH=%PATH%;%progsroot%\pythonxy\WinMerge-2.12.4.2
set PATH=%PATH%;%progsroot%\notepad++
set PATH=%PATH%;c:\miniconda3\scripts

REM call activate C:\workspace\pyforestsim\pyforestsim\pynvel\conda_py34_x64
set PATH=C:\workspace\pyforestsim\pyforestsim\pynvel\conda_py34_x64;%PATH%

set PROMPT=$p$_$+$g

cd /d %srcroot%

:: Set PATH values for GCC
::call c:\progs\TDM-GCC-64\mingwvars.bat
set MSYSTEM=MINGW64

set CHERE_INVOKING=1
start c:\progs\console2\console.exe ^
		-d %srcroot% ^
		-w "PyNVEL (MSY2+MinGW-w64 %MSYSTEM%)" ^
		-r "cmd /C C:\progs\msys64\usr\bin\bash.exe --login -i"
::		-t "MSYS2 Bash" -r "%*"
