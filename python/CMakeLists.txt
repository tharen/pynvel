find_program(PYTHON "python")
find_package(Python COMPONENTS Interpreter Development)

if(NOT PYTHON)
    message(FATAL_ERROR "Python interpreter is not available.")
endif()

message(STATUS "Python interpreter: ${PYTHON}")
message(STATUS "Python_VERSION: ${Python_VERSION}")
message(STATUS "Python_LIBRARIES: ${Python_LIBRARIES}")
message(STATUS "Python_LIBRARY_DIRS: ${Python_LIBRARY_DIRS}")
message(STATUS "Python_RUNTIME_LIBRARY_DIRS: ${Python_RUNTIME_LIBRARY_DIRS}")

get_filename_component(PYTHON_PFX ${PYTHON} DIRECTORY)

# Configure the __init__.py module file and setup.py build script
set(SETUP_PY_IN "${CMAKE_CURRENT_SOURCE_DIR}/setup.py.in")
set(INIT_PY_IN "${CMAKE_CURRENT_SOURCE_DIR}/pynvel/__init__.py.in")
set(SETUP_PY "${CMAKE_CURRENT_SOURCE_DIR}/setup.py")
set(INIT_PY "${CMAKE_CURRENT_SOURCE_DIR}/pynvel/__init__.py")
set(DEPS "${CMAKE_CURRENT_SOURCE_DIR}/pynvel/__init__.py" ${DEPS})

configure_file(${SETUP_PY_IN} ${SETUP_PY})
configure_file(${INIT_PY_IN} ${INIT_PY})

## BUILD THE STATIC SYSTEM LIBRARIES
# Build the python static libraries
set(py_ver "${Python_VERSION_MAJOR}${Python_VERSION_MIONOR}")
set(GEN_LIBPYTHON "${Python_LIBRARY_DIRS}/libpython${py_ver}.a")
set(python_dll "${PYTHON_PFX}/python${py_ver}.dll") 
add_custom_command(
        OUTPUT ${GEN_LIBPYTHON}
        COMMAND gendef ${python_dll}
        COMMAND dlltool --dllname ${python_dll} --def "python${py_ver}.def" --output-lib "libpython${py_ver}.a"
        WORKING_DIRECTORY "${Python_LIBRARY_DIRS}"
        COMMENT "Build libpython"
        )
add_custom_target(libpython ALL DEPENDS ${GEN_LIBPYTHON})

# Build the vcruntime static libraries
## FIXME: 140 is only valid for recent Python versions, e.g. 3.7+
##        and may not be located in the python folder
message(STATUS "**** ${PYTHON_PFX}")
set(vc_ver "140")
set(GEN_LIBVC "${Python_LIBRARY_DIRS}/libvcruntime${vc_ver}.a")
set(vc_dll "${PYTHON_PFX}/libvcruntime${vc_ver}.dll") 
add_custom_command(
        OUTPUT ${GEN_LIBVC}
        COMMAND gendef ${vc_dll}
        COMMAND dlltool --dllname ${vc_dll} --def "vcruntime${vc_ver}.def" --output-lib "libvcruntime${vc_ver}.a"
        WORKING_DIRECTORY "${Python_LIBRARY_DIRS}"
        COMMENT "Build libvcruntime"
        )
add_custom_target(libvcruntime ALL DEPENDS ${GEN_LIBVC})

## END BUILDING SYSTEM LIBRARIES

## BUILD THE PYTHON EXTENSION
set(OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/build/timestamp")
add_custom_command(
        OUTPUT ${OUTPUT}
        COMMAND ${PYTHON} ${SETUP_PY} build_ext --inplace --force #--static
        COMMAND ${CMAKE_COMMAND} -E touch ${OUTPUT}
        DEPENDS ${DEPS} ${vollib}
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        COMMENT "Build the Python extension."
        )

add_custom_target(target ALL DEPENDS ${OUTPUT})

# Create the wheel and source packages
add_custom_target(wheel
        COMMAND ${PYTHON} ${SETUP_PY} bdist_wheel bdist_msi sdist
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        )

add_custom_target(clean_all
        COMMAND ${PYTHON} ${SETUP_PY} clean --all
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        )
        
# Install the library in the local Python environment
install(CODE 
        "execute_process(COMMAND pip install --no-deps -e . \
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})")

# install(TARGETS ${vollib}_static DESTINATION ${dest})
# install(TARGETS ${vollib} DESTINATION ${dest})

set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/pynvel/_pynvel*.c \
        ;${CMAKE_CURRENT_SOURCE_DIR}/pynvel/_pynvel*.pyd \
        ;${CMAKE_CURRENT_SOURCE_DIR}/pynvel/_pynvel*.so \
        ;${CMAKE_CURRENT_SOURCE_DIR}/pynvel/_pynvel*.html"
        )
        