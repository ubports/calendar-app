project(com.ubuntu.calendar)
cmake_minimum_required(VERSION 2.8.9)

find_program(INTLTOOL_MERGE intltool-merge)
if(NOT INTLTOOL_MERGE)
    message(FATAL_ERROR "Could not find intltool-merge, please install the intltool package")
endif()

find_program(INTLTOOL_EXTRACT intltool-extract)
if(NOT INTLTOOL_EXTRACT)
    message(FATAL_ERROR "Could not find intltool-extract, please install the intltool package")
endif()

option(INSTALL_TESTS "Install the tests on make install" on)
option(CLICK_MODE "Installs to a contained location" on)

# Standard install paths
include(GNUInstallDirs)

# Tests
enable_testing()

set(APP_NAME                    calendar)
set(DESKTOP_FILE                "${PROJECT_NAME}_${APP_NAME}.desktop")
set(APPLICATION_FILE            "${PROJECT_NAME}_${APP_NAME}.application")
set(URLS_FILE                   "${PROJECT_NAME}_${APP_NAME}.url-dispatcher")
set(MAIN_QML                    calendar.qml)
set(ICON_FILE                   calendar-app@30.png)
set(SYMBOLIC_ICON_FILE		calendar-app-symbolic.svg)
set(AUTOPILOT_DIR               calendar_app)
set(APP_HARDCODE                calendar-app)
set(UBUNTU_MANIFEST_PATH        "click/manifest.json.in" CACHE INTERNAL "Relative path to the manifest file")

if(CLICK_MODE)
    if(NOT DEFINED BZR_SOURCE)
        set(BZR_SOURCE "lp:ubuntu-${APP_HARDCODE}")
        message("-- Setting BZR_SOURCE to ${BZR_SOURCE}")
    endif(NOT DEFINED BZR_SOURCE)
    set(CMAKE_INSTALL_PREFIX /)
    set(CMAKE_INSTALL_BINDIR /)
    set(DATA_DIR /)
    set(ICON ${ICON_FILE})
    set(SYMBOLIC_ICON ${SYMBOLIC_ICON_FILE})
    set(EXEC "qmlscene %u ${MAIN_QML}")
    set(DESKTOP_DIR ${DATA_DIR})
    set(URLS_DIR ${DATA_DIR})
    set(APPLICATION_DIR ${DATA_DIR})
else(CLICK_MODE)
    set(DATA_DIR ${CMAKE_INSTALL_DATADIR}/${APP_HARDCODE})
    set(EXEC ${APP_HARDCODE})
    set(ICON ${CMAKE_INSTALL_PREFIX}/${DATA_DIR}/${ICON_FILE})
    set(SYMBOLIC_ICON ${CMAKE_INSTALL_PREFIX}/${DATA_DIR}/${SYMBOLIC_ICON_FILE})
    configure_file(${APP_HARDCODE}.in
            ${CMAKE_CURRENT_BINARY_DIR}/${APP_HARDCODE})
    install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/${APP_HARDCODE}
            DESTINATION ${CMAKE_INSTALL_BINDIR})
    set(DESKTOP_DIR ${CMAKE_INSTALL_DATADIR}/applications)
    set(URLS_DIR ${CMAKE_INSTALL_DATADIR}/url-dispatcher/urls)
    set(APPLICATION_DIR ${CMAKE_INSTALL_DATADIR}/accounts/applications)
endif(CLICK_MODE)

file(GLOB_RECURSE I18N_SRC_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/po
     *.qml *.js)
list(APPEND I18N_SRC_FILES ${DESKTOP_FILE}.in.in.h)
list(SORT I18N_SRC_FILES)
message("Found ${I18N_SRC_FILES}")

file(GLOB SRC_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
     *.qml *.js)
add_custom_target(ubuntu-calendar-app_QMlFiles ALL SOURCES ${SRC_FILES})

file(GLOB RESOURCE_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
     *.png *.svg)
install(FILES ${SRC_FILES} ${RESOURCE_FILES} ${ICON_FILE} ${SYMBOLIC_ICON_FILE} DESTINATION ${DATA_DIR})

configure_file(${DESKTOP_FILE}.in.in ${DESKTOP_FILE}.in)

add_custom_target(${DESKTOP_FILE} ALL
  COMMENT "Merging translations into ${DESKTOP_FILE}"
  COMMAND LC_ALL=C ${INTLTOOL_MERGE} -d -u ${CMAKE_SOURCE_DIR}/po ${DESKTOP_FILE}.in ${DESKTOP_FILE} >/dev/null
)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE} DESTINATION ${DESKTOP_DIR})

install(FILES ${URLS_FILE} DESTINATION ${URLS_DIR})

install(FILES ${APPLICATION_FILE} DESTINATION ${APPLICATION_DIR})

install(DIRECTORY "3rd-party" DESTINATION ${DATA_DIR})
install(DIRECTORY "ubuntu-app-platform" DESTINATION ${CMAKE_INSTALL_PREFIX})

add_subdirectory(click)
add_subdirectory(po)
add_subdirectory(tests)
