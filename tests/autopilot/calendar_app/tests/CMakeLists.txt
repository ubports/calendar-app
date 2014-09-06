# make the test files visible on qtcreator
file(GLOB PYTHON_TEST_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
     *.py)

add_custom_target(com_ubuntu_calendar_PYTHONTESTFiles ALL SOURCES ${PYTHON_TEST_FILES})
