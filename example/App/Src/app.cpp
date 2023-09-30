
#include "app.hpp"

#include "gpio.h"
#include "main.h"

#include <cstdint>

extern "C" void app_main()
{
    while (true)
    {
        HAL_GPIO_TogglePin(LD2_GPIO_Port, LD2_Pin);
        HAL_Delay(1000);
    }
}
