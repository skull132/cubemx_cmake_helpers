set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR ARM)

set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER arm-none-eabi-g++)
set(CMAKE_ASM_COMPILER arm-none-eabi-gcc)
set(CMAKE_RANLIB arm-none-eabi-ranlib)

include(${CMAKE_CURRENT_LIST_DIR}/cubemx_target.cmake)

option(CUBE_USE_HAL "Set to enable the usage of HAL." ON)
option(CUBE_USE_LL "Set to enable the usage of LL." OFF)

if (NOT DEFINED CUBE_FLOAT_ABI)
    set(CUBE_FLOAT_ABI "soft")
endif ()

if (NOT DEFINED CUBE_MCU)
    if (NOT DEFINED CUBE_ROOT_PATH)
        set(CUBE_ROOT_PATH "${CMAKE_CURRENT_LIST_DIR}/..")
    endif ()
    cube_attempt_identify_mcu(${CUBE_ROOT_PATH} CUBE_MCU)

    if (NOT DEFINED CUBE_MCU)
        message(FATAL_ERROR "Cannot identify MCU. Please provide via -DCUBE_MCU. Currently used CUBE_ROOT_PATH=${CUBE_ROOT_PATH}")
    endif ()
endif ()

cube_mcu_to_defines(${CUBE_MCU}
    FLOAT_ABI ${CUBE_FLOAT_ABI}
    USE_HAL ${CUBE_USE_HAL}
    USE_LL ${CUBE_USE_LL}
    OUT_TOOLCHAIN_DEFS TLC_DEFS
)

set(COMMON_C_FLAGS "${TLC_DEFS} -fdata-sections -ffunction-sections")
set(CMAKE_C_FLAGS_INIT "${COMMON_C_FLAGS}")
set(CMAKE_CXX_FLAGS_INIT "${COMMON_C_FLAGS} -fno-exceptions -fno-rtti -fno-use-cxa-atexit")
set(CMAKE_ASM_FLAGS_INIT "${COMMON_C_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS_INIT "${COMMON_C_FLAGS} -lc -lm -lnosys -specs=nosys.specs -Wl,--gc-sections -Xlinker --print-memory-usage")
