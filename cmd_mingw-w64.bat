
setlocal

set proj_root=%~dp0

set PATH=C:\progs\mingw-w64\x86_64-6.2.0-release-win32-seh-rt_v5-rev1\mingw64\bin
REM set PATH=C:\progs\mingw-w64\x86_64-5.3.0-win32-seh-rt_v4-rev0\mingw64\bin
REM set PATH=C:\progs\mingw-w64\x86_64-5.3.0-posix-seh-rt_v4-rev0\mingw64\bin
REM set PATH=C:\progs\mingw-w64\x86_64-5.1.0-win32-seh-rt_v4-rev0\mingw64\bin

set PATH=%PATH%;C:\Windows\System32;C:\Windows
set PATH=C:\progs\cmake\bin;%PATH%
REM set PATH=C:\Ruby22-x64\bin;%PATH%
REM set PATH=C:\progs\Git\bin;C:\progs\Git\usr\bin;%PATH%
set path=%path%;C:\Miniconda3;C:\Miniconda3\Scripts

start c:\progs\ConEmu\ConEmu64.exe
