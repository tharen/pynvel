cmake_minimum_required (VERSION 2.8.8 FATAL_ERROR)

enable_language(Fortran)
project(VOLLIB Fortran)

set(PACKAGE_VERSION "0.0.4")

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

set(src_root "${CMAKE_CURRENT_LIST_DIR}/vollib")

include_directories(BEFORE ${src_root})

# Read the source file names as a list
file(STRINGS "${src_root}/../sources.txt" vollib_sources)
# Localize the paths
string(REPLACE "vollib/" "${src_root}/" vollib_sources "${vollib_sources}")

# Direct all library output to the pynvel folder
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/pynvel)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/pynvel)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/pynvel)

if (TARGET_32BIT)
    set(arch_flags "-m32")
    set(vollib vollib)
else ()
    set(arch_flags "-m64")
    set(vollib vollib64)
endif ()

if (TARGET_NATIVE)
    message(STATUS "Targeting host native architecture.")
    set(arch_flags "-march=native")
endif ()

set(CMAKE_C_FLAGS "${arch_flags} ${CMAKE_C_FLAGS}")
set(CMAKE_CXX_FLAGS "${arch_flags} ${CMAKE_CXX_FLAGS}")
set(CMAKE_Fortran_FLAGS "${arch_flags} ${CMAKE_Fortran_FLAGS}")
set(CMAKE_SHARED_LINKER_FLAGS "${arch_flags} ${CMAKE_SHARED_LINKER_FLAGS}")

if (NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(CMAKE_C_FLAGS "-fPIC ${CMAKE_C_FLAGS}")
    set(CMAKE_CXX_FLAGS "-fPIC ${CMAKE_CXX_FLAGS}")
    set(CMAKE_Fortran_FLAGS "-fPIC ${CMAKE_Fortran_FLAGS}")
    set(CMAKE_SHARED_LINKER_FLAGS "-fPIC ${CMAKE_SHARED_LINKER_FLAGS}")
endif ()

if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
    # TODO: Add STATIC_LINK option
    set(CMAKE_SHARED_LINKER_FLAGS "-static ${CMAKE_SHARED_LINKER_FLAGS} -s -Wl,--subsystem,windows")
endif ()

# Compile sources into objects
add_library(${vollib}_objs OBJECT ${vollib_sources})

# Create a static library
add_library(${vollib}_static STATIC $<TARGET_OBJECTS:${vollib}_objs>)
set(DEPS ${vollib}_static)

# Link a shared library
add_library(${vollib} SHARED $<TARGET_OBJECTS:${vollib}_objs>)
set_target_properties(${vollib} PROPERTIES
    LINKER_LANGUAGE Fortran
    )
set(DEPS ${DEPS} ${vollib})

# Set the install location for library files
if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
    # Assume install location is flat
    set(dest ".")
else ()
    # Assume install location is nested
    set(dest "lib")
endif ()

find_program(PYTHON "python")

if (PYTHON)
    # Configure the __init__.py module file and setup.py build script
    set(SETUP_PY_IN "${CMAKE_CURRENT_SOURCE_DIR}/setup.py.in")
    set(INIT_PY_IN "${CMAKE_CURRENT_SOURCE_DIR}/pynvel/__init__.py.in")
    set(SETUP_PY "${CMAKE_CURRENT_SOURCE_DIR}/setup.py")
    set(INIT_PY "${CMAKE_CURRENT_SOURCE_DIR}/pynvel/__init__.py")
    set(DEPS "${CMAKE_CURRENT_SOURCE_DIR}/pynvel/__init__.py" ${DEPS})

    configure_file(${SETUP_PY_IN} ${SETUP_PY})
    configure_file(${INIT_PY_IN} ${INIT_PY})

# endif ()

# # if (PYTHON)
# if (0)
    
    set(OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/build/timestamp")

    add_custom_command(
            OUTPUT ${OUTPUT}
            COMMAND ${PYTHON} ${SETUP_PY} build_ext --static --inplace --force
            COMMAND ${CMAKE_COMMAND} -E touch ${OUTPUT}
            DEPENDS ${DEPS}
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
            )

    add_custom_target(target ALL DEPENDS ${OUTPUT})
    
    # Create the wheel and source packages
    add_custom_target(wheel
            COMMAND ${PYTHON} ${SETUP_PY} bdist_wheel bdist_msi sdist
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
            )
    
    # Install the library in the local Python environment
    install(CODE "execute_process(COMMAND pip install --no-deps -e . WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})")

endif()

# install(TARGETS ${vollib}_static DESTINATION ${dest})
# install(TARGETS ${vollib} DESTINATION ${dest})
