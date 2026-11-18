#!/bin/sh
# Build SDL_mixer (shared and static) for aarch64-macos into stage/aarch64-macos/.
# Needs SDL in the stage first.
set -eu

TARGET=aarch64-macos
DIR=$(cd "$(dirname "$0")" && pwd)
ROOT=$(dirname "$DIR")
BUILD=$ROOT/build/$TARGET/SDL_mixer
STAGE=$ROOT/stage/$TARGET

# build <shared|static> <BUILD_SHARED_LIBS>
# Libraries find each other next to themselves, executables look in ../lib.
build() {
  cmake -S "$DIR/source" -B "$BUILD/$1" -G Ninja -C "$DIR/cache.cmake" \
    "-DBUILD_SHARED_LIBS=$2" \
    "-DCMAKE_INSTALL_PREFIX=$STAGE" \
    "-DCMAKE_PREFIX_PATH=$STAGE" \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 \
    '-DCMAKE_INSTALL_RPATH=@loader_path;@loader_path/../lib'
  cmake --build "$BUILD/$1"
  cmake --install "$BUILD/$1"
}
build shared ON
build static OFF

cmake "-DNAME=SDL_mixer" "-DSOURCE=$DIR/source" "-DSTAGE=$STAGE" -P "$ROOT/cmake/record.cmake"
