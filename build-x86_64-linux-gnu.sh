#!/bin/sh
# Build every library for x86_64-linux-gnu into a fresh stage/x86_64-linux-gnu/.
# Order matters: the other libraries build against the SDL in the stage.
set -eu
ROOT=$(cd "$(dirname "$0")" && pwd)

rm -rf "$ROOT/stage/x86_64-linux-gnu"

"$ROOT/SDL/build-x86_64-linux-gnu.sh"
"$ROOT/SDL_image/build-x86_64-linux-gnu.sh"
"$ROOT/SDL_ttf/build-x86_64-linux-gnu.sh"
"$ROOT/SDL_mixer/build-x86_64-linux-gnu.sh"
"$ROOT/SDL_shadercross/build-x86_64-linux-gnu.sh"
