set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR ARM)

set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER arm-none-eabi-g++)
set(CMAKE_ASM_COMPILER arm-none-eabi-gcc)
set(CMAKE_RANLIB arm-none-eabi-ranlib)

set(COMMON_C_FLAGS "-fdata-sections -ffunction-sections")
set(CMAKE_C_FLAGS_INIT "${COMMON_C_FLAGS}")
set(CMAKE_CXX_FLAGS_INIT "${COMMON_C_FLAGS} -fno-exceptions -fno-rtti -fno-use-cxa-atexit")
set(CMAKE_ASM_FLAGS_INIT "${COMMON_C_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS_INIT "${COMMON_C_FLAGS} -lc -lm -lnosys -specs=nosys.specs -Wl,--gc-sections -Xlinker --print-memory-usage")
