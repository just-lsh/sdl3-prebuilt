# SDL_mixer's CMake options, the same for every target.
#
# Only the decoders that need no third-party library: WAV/AIFF/VOC/AU,
# FLAC (dr_flac), MP3 (dr_mp3), Ogg Vorbis (stb_vorbis), MIDI (Timidity).
# Opus, MOD (libxmp), GME and WavPack are off.
include(${CMAKE_CURRENT_LIST_DIR}/../cmake/common.cmake)

set(SDLMIXER_VENDORED ON CACHE BOOL "")
set(SDLMIXER_DEPS_SHARED OFF CACHE BOOL "")
set(SDLMIXER_TESTS OFF CACHE BOOL "")
set(SDLMIXER_EXAMPLES OFF CACHE BOOL "")
set(SDLMIXER_FLAC_LIBFLAC OFF CACHE BOOL "")
set(SDLMIXER_MP3_MPG123 OFF CACHE BOOL "")
set(SDLMIXER_VORBIS_VORBISFILE OFF CACHE BOOL "")
set(SDLMIXER_OPUS OFF CACHE BOOL "")
set(SDLMIXER_GME OFF CACHE BOOL "")
set(SDLMIXER_MOD_XMP OFF CACHE BOOL "")
set(SDLMIXER_WAVPACK OFF CACHE BOOL "")
