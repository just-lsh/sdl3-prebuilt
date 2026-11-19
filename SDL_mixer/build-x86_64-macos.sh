#!/bin/sh
# Build SDL_mixer (shared and static) for x86_64-macos into stage/x86_64-macos/SDL_mixer/.
# Needs SDL built first.
set -eu

TARGET=x86_64-macos
DIR=$(cd "$(dirname "$0")" && pwd)
ROOT=$(dirname "$DIR")
BUILD=$ROOT/build/$TARGET/SDL_mixer
STAGE=$ROOT/stage/$TARGET/SDL_mixer
SDL_STAGE=$ROOT/stage/$TARGET/SDL

# Shared libraries. Libraries find each other next to themselves,
# executables look in ../lib.
cmake -S "$DIR/source" -B "$BUILD/shared" -G Ninja -C "$DIR/cache.cmake" \
  -DBUILD_SHARED_LIBS=ON \
  "-DCMAKE_INSTALL_PREFIX=$STAGE" \
  "-DCMAKE_PREFIX_PATH=$SDL_STAGE" \
  -DCMAKE_OSX_ARCHITECTURES=x86_64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 \
  '-DCMAKE_INSTALL_RPATH=@loader_path;@loader_path/../lib'
cmake --build "$BUILD/shared"
cmake --install "$BUILD/shared"

# Static libraries.
cmake -S "$DIR/source" -B "$BUILD/static" -G Ninja -C "$DIR/cache.cmake" \
  -DBUILD_SHARED_LIBS=OFF \
  "-DCMAKE_INSTALL_PREFIX=$STAGE" \
  "-DCMAKE_PREFIX_PATH=$SDL_STAGE" \
  -DCMAKE_OSX_ARCHITECTURES=x86_64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 \
  '-DCMAKE_INSTALL_RPATH=@loader_path;@loader_path/../lib'
cmake --build "$BUILD/static"
cmake --install "$BUILD/static"

cmake "-DNAME=SDL_mixer" "-DSTAGE=$STAGE" "-DSDL_STAGE=$SDL_STAGE" -P "$ROOT/cmake/record.cmake"
