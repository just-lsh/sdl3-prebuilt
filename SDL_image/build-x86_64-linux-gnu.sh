#!/bin/sh
# Build SDL_image (shared and static) for x86_64-linux-gnu into stage/x86_64-linux-gnu/SDL_image/.
# Needs SDL built first.
set -eu

TARGET=x86_64-linux-gnu
DIR=$(cd "$(dirname "$0")" && pwd)
ROOT=$(dirname "$DIR")
BUILD=$ROOT/build/$TARGET/SDL_image
STAGE=$ROOT/stage/$TARGET/SDL_image
SDL_STAGE=$ROOT/stage/$TARGET/SDL

# Vendored third-party code for the enabled features (see cache.cmake).
git -C "$DIR/source" submodule update --init --depth 1 -- external/libwebp

# Shared libraries. $ORIGIN is for the dynamic linker: libraries find each
# other next to themselves, executables look in ../lib.
cmake -S "$DIR/source" -B "$BUILD/shared" -G Ninja -C "$DIR/cache.cmake" \
  -DBUILD_SHARED_LIBS=ON \
  "-DCMAKE_INSTALL_PREFIX=$STAGE" \
  "-DCMAKE_PREFIX_PATH=$SDL_STAGE" \
  '-DCMAKE_INSTALL_RPATH=$ORIGIN:$ORIGIN/../lib'
cmake --build "$BUILD/shared"
cmake --install "$BUILD/shared"

# Static libraries.
cmake -S "$DIR/source" -B "$BUILD/static" -G Ninja -C "$DIR/cache.cmake" \
  -DBUILD_SHARED_LIBS=OFF \
  "-DCMAKE_INSTALL_PREFIX=$STAGE" \
  "-DCMAKE_PREFIX_PATH=$SDL_STAGE" \
  '-DCMAKE_INSTALL_RPATH=$ORIGIN:$ORIGIN/../lib'
cmake --build "$BUILD/static"
cmake --install "$BUILD/static"

cmake "-DSOURCE=$DIR/source/external/libwebp" "-DNAME=libwebp" "-DSTAGE=$STAGE" -P "$ROOT/cmake/licenses.cmake"
cmake "-DNAME=SDL_image" "-DSTAGE=$STAGE" "-DSDL_STAGE=$SDL_STAGE" -P "$ROOT/cmake/record.cmake"
