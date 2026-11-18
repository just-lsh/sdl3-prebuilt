#!/bin/sh
# Build SDL_image (shared and static) for aarch64-macos into stage/aarch64-macos/.
# Needs SDL in the stage first.
set -eu

TARGET=aarch64-macos
DIR=$(cd "$(dirname "$0")" && pwd)
ROOT=$(dirname "$DIR")
BUILD=$ROOT/build/$TARGET/SDL_image
STAGE=$ROOT/stage/$TARGET

# Vendored third-party code for the enabled features (see cache.cmake).
git -C "$DIR/source" submodule update --init --depth 1 -- external/libwebp

# Shared libraries. Libraries find each other next to themselves,
# executables look in ../lib.
cmake -S "$DIR/source" -B "$BUILD/shared" -G Ninja -C "$DIR/cache.cmake" \
  -DBUILD_SHARED_LIBS=ON \
  "-DCMAKE_INSTALL_PREFIX=$STAGE" \
  "-DCMAKE_PREFIX_PATH=$STAGE" \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 \
  '-DCMAKE_INSTALL_RPATH=@loader_path;@loader_path/../lib'
cmake --build "$BUILD/shared"
cmake --install "$BUILD/shared"

# Static libraries.
cmake -S "$DIR/source" -B "$BUILD/static" -G Ninja -C "$DIR/cache.cmake" \
  -DBUILD_SHARED_LIBS=OFF \
  "-DCMAKE_INSTALL_PREFIX=$STAGE" \
  "-DCMAKE_PREFIX_PATH=$STAGE" \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 \
  '-DCMAKE_INSTALL_RPATH=@loader_path;@loader_path/../lib'
cmake --build "$BUILD/static"
cmake --install "$BUILD/static"

cmake "-DSOURCE=$DIR/source/external/libwebp" "-DNAME=libwebp" "-DSTAGE=$STAGE" -P "$ROOT/cmake/licenses.cmake"
cmake "-DNAME=SDL_image" "-DSOURCE=$DIR/source" "-DSTAGE=$STAGE" -P "$ROOT/cmake/record.cmake"
