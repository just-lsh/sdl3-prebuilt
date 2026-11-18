# SDL_image's CMake options, the same for every target.
#
# PNG/JPEG via stb_image (no libpng/libjpeg), QOI/BMP/GIF/TGA/SVG built in,
# WebP via vendored libwebp (submodule source/external/libwebp, fetched by the
# build scripts). Third-party code is linked *into* the library, so a shared
# build is one file.
#
# AVIF, JPEG XL and TIFF are off: they pull in large codecs. To enable one,
# set it ON and add its submodule(s) to the build scripts' `git submodule` line:
#   AVIF -> external/libavif external/dav1d external/aom
#   JXL  -> external/libjxl
#   TIF  -> external/libtiff
include(${CMAKE_CURRENT_LIST_DIR}/../cmake/common.cmake)

set(SDLIMAGE_VENDORED ON CACHE BOOL "")
set(SDLIMAGE_DEPS_SHARED OFF CACHE BOOL "")
set(SDLIMAGE_SAMPLES OFF CACHE BOOL "")
set(SDLIMAGE_TESTS OFF CACHE BOOL "")
set(SDLIMAGE_BACKEND_STB ON CACHE BOOL "")
set(SDLIMAGE_BACKEND_IMAGEIO OFF CACHE BOOL "")
set(SDLIMAGE_BACKEND_WIC OFF CACHE BOOL "")
set(SDLIMAGE_PNG_LIBPNG OFF CACHE BOOL "")
set(SDLIMAGE_AVIF OFF CACHE BOOL "")
set(SDLIMAGE_JXL OFF CACHE BOOL "")
set(SDLIMAGE_TIF OFF CACHE BOOL "")
set(SDLIMAGE_WEBP ON CACHE BOOL "")
