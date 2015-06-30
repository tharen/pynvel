cmake_minimum_required (VERSION 2.8.8 FATAL_ERROR)

project(VOLLIB Fortran)

set(src_root "C:/workspace/src/nvel/vollib")
include_directories(BEFORE ${src_root})

# Read the source file names as a list
file(STRINGS "${src_root}/../sources.txt" vollib_sources)
# Localize the paths
string(REPLACE "vollib/" "${src_root}/" vollib_sources "${vollib_sources}")

add_library(vollib SHARED ${vollib_sources})
set_target_properties(vollib PROPERTIES
    LINKER_LANGUAGE Fortran
    PREFIX ""
    IMPORT_PREFIX ""
    COMPILE_FLAGS "-O -m32"
    LINK_FLAGS "-O -m32 -static"
    )