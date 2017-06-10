@echo off

if not exist ..\CMakeLists.txt (
    echo WARNING: The build folder should be one level below CMakeLists.txt: e.g. mkdir build ^& cd build
    exit /b
    )
    
REM echo cmake -G "MinGW Makefiles" .. -DCMAKE_INSTALL_PREFIX=%~dp0\pynvel\pynvel -DNATIVE_ARCH=Yes
REM cmake -G "MinGW Makefiles" .. -DCMAKE_INSTALL_PREFIX=%~dp0\pynvel\pynvel -DNATIVE_ARCH=Yes

REM echo.
REM echo To build: cmake --build . --target install -- -j4
REM echo.

echo cmake -G "MinGW Makefiles" .. -DNATIVE_ARCH=Yes
cmake -G "MinGW Makefiles" .. -DNATIVE_ARCH=Yes -DCMAKE_BUILD_TYPE=Release

echo.
echo To build: cmake --build . -- -j4
echo.