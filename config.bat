@echo off

if not exist ..\CMakeLists.txt (
    echo WARNING: The build folder should be one level below CMakeLists.txt: e.g. mkdir build ^& cd build
    exit /b
    )
    
cmake .. -G "MinGW Makefiles" -DNATIVE_ARCH=Yes -DCMAKE_BUILD_TYPE=Release

echo.
echo To build: cmake --build . -- -j4
echo.