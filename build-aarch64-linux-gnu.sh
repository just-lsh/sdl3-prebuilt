#!/bin/sh
# Build every library for aarch64-linux-gnu into a fresh stage/aarch64-linux-gnu/.
# Order matters: the other libraries build against the SDL in the stage.
set -eu
ROOT=$(cd "$(dirname "$0")" && pwd)

rm -rf "$ROOT/stage/aarch64-linux-gnu"

"$ROOT/SDL/build-aarch64-linux-gnu.sh"
"$ROOT/SDL_image/build-aarch64-linux-gnu.sh"
"$ROOT/SDL_ttf/build-aarch64-linux-gnu.sh"
"$ROOT/SDL_mixer/build-aarch64-linux-gnu.sh"
"$ROOT/SDL_shadercross/build-aarch64-linux-gnu.sh"
