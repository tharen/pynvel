@echo off
:: arg 1: Python version, no dots
:: arg 2: Full path to the target environment
if not exist %~2 (
  echo ERROR: %~2 does not exist.
  exit /b 1
  )
  
echo Generate a MinGW import library for the default python

mkdir %~2\libs
pushd %~2\libs

echo %~2\python%~1.dll
call gendef %~2\python%~1.dll
call dlltool --dllname python%~1.dll --def python%~1.def --output-lib libpython%~1.a
popd