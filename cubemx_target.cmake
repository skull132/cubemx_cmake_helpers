
# Assuming input format: STM32F401xE
function(cube_mcu_to_defines MCU_NAME)
    set(options USE_HAL USE_LL)
    set(oneValueArgs FLOAT_ABI OUT_SOURCE_DEFS OUT_TOOLCHAIN_DEFS OUT_MCU_FAMILY)
    set(multiValueArgs)

    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}"
        "${multiValueArgs}" ${ARGN})

    string(SUBSTRING "${MCU_NAME}" 0 7 MCU_FAMILY)
    set(MCU_FAMILY "${MCU_FAMILY}xx")

    if (DEFINED ARG_OUT_MCU_FAMILY)
        set(${ARG_OUT_MCU_FAMILY} ${MCU_FAMILY} PARENT_SCOPE)
    endif ()

    if (NOT DEFINED ARG_USE_HAL)
        set(ARG_USE_HAL ON)
    endif ()

    if (NOT DEFINED ARG_USE_LL)
        set(ARG_USE_LL OFF)
    endif ()

    if (NOT DEFINED ARG_FLOAT_ABI)
        set(ARG_FLOAT_ABI "hard")
    endif ()

    if (DEFINED ARG_OUT_TOOLCHAIN_DEFS)
        set(TOOLCHAIN_DEFS_STM32F4xx "-mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16")
        set(TOOLCHAIN_DEFS_STM32F3xx "-mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16")
        set(TOOLCHAIN_DEFS_STM32F2xx "-mcpu=cortex-m3 -mthumb")
        set(TOOLCHAIN_DEFS_STM32F1xx "-mcpu=cortex-m3 -mthumb")
        set(TOOLCHAIN_DEFS_STM32F0xx "-mcpu=cortex-m0 -mthumb")

        set(TOOLCHAIN_DEFS_VAR "TOOLCHAIN_DEFS_${MCU_FAMILY}")

        if (NOT DEFINED ${TOOLCHAIN_DEFS_VAR})
            message(FATAL_ERROR "Toolchain flags for ${MCU_FAMILY} (looking for ${TOOLCHAIN_DEFS_VAR}) family not defined.")
        endif ()

        if (NOT "${${TOOLCHAIN_DEFS_VAR}}" MATCHES "mfpu" AND ARG_FLOAT_ABI STREQUAL "hard")
            message(FATAL_ERROR "Toolchain is configured to use -mfloat-abi=hard for an MCU without an FPU. Use -DCUBE_FLOAT_ABI=soft or =softfp to fix. Float ABI: ${ARG_FLOAT_ABI}")
        endif ()

            set(TOOLCHAIN_DEFS "${${TOOLCHAIN_DEFS_VAR}} -D${MCU_NAME} -mfloat-abi=${ARG_FLOAT_ABI}")
        if (${ARG_USE_HAL})
            set(TOOLCHAIN_DEFS "${TOOLCHAIN_DEFS} -DUSE_HAL_DRIVER")
        endif ()
        if (${ARG_USE_LL})
            set(TOOLCHAIN_DEFS "${TOOLCHAIN_DEFS} -DUSE_LL_DRIVER")
        endif ()

        set(${ARG_OUT_TOOLCHAIN_DEFS} "${TOOLCHAIN_DEFS}" PARENT_SCOPE)
    endif ()

    if (DEFINED ARG_OUT_SOURCE_DEFS)
        set(SOURCE_DEFS "-D${MCU_FAMILY}")
        if (${ARG_USE_HAL})
            set(SOURCE_DEFS "${SOURCE_DEFS} -DUSE_HAL_DRIVER")
        endif ()
        if (${ARG_USE_LL})
            set(SOURCE_DEFS "${SOURCE_DEFS} -DUSE_LL_DRIVER")
        endif ()

        set(${ARG_OUT_SOURCE_DEFS} "${SOURCE_DEFS} $<$<CONFIG:Debug>:-g -gdwarf-2>" PARENT_SCOPE)
    endif ()

endfunction()

function(cube_find_linker_script ROOT_PATH OUT_PATH)
    file(GLOB FOUND_FILES "${ROOT_PATH}/*_FLASH.ld")
    if (NOT DEFINED FOUND_FILES)
        message(FATAL_ERROR "Unable to locate a xxx_FLASH.ld file in the directory ${ROOT_PATH}.")
    endif ()

    set(${OUT_PATH} ${FOUND_FILES} PARENT_SCOPE)
