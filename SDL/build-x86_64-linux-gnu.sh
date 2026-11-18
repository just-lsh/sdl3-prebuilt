#!/bin/sh
# Build SDL for x86_64-linux-gnu into stage/x86_64-linux-gnu/SDL/.
set -eu

TARGET=x86_64-linux-gnu
DIR=$(cd "$(dirname "$0")" && pwd)
ROOT=$(dirname "$DIR")
BUILD=$ROOT/build/$TARGET/SDL
STAGE=$ROOT/stage/$TARGET/SDL

# $ORIGIN is for the dynamic linker: libraries find each other next to
# themselves, executables look in ../lib.
cmake -S "$DIR/source" -B "$BUILD" -G Ninja -C "$DIR/cache.cmake" \
  "-DCMAKE_INSTALL_PREFIX=$STAGE" \
  '-DCMAKE_INSTALL_RPATH=$ORIGIN:$ORIGIN/../lib'
cmake --build "$BUILD"
cmake --install "$BUILD"
cmake "-DNAME=SDL" "-DSOURCE=$DIR/source" "-DSTAGE=$STAGE" -P "$ROOT/cmake/record.cmake"
