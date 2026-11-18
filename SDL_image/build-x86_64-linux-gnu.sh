#!/bin/sh
# Build SDL_image (shared and static) for x86_64-linux-gnu into stage/x86_64-linux-gnu/.
# Needs SDL in the stage first.
set -eu

TARGET=x86_64-linux-gnu
DIR=$(cd "$(dirname "$0")" && pwd)
ROOT=$(dirname "$DIR")
BUILD=$ROOT/build/$TARGET/SDL_image
STAGE=$ROOT/stage/$TARGET

# Vendored third-party code for the enabled features (see cache.cmake).
git -C "$DIR/source" submodule update --init --depth 1 -- external/libwebp

# build <shared|static> <BUILD_SHARED_LIBS>
# $ORIGIN is for the dynamic linker: libraries find each other next to
# themselves, executables look in ../lib.
build() {
  cmake -S "$DIR/source" -B "$BUILD/$1" -G Ninja -C "$DIR/cache.cmake" \
    "-DBUILD_SHARED_LIBS=$2" \
    "-DCMAKE_INSTALL_PREFIX=$STAGE" \
    "-DCMAKE_PREFIX_PATH=$STAGE" \
    '-DCMAKE_INSTALL_RPATH=$ORIGIN:$ORIGIN/../lib'
  cmake --build "$BUILD/$1"
  cmake --install "$BUILD/$1"
}
build shared ON
build static OFF

cmake "-DSOURCE=$DIR/source/external/libwebp" "-DNAME=libwebp" "-DSTAGE=$STAGE" -P "$ROOT/cmake/licenses.cmake"
cmake "-DNAME=SDL_image" "-DSOURCE=$DIR/source" "-DSTAGE=$STAGE" -P "$ROOT/cmake/record.cmake"
