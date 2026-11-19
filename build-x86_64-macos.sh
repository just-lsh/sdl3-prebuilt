#!/bin/sh
# Build every library for x86_64-macos into a fresh stage/x86_64-macos/.
# Order matters: the other libraries build against the SDL in the stage.
set -eu
ROOT=$(cd "$(dirname "$0")" && pwd)

rm -rf "$ROOT/stage/x86_64-macos"

"$ROOT/SDL/build-x86_64-macos.sh"
"$ROOT/SDL_image/build-x86_64-macos.sh"
"$ROOT/SDL_ttf/build-x86_64-macos.sh"
"$ROOT/SDL_mixer/build-x86_64-macos.sh"
"$ROOT/SDL_shadercross/build-x86_64-macos.sh"
