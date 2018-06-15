find_program(PYTHON "python")

if(NOT PYTHON)
    message(FATAL_ERROR "Python interpreter is not available.")
endif()

message(STATUS "Python interpreter: ${PYTHON}")

# Configure the __init__.py module file and setup.py build script
set(SETUP_PY_IN "${CMAKE_CURRENT_SOURCE_DIR}/setup.py.in")
set(INIT_PY_IN "${CMAKE_CURRENT_SOURCE_DIR}/pynvel/__init__.py.in")
set(SETUP_PY "${CMAKE_CURRENT_SOURCE_DIR}/setup.py")
set(INIT_PY "${CMAKE_CURRENT_SOURCE_DIR}/pynvel/__init__.py")
set(DEPS "${CMAKE_CURRENT_SOURCE_DIR}/pynvel/__init__.py" ${DEPS})

configure_file(${SETUP_PY_IN} ${SETUP_PY})
configure_file(${INIT_PY_IN} ${INIT_PY})

set(OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/build/timestamp")
add_custom_command(
        OUTPUT ${OUTPUT}
        COMMAND ${PYTHON} ${SETUP_PY} build_ext --static --inplace --force
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
        