#!/bin/sh
# Build SDL for x86_64-macos into stage/x86_64-macos/SDL/.
set -eu

TARGET=x86_64-macos
DIR=$(cd "$(dirname "$0")" && pwd)
ROOT=$(dirname "$DIR")
BUILD=$ROOT/build/$TARGET/SDL
STAGE=$ROOT/stage/$TARGET/SDL

# Libraries find each other next to themselves, executables look in ../lib.
cmake -S "$DIR/source" -B "$BUILD" -G Ninja -C "$DIR/cache.cmake" \
  "-DCMAKE_INSTALL_PREFIX=$STAGE" \
  -DCMAKE_OSX_ARCHITECTURES=x86_64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 \
  '-DCMAKE_INSTALL_RPATH=@loader_path;@loader_path/../lib'
cmake --build "$BUILD"
cmake --install "$BUILD"
cmake "-DNAME=SDL" "-DSTAGE=$STAGE" -P "$ROOT/cmake/record.cmake"
