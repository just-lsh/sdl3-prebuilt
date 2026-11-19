# SDL's CMake options, the same for every target.
include(${CMAKE_CURRENT_LIST_DIR}/../cmake/common.cmake)

set(SDL_SHARED ON CACHE BOOL "")
set(SDL_STATIC ON CACHE BOOL "")
set(SDL_TEST_LIBRARY OFF CACHE BOOL "")
set(SDL_TESTS OFF CACHE BOOL "")
set(SDL_EXAMPLES OFF CACHE BOOL "")
# pkg-config files find the prefix relative to themselves instead of
# hardcoding the build machine's install path (default ON only for MSVC).
set(SDL_RELOCATABLE ON CACHE BOOL "")
# Appended to SDL_REVISION / SDL_GetRevision(), e.g. "SDL-3.x.y-<hash> (...)".
set(SDL_VENDOR_INFO "github.com/just-lsh/sdl3-prebuilt" CACHE STRING "")
