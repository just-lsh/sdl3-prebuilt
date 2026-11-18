#!/bin/sh
# Build SDL_shadercross (shared + static library and the CLI) for
# aarch64-macos into stage/aarch64-macos/SDL_shadercross/. There is no
# prebuilt DXC for macOS, so DXC is built from source: expect 30-60+ minutes.
# Needs SDL built first.
set -eu

TARGET=aarch64-macos
DIR=$(cd "$(dirname "$0")" && pwd)
ROOT=$(dirname "$DIR")
BUILD=$ROOT/build/$TARGET/SDL_shadercross
STAGE=$ROOT/stage/$TARGET/SDL_shadercross
SDL_STAGE=$ROOT/stage/$TARGET/SDL

git -C "$DIR/source" submodule update --init --depth 1 -- \
  external/SPIRV-Cross external/SPIRV-Headers external/SPIRV-Tools external/DirectXShaderCompiler
git -C "$DIR/source/external/DirectXShaderCompiler" submodule update --init --recursive --depth 1

# Libraries find each other next to themselves, executables look in ../lib.
cmake -S "$DIR/source" -B "$BUILD/shadercross" -G Ninja -C "$DIR/cache.cmake" \
  -DSDLSHADERCROSS_VENDORED=ON \
  "-DCMAKE_INSTALL_PREFIX=$STAGE" \
  "-DCMAKE_PREFIX_PATH=$SDL_STAGE" \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 \
  '-DCMAKE_INSTALL_RPATH=@loader_path;@loader_path/../lib'
cmake --build "$BUILD/shadercross"
cmake --install "$BUILD/shadercross"

cmake "-DSOURCE=$DIR/source/external/SPIRV-Cross" "-DNAME=SPIRV-Cross" "-DSTAGE=$STAGE" -P "$ROOT/cmake/licenses.cmake"
cmake "-DSOURCE=$DIR/source/external/SPIRV-Tools" "-DNAME=SPIRV-Tools" "-DSTAGE=$STAGE" -P "$ROOT/cmake/licenses.cmake"
cmake "-DSOURCE=$DIR/source/external/DirectXShaderCompiler" "-DNAME=DirectXShaderCompiler" "-DSTAGE=$STAGE" -P "$ROOT/cmake/licenses.cmake"
cmake "-DNAME=SDL_shadercross" "-DSTAGE=$STAGE" "-DSDL_STAGE=$SDL_STAGE" -P "$ROOT/cmake/record.cmake"
