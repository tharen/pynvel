@echo off

:: Setup the build environment for a MSYS2 base project.

set USERPROFILE=c:\users\tharen
set HOMEDRIVE=c:
set HOMEPATH=\users\tharen
set HOME=%HOMEDRIVE%%HOMEPATH%

cd /d %HOME%

set progsroot=C:\progs
set srcroot=%~dp0

set PATH=%windir%\system32\;%PATH%
::set PATH=%progsroot%\TDM-GCC-64\bin;%PATH%
set PATH=%PATH%;%progsroot%\cmake\bin
set PATH=%PATH%;%progsroot%\TortoiseHg
set PATH=%PATH%;%progsroot%\TortoiseSVN\bin
set PATH=%PATH%;C:\progs\graphviz\bin;C:\progs\doxygen\bin
:: MSYSGit includes sh.exe which conflicts with mingw32-make
::set PATH=%PATH%;%progsroot%\Git\bin
set PATH=%PATH%;%progsroot%\notepad++;%progsroot%\pythonxy\WinMerge-2.12.4.2
set PATH=C:\Python27\DLLs;%PATH%
set PATH=c:\python27;c:\python27\scripts;%PATH%

set PYTHONPATH=%srcroot%\debug
set PATH=%srcroot%\debug;%PATH%

set PROMPT=$p$_$+$g

:: Set PATH values for GCC
call c:\progs\TDM-GCC-64\mingwvars.bat
set MSYSTEM=MINGW32

set CHERE_INVOKING=1
start c:\progs\console2\console.exe ^
		-d %srcroot% ^
		-w "PyNVEL (TDM-GCC-64)" ^
		-r "cmd /C C:\progs\msys64\usr\bin\bash.exe --login -i"
::		-t "MSYS2 Bash" -r "%*"
