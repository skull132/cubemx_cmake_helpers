cmake_minimum_required(VERSION 3.16)

project(example)

enable_language(C CXX ASM)

include(../cubemx_target.cmake)

cube_configure_compiler_flags()

set(EXECUTABLE ${PROJECT_NAME}.out)

add_executable(${EXECUTABLE}
    ${CMAKE_CURRENT_LIST_DIR}/App/Src/app.cpp
)

cube_configure_target(${PROJECT_NAME})

target_include_directories(${EXECUTABLE}
    PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/App/Inc
)

set_target_properties(${EXECUTABLE}
    PROPERTIES
        CXX_STANDARD 20
        CXX_STANDARD_REQUIRED TRUE
        C_STANDARD 17
        C_STANDARD_REQUIRED TRUE
)

target_compile_options(${EXECUTABLE}
    PRIVATE
        -Wall
        -Wextra
        $<$<CONFIG:Debug>:-Og>
        $<$<CONFIG:Release>:-O2>
)
