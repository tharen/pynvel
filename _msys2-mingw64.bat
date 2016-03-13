@echo off
:: Build envirnonment for NVEL/PyNVEL

set srcroot=%~dp0

set USERPROFILE=c:\users\tharen
set HOMEDRIVE=c:
set HOMEPATH=\users\tharen
set HOME=%HOMEDRIVE%%HOMEPATH%

set progsroot=C:\progs
set PATH=%PATH%;%progsroot%\cmake\bin
set PATH=%PATH%;%progsroot%\pythonxy\WinMerge-2.12.4.2
set PATH=%PATH%;%progsroot%\notepad++
set PATH=%PATH%;C:\progs\graphviz\bin;C:\progs\doxygen\bin
::set PATH=%windir%\system32\;%PATH%

set PATH=c:\python34;C:\Python34\DLLs;c:\python34\scripts;%PATH%

set PROMPT=$p$_$+$g

cd /d %srcroot%

:: Set PATH values for GCC
::call c:\progs\TDM-GCC-64\mingwvars.bat

set MSYSTEM=MINGW64

set CHERE_INVOKING=1
start c:\progs\console2\console.exe ^
		-d %srcroot% ^
		-w "Open-FVS (MSY2+MinGW-w64 %MSYSTEM%)" ^
		-r "cmd /C C:\progs\msys64\usr\bin\bash.exe --login -i"
::		-t "MSYS2 Bash" -r "%*"
