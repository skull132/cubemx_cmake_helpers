## 
## Some chunks copyright (c) 2018 Johannes Bruder,
## Licensed under MIT from https://github.com/jobroe/cmake-arm-embedded/tree/master
##

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR ARM)

set(TOOLCHAIN arm-none-eabi)

if(NOT DEFINED TOOLCHAIN_PREFIX)
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)
        set(TOOLCHAIN_PREFIX "/usr")
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Darwin)
        set(TOOLCHAIN_PREFIX "/usr/local")
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Windows)
        message(STATUS "Please specify the TOOLCHAIN_PREFIX !\n For example: -DTOOLCHAIN_PREFIX=\"C:/Program Files/GNU Tools ARM Embedded\" ")
    else()
        set(TOOLCHAIN_PREFIX "/usr")
        message(STATUS "No TOOLCHAIN_PREFIX specified, using default: " ${TOOLCHAIN_PREFIX})
    endif()
endif()

set(TOOLCHAIN_BIN_DIR ${TOOLCHAIN_PREFIX}/bin)
set(TOOLCHAIN_INC_DIR ${TOOLCHAIN_PREFIX}/${TOOLCHAIN}/include)
set(TOOLCHAIN_LIB_DIR ${TOOLCHAIN_PREFIX}/${TOOLCHAIN}/lib)

# Set system depended extensions
if(WIN32)
    set(TOOLCHAIN_EXT ".exe" )
else()
    set(TOOLCHAIN_EXT "" )
endif()

# Perform compiler test with static library
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(CMAKE_C_COMPILER ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN}-gcc${TOOLCHAIN_EXT} CACHE INTERNAL "C Compiler")
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN}-g++${TOOLCHAIN_EXT} CACHE INTERNAL "C++ Compiler")
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN}-gcc${TOOLCHAIN_EXT} CACHE INTERNAL "ASM Compiler")

set(CMAKE_FIND_ROOT_PATH ${TOOLCHAIN_PREFIX}/${${TOOLCHAIN}} ${CMAKE_PREFIX_PATH})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Common flag setting
set(COMMON_C_FLAGS "-Wall -Wextra -fdata-sections -ffunction-sections -mthumb")

set(CMAKE_C_FLAGS "${COMMON_C_FLAGS}")
set(CMAKE_CXX_FLAGS "${COMMON_C_FLAGS} -fno-exceptions -fno-rtti -fno-use-cxa-atexit")
set(CMAKE_ASM_FLAGS "${COMMON_C_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS "${COMMON_C_FLAGS} -lc -lm -lnosys -specs=nano.specs -specs=nosys.specs -Wl,--gc-sections -Xlinker --print-memory-usage")

# Release and debug configurations
set(CMAKE_C_FLAGS_DEBUG "-Og -g -gdwarf-2" CACHE INTERNAL "C Compiler options for debug build type")
set(CMAKE_CXX_FLAGS_DEBUG "-Og -g -gdwarf-2" CACHE INTERNAL "C++ Compiler options for debug build type")
set(CMAKE_ASM_FLAGS_DEBUG "-g" CACHE INTERNAL "ASM Compiler options for debug build type")
set(CMAKE_EXE_LINKER_FLAGS_DEBUG "" CACHE INTERNAL "Linker options for debug build type")

set(CMAKE_C_FLAGS_RELEASE "-Os" CACHE INTERNAL "C Compiler options for release build type")
set(CMAKE_CXX_FLAGS_RELEASE "-Os" CACHE INTERNAL "C++ Compiler options for release build type")
set(CMAKE_ASM_FLAGS_RELEASE "" CACHE INTERNAL "ASM Compiler options for release build type")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "" CACHE INTERNAL "Linker options for release build type")
