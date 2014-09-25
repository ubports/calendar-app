if(NOT BZR_REVNO)
    set(BZR_REVNO "latest")
endif(NOT BZR_REVNO)
configure_file(manifest.json.in ${CMAKE_CURRENT_BINARY_DIR}/manifest.json)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/manifest.json calendar.apparmor
        DESTINATION ${CMAKE_INSTALL_PREFIX})

# make the click files visible in qtcreator
file(GLOB CLICK_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
     *.json *.json.in *.apparmor)

add_custom_target(com_ubuntu_calendar_CLICKFiles ALL SOURCES ${CLICK_FILES})
