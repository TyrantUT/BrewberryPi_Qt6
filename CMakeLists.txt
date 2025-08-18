cmake_minimum_required(VERSION 3.19)

project(BrewberryPiApp LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS
            Core
            Gui
            Qml
            Quick
            Widgets
            QuickControls2
            Charts)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(${PROJECT_NAME}
    src/main.cpp
)

qt_add_resources(BrewberryPiApp "configuration"
    PREFIX "/"
    FILES
        qtquickcontrols2.conf
)

# Detect if the target architecture is ARM
if (APPLE)
    message(STATUS "Skipping pigpio files.")
    add_definitions(-DPLATFORM_APPLE)
    set(PIGPIO_LIBRARY "")
    set(TSLIB_LIBRARY "")
else()
    message(STATUS "Adding pigpio related directories and libraries")
    set(PIGPIO_LIBRARY pigpio pthread)
    target_include_directories(${PROJECT_NAME} PRIVATE /sysroot/usr /sysroot/usr/include)
    target_link_directories(${PROJECT_NAME} PRIVATE /sysroot/usr/lib)
    target_compile_options(${PROJECT_NAME} PRIVATE -Wall -Wcomment -Wunused-function)

    # Find tslib
    find_library(TSLIB_LIBRARY NAMES ts)
    find_path(TSLIB_INCLUDE_DIR NAMES tslib.h)
    if (NOT TSLIB_LIBRARY OR NOT TSLIB_INCLUDE_DIR)
        message(FATAL_ERROR "tslib not found. Install libts-dev on the host and target.")
    endif()

    target_include_directories(${PROJECT_NAME} PRIVATE ${TSLIB_INCLUDE_DIR})

endif()

target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Widgets
    Qt6::QuickControls2
    Qt6::Charts
    ${PIGPIO_LIBRARY}
    ${TSLIB_LIBRARY}
)

set(QT_QML_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml)
set(QML_IMPORT_PATH ${QT_QML_OUTPUT_DIRECTORY}
    CACHE STRING "Import paths for Qt Creator's code model"
    FORCE
)
set(QT_QML_GENERATE_QMLLS_INI ON)

include(${CMAKE_CURRENT_SOURCE_DIR}/qmlmodules)


#include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# make IDEs aware of the QML import path
set(QML_IMPORT_PATH ${PROJECT_BINARY_DIR}/qml CACHE PATH
    "Path to the custom QML components defined by the project")

qt_generate_deploy_qml_app_script(
    TARGET BrewberryPiApp
    OUTPUT_SCRIPT deploy_script
    MACOS_BUNDLE_POST_BUILD
    NO_UNSUPPORTED_PLATFORM_ERROR
    DEPLOY_USER_QML_MODULES_ON_UNSUPPORTED_PLATFORM
)
install(SCRIPT ${deploy_script})
