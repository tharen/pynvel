# Hierarchical project as described here
#  https://bloerg.net/2012/11/10/cmake-and-distutils.html

cmake_minimum_required (VERSION 2.8.8 FATAL_ERROR)

enable_language(Fortran C)
project(NVEL Fortran C)

set(PACKAGE_VERSION "0.0.6.dev5")

# Direct all library output to the pynvel folder
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/python/pynvel)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/python/pynvel)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/python/pynvel)

set(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_SOURCE_DIR}/dist)

# Define default configuration variables
option(TARGET_32BIT "Set to yes if target architecture is 32 bit." No)
option(NATIVE_ARCH "Build targeting the host architecture." No)

if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release")
endif ()

message(STATUS "Target native architecture: ${NATIVE_ARCH}")
message(STATUS "Target 32 bit architecture: ${TARGET_32BIT}")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "Install prefix: ${CMAKE_INSTALL_PREFIX}")

if (TARGET_32BIT)
    set(vollib vollib)
else ()
    set(vollib vollib64)
endif ()

add_subdirectory(VolumeLibrary)
add_subdirectory(python)