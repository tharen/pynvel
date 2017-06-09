
# set(src_root "${CMAKE_CURRENT_LIST_DIR}")

# include_directories(BEFORE ${src_root})

# Read the source file names as a list
file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/_sources.txt" vollib_sources)

if (TARGET_32BIT)
    set(arch_flags "-m32")
else ()
    set(arch_flags "-m64")
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

# CMAKE_BUILD_TYPE = Debug
set(debug_flags "-g3 -mfpmath=sse -msse")
set(CMAKE_Fortran_FLAGS_DEBUG "${debug_flags} -fbacktrace -ffpe-trap=invalid,zero,overflow,underflow")
set(CMAKE_CXX_FLAGS_DEBUG "${debug_flags}")
set(CMAKE_C_FLAGS_DEBUG "${debug_flags}")

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

set(OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/timestamp")
add_custom_command(
        OUTPUT ${OUTPUT}
        COMMAND ${CMAKE_COMMAND} -E touch ${OUTPUT}
        DEPENDS ${DEPS}
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        )
add_custom_target(vollib_timestamp ALL DEPENDS ${OUTPUT})

# # Set the install location for library files
# if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
    # # Assume install location is flat
    # set(dest ".")
# else ()
    # # Assume install location is nested
    # set(dest "lib")
# endif ()

# install(TARGETS ${vollib}_static DESTINATION ${dest})
# install(TARGETS ${vollib} DESTINATION ${dest})
