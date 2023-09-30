# Usage

First, generate the CubeMX project's files using CubeMX.

Then make a build folder and generate the project:

```sh
$ mkdir build && cd build
$ cmake .. -DCMAKE_TOOLCHAIN_FILE=../../arm-none-eabi.cubemx.cmake
$ make
```

And you can now link libraries, add things via add_subdirectory, etc.
