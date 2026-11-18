# SDL's CMake options, the same for every target.
include(${CMAKE_CURRENT_LIST_DIR}/../cmake/common.cmake)

set(SDL_SHARED ON CACHE BOOL "")
set(SDL_STATIC ON CACHE BOOL "")
set(SDL_TEST_LIBRARY OFF CACHE BOOL "")
set(SDL_TESTS OFF CACHE BOOL "")
set(SDL_EXAMPLES OFF CACHE BOOL "")
