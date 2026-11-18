#!/bin/sh
# Build SDL_ttf (shared and static) for x86_64-linux-gnu into stage/x86_64-linux-gnu/SDL_ttf/.
# Needs SDL built first.
set -eu

TARGET=x86_64-linux-gnu
DIR=$(cd "$(dirname "$0")" && pwd)
ROOT=$(dirname "$DIR")
BUILD=$ROOT/build/$TARGET/SDL_ttf
STAGE=$ROOT/stage/$TARGET/SDL_ttf
SDL_STAGE=$ROOT/stage/$TARGET/SDL

# Vendored third-party code for the enabled features (see cache.cmake).
git -C "$DIR/source" submodule update --init --depth 1 -- external/freetype external/harfbuzz external/plutosvg external/plutovg

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

cmake "-DSOURCE=$DIR/source/external/freetype" "-DNAME=freetype" "-DSTAGE=$STAGE" -P "$ROOT/cmake/licenses.cmake"
cmake "-DSOURCE=$DIR/source/external/harfbuzz" "-DNAME=harfbuzz" "-DSTAGE=$STAGE" -P "$ROOT/cmake/licenses.cmake"
cmake "-DSOURCE=$DIR/source/external/plutosvg" "-DNAME=plutosvg" "-DSTAGE=$STAGE" -P "$ROOT/cmake/licenses.cmake"
cmake "-DSOURCE=$DIR/source/external/plutovg" "-DNAME=plutovg" "-DSTAGE=$STAGE" -P "$ROOT/cmake/licenses.cmake"
cmake "-DNAME=SDL_ttf" "-DSOURCE=$DIR/source" "-DSTAGE=$STAGE" -P "$ROOT/cmake/record.cmake"
