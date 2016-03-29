find_program(QMLTESTRUNNER qmltestrunner)

file(GLOB TESTS tst_*.qml)
foreach(TEST ${TESTS})
    get_filename_component(NAME ${TEST} NAME_WE)
    add_test(${NAME} ${QMLTESTRUNNER} -import ${CMAKE_SOURCE_DIR} -input ${TEST})
    set_tests_properties(${NAME} PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=minimal")
endforeach(TEST)
