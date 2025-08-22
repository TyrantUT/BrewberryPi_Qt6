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
    Charts
    WebSockets
    Network
)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(BrewberryPiApp
    src/main.cpp
    src/websocketmanager.h
    src/websocketmanager.cpp
    resources/resources.qrc
    resources/server.key
    resources/server.crt
)

qt_add_resources(BrewberryPiApp "configuration"
    PREFIX "/"
    FILES
        qtquickcontrols2.conf
)

# Detect if the target architecture is ARM
if(APPLE)
    message(STATUS "Skipping pigpio files.")
    add_definitions(-DPLATFORM_APPLE)
    set(PIGPIO_LIBRARY "")
    set(TSLIB_LIBRARY "")
else()
    message(STATUS "Adding pigpio related directories and libraries")
    set(PIGPIO_LIBRARY pigpio pthread)
    target_include_directories(BrewberryPiApp PRIVATE /sysroot/usr /sysroot/usr/include)
    target_link_directories(BrewberryPiApp PRIVATE /sysroot/usr/lib)
    target_compile_options(BrewberryPiApp PRIVATE -Wall -Wcomment -Wunused-function)

    find_library(TSLIB_LIBRARY NAMES ts HINTS /usr/lib/aarch64-linux-gnu)
    find_path(TSLIB_INCLUDE_DIR NAMES tslib.h HINTS /usr/include)
    if(NOT TSLIB_LIBRARY OR NOT TSLIB_INCLUDE_DIR)
        message(FATAL_ERROR "tslib not found. Install libts-dev on the Raspberry Pi and sync to sysroot.")
    endif()
    target_include_directories(BrewberryPiApp PRIVATE ${TSLIB_INCLUDE_DIR})
endif()

# Add imports/BrewberryPi/ to include directories for BrewberryPiApp
target_include_directories(BrewberryPiApp PRIVATE ${CMAKE_SOURCE_DIR}/imports/BrewberryPi)

# Link Qt libraries and QML modules
target_link_libraries(BrewberryPiApp PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Widgets
    Qt6::QuickControls2
    Qt6::Charts
    Qt6::WebSockets
    Qt6::Network
    ${PIGPIO_LIBRARY}
    ${TSLIB_LIBRARY}
)

set(QT_QML_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml)
set(QML_IMPORT_PATH ${QT_QML_OUTPUT_DIRECTORY}
    CACHE STRING "Import paths for Qt Creator's code model"
    FORCE
)
set(QT_QML_GENERATE_QMLLS_INI ON)

# Include QML module subdirectories
add_subdirectory(content)
add_subdirectory(imports)

# Finalize target to include QML plugins and dependencies
qt_finalize_target(BrewberryPiApp)

install(TARGETS BrewberryPiApp
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Generate deployment script
qt_generate_deploy_qml_app_script(
    TARGET BrewberryPiApp
    OUTPUT_SCRIPT deploy_script
    MACOS_BUNDLE_POST_BUILD
    NO_UNSUPPORTED_PLATFORM_ERROR
    DEPLOY_USER_QML_MODULES_ON_UNSUPPORTED_PLATFORM
)

install(SCRIPT ${deploy_script})

# Make IDEs aware of the QML import path
set(QML_IMPORT_PATH ${PROJECT_BINARY_DIR}/qml CACHE PATH
    "Path to the custom QML components defined by the project")
