# Prints a library's version: the one in its header, or for SDL_shadercross,
# which has no releases, the short commit of its source.
#
#   cmake -DLIB=<lib> -P version.cmake
if(NOT DEFINED LIB)
  message(FATAL_ERROR "version.cmake: -DLIB=... is required")
endif()

set(source "${CMAKE_CURRENT_LIST_DIR}/../${LIB}/source")

if(LIB STREQUAL "SDL_shadercross")
  execute_process(
    COMMAND git -C "${source}" rev-parse --short=7 HEAD
    OUTPUT_VARIABLE version
    OUTPUT_STRIP_TRAILING_WHITESPACE
    COMMAND_ERROR_IS_FATAL ANY)
else()
  if(LIB STREQUAL "SDL")
    set(header include/SDL3/SDL_version.h)
    set(prefix SDL)
  elseif(LIB STREQUAL "SDL_image")
    set(header include/SDL3_image/SDL_image.h)
    set(prefix SDL_IMAGE)
  elseif(LIB STREQUAL "SDL_ttf")
    set(header include/SDL3_ttf/SDL_ttf.h)
    set(prefix SDL_TTF)
  elseif(LIB STREQUAL "SDL_mixer")
    set(header include/SDL3_mixer/SDL_mixer.h)
    set(prefix SDL_MIXER)
  else()
    message(FATAL_ERROR "version.cmake: unknown library '${LIB}'")
  endif()

  file(STRINGS "${source}/${header}" lines REGEX "^#define ${prefix}_(MAJOR|MINOR|MICRO)_VERSION ")
  set(version "")
  foreach(part MAJOR MINOR MICRO)
    if(NOT lines MATCHES "#define ${prefix}_${part}_VERSION +([0-9]+)")
      message(FATAL_ERROR "version.cmake: ${prefix}_${part}_VERSION not found in ${header}")
    endif()
    list(APPEND version "${CMAKE_MATCH_1}")
  endforeach()
  list(JOIN version "." version)
endif()

execute_process(COMMAND "${CMAKE_COMMAND}" -E echo "${version}")
