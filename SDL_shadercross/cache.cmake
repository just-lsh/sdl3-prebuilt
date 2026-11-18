# SDL_shadercross's CMake options, the same for every target. The build
# scripts add -DSDLSHADERCROSS_VENDORED=ON|OFF: OFF uses Microsoft's prebuilt
# DXC (Windows x64, Linux x64), ON builds DXC from source (macOS; slow).
#
# Shared + static library and the CLI, for build-time shader tooling.
# Both library variants call DXC's DxcCreateInstance directly, so anything
# linking them (even statically) needs the dxcompiler shared library at link
# and run time. SPIRV-Cross is static: inside the shared library, and
# installed as separate archives for linking the static one.
include(${CMAKE_CURRENT_LIST_DIR}/../cmake/common.cmake)

set(SDLSHADERCROSS_SHARED ON CACHE BOOL "")
set(SDLSHADERCROSS_STATIC ON CACHE BOOL "")
set(SDLSHADERCROSS_CLI ON CACHE BOOL "")
set(SDLSHADERCROSS_INSTALL ON CACHE BOOL "")
# Would fetch unpinned vkd3d/Vulkan components from main branches.
set(SDLSHADERCROSS_INSTALL_RUNTIME OFF CACHE BOOL "")
set(SDLSHADERCROSS_TESTS OFF CACHE BOOL "")
set(SDLSHADERCROSS_DXC ON CACHE BOOL "")
# Link SPIRV-Cross into the library.
set(SDLSHADERCROSS_SPIRVCROSS_SHARED OFF CACHE BOOL "")
