# SDL_ttf's CMake options, the same for every target.
#
# FreeType + HarfBuzz (text shaping) + plutosvg (color emoji), all vendored
# (submodules under source/external/, fetched by the build scripts) and linked
# *into* the library, so a shared build is one file.
include(${CMAKE_CURRENT_LIST_DIR}/../cmake/common.cmake)

set(SDLTTF_VENDORED ON CACHE BOOL "")
set(SDLTTF_SAMPLES OFF CACHE BOOL "")
set(SDLTTF_HARFBUZZ ON CACHE BOOL "")
set(SDLTTF_PLUTOSVG ON CACHE BOOL "")
