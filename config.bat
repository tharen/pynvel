@echo off

if not exist ..\CMakeLists.txt (
    echo WARNING: The build folder should be one level below CMakeLists.txt: e.g. mkdir build ^& cd build
    exit /b
    )
    
echo cmake -G "MinGW Makefiles" .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%~dp0\pynvel\pynvel -DTARGET_32BIT=No -DTARGET_NATIVE=Yes
cmake -G "MinGW Makefiles" .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%~dp0\pynvel\pynvel -DTARGET_32BIT=No -DTARGET_NATIVE=Yes

echo.
echo To build: cmake --build . --target install -- -j4
echo.