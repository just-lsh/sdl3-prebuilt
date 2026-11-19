# SPIRV-Cross's CMake options, for targets using prebuilt DXC (where
# shadercross expects SPIRV-Cross to be installed already).
# Static + PIC: the shared shadercross library links it in, and the static
# one needs these archives installed next to it.
include(${CMAKE_CURRENT_LIST_DIR}/../cmake/common.cmake)

set(SPIRV_CROSS_SHARED OFF CACHE BOOL "")
set(SPIRV_CROSS_STATIC ON CACHE BOOL "")
set(SPIRV_CROSS_CLI OFF CACHE BOOL "")
set(SPIRV_CROSS_ENABLE_TESTS OFF CACHE BOOL "")
set(CMAKE_POSITION_INDEPENDENT_CODE ON CACHE BOOL "")
