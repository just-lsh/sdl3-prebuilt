#!/bin/sh
# Build SDL_shadercross (shared + static library and the CLI) for
# x86_64-linux-gnu into stage/x86_64-linux-gnu/, using Microsoft's prebuilt
# DXC. Needs SDL in the stage first.
set -eu

TARGET=x86_64-linux-gnu
DIR=$(cd "$(dirname "$0")" && pwd)
ROOT=$(dirname "$DIR")
BUILD=$ROOT/build/$TARGET/SDL_shadercross
STAGE=$ROOT/stage/$TARGET

git -C "$DIR/source" submodule update --init --depth 1 -- external/SPIRV-Cross

# DXC first: shadercross's configure step looks for it.
cmake -DSYSTEM=Linux "-DBUILD=$BUILD" "-DSTAGE=$STAGE" -P "$DIR/dxc.cmake"

cmake -S "$DIR/source/external/SPIRV-Cross" -B "$BUILD/SPIRV-Cross" -G Ninja -C "$DIR/spirv-cross.cmake" \
  "-DCMAKE_INSTALL_PREFIX=$STAGE"
cmake --build "$BUILD/SPIRV-Cross"
cmake --install "$BUILD/SPIRV-Cross"

# $ORIGIN is for the dynamic linker: libraries find each other next to
# themselves, executables look in ../lib.
cmake -S "$DIR/source" -B "$BUILD/shadercross" -G Ninja -C "$DIR/cache.cmake" \
  -DSDLSHADERCROSS_VENDORED=OFF \
  "-DCMAKE_INSTALL_PREFIX=$STAGE" \
  "-DCMAKE_PREFIX_PATH=$STAGE" \
  '-DCMAKE_INSTALL_RPATH=$ORIGIN:$ORIGIN/../lib'
cmake --build "$BUILD/shadercross"
cmake --install "$BUILD/shadercross"

cmake "-DSOURCE=$DIR/source/external/SPIRV-Cross" "-DNAME=SPIRV-Cross" "-DSTAGE=$STAGE" -P "$ROOT/cmake/licenses.cmake"
cmake "-DNAME=SDL_shadercross" "-DSOURCE=$DIR/source" "-DSTAGE=$STAGE" -P "$ROOT/cmake/record.cmake"
