if(INSTALL_TESTS)
execute_process(COMMAND python -c "from distutils.sysconfig import get_python_lib; print get_python_lib()"
    OUTPUT_VARIABLE PYTHON_PACKAGE_DIR OUTPUT_STRIP_TRAILING_WHITESPACE)

install(DIRECTORY ${AUTOPILOT_DIR}
    DESTINATION ${PYTHON_PACKAGE_DIR}
    )

#add depends
install(DIRECTORY address_book_service_testability
    DESTINATION ${PYTHON_PACKAGE_DIR}
    )
endif(INSTALL_TESTS)
