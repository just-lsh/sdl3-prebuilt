#!/bin/sh
# Build SDL_shadercross (shared + static library and the CLI) for
# x86_64-linux-gnu into stage/x86_64-linux-gnu/. Microsoft's prebuilt DXC
# needs glibc 2.38, newer than the Steam Runtime (sniper) we build in, so DXC
# is built from source: expect 30-60+ minutes.
# Needs SDL in the stage first.
set -eu

TARGET=x86_64-linux-gnu
DIR=$(cd "$(dirname "$0")" && pwd)
ROOT=$(dirname "$DIR")
BUILD=$ROOT/build/$TARGET/SDL_shadercross
STAGE=$ROOT/stage/$TARGET

git -C "$DIR/source" submodule update --init --depth 1 -- \
  external/SPIRV-Cross external/SPIRV-Headers external/SPIRV-Tools external/DirectXShaderCompiler
git -C "$DIR/source/external/DirectXShaderCompiler" submodule update --init --recursive --depth 1

# $ORIGIN is for the dynamic linker: libraries find each other next to
# themselves, executables look in ../lib.
cmake -S "$DIR/source" -B "$BUILD/shadercross" -G Ninja -C "$DIR/cache.cmake" \
  -DSDLSHADERCROSS_VENDORED=ON \
  "-DCMAKE_INSTALL_PREFIX=$STAGE" \
  "-DCMAKE_PREFIX_PATH=$STAGE" \
  '-DCMAKE_INSTALL_RPATH=$ORIGIN:$ORIGIN/../lib'
cmake --build "$BUILD/shadercross"
cmake --install "$BUILD/shadercross"

cmake "-DSOURCE=$DIR/source/external/SPIRV-Cross" "-DNAME=SPIRV-Cross" "-DSTAGE=$STAGE" -P "$ROOT/cmake/licenses.cmake"
cmake "-DSOURCE=$DIR/source/external/SPIRV-Tools" "-DNAME=SPIRV-Tools" "-DSTAGE=$STAGE" -P "$ROOT/cmake/licenses.cmake"
cmake "-DSOURCE=$DIR/source/external/DirectXShaderCompiler" "-DNAME=DirectXShaderCompiler" "-DSTAGE=$STAGE" -P "$ROOT/cmake/licenses.cmake"
cmake "-DNAME=SDL_shadercross" "-DSOURCE=$DIR/source" "-DSTAGE=$STAGE" -P "$ROOT/cmake/record.cmake"
