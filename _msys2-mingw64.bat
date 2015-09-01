@echo off
:: Build envirnonment for NVEL/PyNVEL

set srcroot=C:\workspace\src\nvel

set USERPROFILE=c:\users\tharen
set HOMEDRIVE=c:
set HOMEPATH=\users\tharen
set HOME=%HOMEDRIVE%%HOMEPATH%

set progsroot=C:\progs
set PATH=%PATH%;%progsroot%\cmake\bin
set PATH=%PATH%;%progsroot%\TortoiseHg
set PATH=%PATH%;%progsroot%\TortoiseSVN\bin
set PATH=%PATH%;%progsroot%\pythonxy\WinMerge-2.12.4.2
set PATH=%PATH%;%progsroot%\notepad++
set PATH=%PATH%;C:\progs\graphviz\bin;C:\progs\doxygen\bin
set PATH=%windir%\system32\;%PATH%

set PATH=c:\python27;C:\Python27\DLLs;c:\python27\scripts;%PATH%

:: TODO: Need some fancy way of updating the build type
set PYTHONPATH=%srcroot%\debug
set PATH=%srcroot%\debug;%PATH%

set PROMPT=$p$_$+$g

cd /d %srcroot%

:: Set PATH values for GCC
::call c:\progs\TDM-GCC-64\mingwvars.bat

set MSYSTEM=MINGW32

set CHERE_INVOKING=1
start c:\progs\console2\console.exe ^
		-d %srcroot% ^
		-w "Open-FVS (MSY2+MinGW-w64 %MSYSTEM%)" ^
		-r "cmd /C C:\progs\msys64\usr\bin\bash.exe --login -i"
::		-t "MSYS2 Bash" -r "%*"
