cmake_minimum_required (VERSION 2.8.8 FATAL_ERROR)

enable_language(Fortran)
project(VOLLIB Fortran)

set(src_root "C:/workspace/src/nvel/vollib")
include_directories(BEFORE ${src_root})

# Read the source file names as a list
file(STRINGS "${src_root}/../sources.txt" vollib_sources)
# Localize the paths
string(REPLACE "vollib/" "${src_root}/" vollib_sources "${vollib_sources}")

set(arch_flags "-m32")
#set(CMAKE_CXX_FLAGS_DEBUG "${arch_flags} ${CMAKE_CXX_FLAGS_DEBUG} -Wall")
#set(CMAKE_CXX_FLAGS_RELEASE "${arch_flags} ${CMAKE_CXX_FLAGS_RELEASE}")
#set(CMAKE_Fortran_FLAGS_DEBUG "${arch_flags} ${CMAKE_Fortran_FLAGS_DEBUG} -Wall")
#set(CMAKE_Fortran_FLAGS_RELEASE "${arch_flags} ${CMAKE_Fortran_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS "${arch_flags} ${CMAKE_C_FLAGS}")
set(CMAKE_CXX_FLAGS "${arch_flags} ${CMAKE_CXX_FLAGS}")
set(CMAKE_Fortran_FLAGS "${arch_flags} ${CMAKE_Fortran_FLAGS}")
set(CMAKE_SHARED_LINKER_FLAGS "${arch_flags} ${CMAKE_SHARED_LINKER_FLAGS}")

add_library(vollib SHARED ${vollib_sources})
set_target_properties(vollib PROPERTIES
    LINKER_LANGUAGE Fortran
    PREFIX ""
    IMPORT_PREFIX ""
    LINK_FLAGS "-static"
    )

install(TARGETS vollib DESTINATION C:/workspace/pyforestsim/pyforestsim/nvel)