find_program(QMLTESTRUNNER qmltestrunner)

file(GLOB TESTS tst_*.qml)
foreach(TEST ${TESTS})
    get_filename_component(NAME ${TEST} NAME_WE)
    add_test(${NAME} ${QMLTESTRUNNER} -input ${TEST})
endforeach(TEST)