endfunction()

function(cube_attempt_identify_mcu ROOT_PATH OUT_MCU_NAME)
    file(GLOB FOUND_FILE "${ROOT_PATH}/startup_stm32f*.s")
    if (DEFINED FOUND_FILE)
        string(REGEX MATCH "stm32[f,g,h][0-9][0-9][0-9]x[a-z0-9A-Z]" REGEX_MATCH "${FOUND_FILE}")
        string(TOUPPER "${REGEX_MATCH}" MCU_NAME)
        string(REPLACE "X" "x" MCU_NAME "${MCU_NAME}")
        set(${OUT_MCU_NAME} ${MCU_NAME} PARENT_SCOPE)
    else ()
        message(WARNING "Unable to locate a startup file in ${ROOT_PATH}, which is required for MCU identification.")
    endif ()
endfunction()

function(cube_configure_target TARGET)
    set(options USE_HAL USE_LL)
    set(oneValueArgs ROOT_PATH MCU)
    set(multiValueArgs)

    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}"
            "${multiValueArgs}" ${ARGN})

    if (NOT DEFINED ARG_USE_HAL)
        set(ARG_USE_HAL ON)
    endif ()

    if (NOT DEFINED ARG_USE_LL)
        set(ARG_USE_LL OFF)
    endif ()

    if (NOT DEFINED ARG_ROOT_PATH)
        set(ARG_ROOT_PATH ${CMAKE_CURRENT_LIST_DIR})
    endif ()

    if (NOT DEFINED ARG_MCU)
        cube_attempt_identify_mcu(${ARG_ROOT_PATH} ARG_MCU)
        if (NOT DEFINED ARG_MCU)
            message(FATAL_ERROR "Failed to identify MCU. Please provide the MCU argument by hand.")
        endif ()
    endif ()

    set(EXECUTABLE ${TARGET}.out)

    cube_mcu_to_defines(${ARG_MCU}
            ${USE_HAL}
            ${USE_LL}
            OUT_SOURCE_DEFS SRC_DEFS
            OUT_MCU_FAMILY MCU_FAM
    )

    file(GLOB CUBE_SOURCES
        ${ARG_ROOT_PATH}/Drivers/${MCU_FAM}_HAL_Driver/Src/*
        ${ARG_ROOT_PATH}/Drivers/${MCU_FAM}_LL_Driver/Src/*
        ${ARG_ROOT_PATH}/Core/Src/*
        ${ARG_ROOT_PATH}/startup_*.s
    )

    target_sources(${EXECUTABLE}
        PRIVATE
            ${CUBE_SOURCES}
    )

    target_include_directories(${EXECUTABLE}
        SYSTEM PRIVATE
            ${ARG_ROOT_PATH}/Core/Inc
            ${ARG_ROOT_PATH}/Drivers/${MCU_FAM}_HAL_Driver/Inc
            ${ARG_ROOT_PATH}/Drivers/${MCU_FAM}_LL_Driver/Inc
            ${ARG_ROOT_PATH}/Drivers/CMSIS/Device/ST/${MCU_FAM}/Include
            ${ARG_ROOT_PATH}/Drivers/CMSIS/Include
    )

    set_source_files_properties(${CUBE_SOURCES}
        PROPERTIES
            COMPILE_FLAGS -Wno-unused-parameter
    )

    target_compile_definitions(${EXECUTABLE}
        PRIVATE
            ${SRC_DEFS}
    )

    cube_find_linker_script("${ARG_ROOT_PATH}" LINKER_SCRIPT)

    target_link_options(${EXECUTABLE}
        PRIVATE
            -T${LINKER_SCRIPT}
            -Wl,-Map=${TARGET}.map,--cref
    )

    set_target_properties(${EXECUTABLE}
        PROPERTIES
            ADDITIONAL_CLEAN_FILES "${TARGET}.bin;${TARGET}.hex;${TARGET}.map"
    )

    add_custom_command(TARGET ${EXECUTABLE}
        POST_BUILD
            COMMAND arm-none-eabi-objcopy -O ihex ${EXECUTABLE} ${TARGET}.hex
            COMMAND arm-none-eabi-objcopy -O binary ${EXECUTABLE} ${TARGET}.bin
    )

endfunction()
