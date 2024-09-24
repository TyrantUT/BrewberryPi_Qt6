cmake_minimum_required(VERSION 3.21)

project(BrewberryPiApp LANGUAGES CXX)

find_package(Qt6 6.7.2 REQUIRED COMPONENTS Core Gui Qml Quick Widgets QuickControls2 Charts)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)


qt_standard_project_setup(REQUIRES 6.7.2)

qt_add_executable(BrewberryPiApp
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
    set(PIGPIO_LIBRARY "")
else()
    message(STATUS "Adding pigpio related directories and libraries")
    set(PIGPIO_LIBRARY pigpio)
    target_include_directories(BrewberryPiApp PRIVATE /sysroot/usr /sysroot/usr/include)
    target_link_directories(BrewberryPiApp PRIVATE /sysroot/usr/lib)
    target_compile_options(BrewberryPiApp PRIVATE -Wall)
endif()

target_link_libraries(BrewberryPiApp PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Widgets
    Qt6::QuickControls2
    Qt6::Charts
    ${PIGPIO_LIBRARY}
)

set(QT_QML_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml)
set(QML_IMPORT_PATH ${QT_QML_OUTPUT_DIRECTORY}
    CACHE STRING "Import paths for Qt Creator's code model"
    FORCE
)

include(${CMAKE_CURRENT_SOURCE_DIR}/qmlmodules)


#include(GNUInstallDirs)
install(TARGETS BrewberryPiApp
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# make IDEs aware of the QML import path
set(QML_IMPORT_PATH ${PROJECT_BINARY_DIR}/qml CACHE PATH
    "Path to the custom QML components defined by the project")
