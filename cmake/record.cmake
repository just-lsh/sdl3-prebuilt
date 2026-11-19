# Records what a library was built from, for the release notes and for
# consumers combining archives.
#
#   cmake -DNAME=<lib> -DSTAGE=<stage dir> [-DSDL_STAGE=<SDL's stage dir>] -P record.cmake
#
# Writes <stage>/manifest/<lib>.txt:
#   version=<version, or short commit for SDL_shadercross>
#   commit=<source commit>
#   sdl-version=<SDL version it was built against>   (with SDL_STAGE only)
#   sdl-commit=<SDL commit it was built against>     (with SDL_STAGE only)
foreach(var NAME STAGE)
  if(NOT DEFINED ${var})
    message(FATAL_ERROR "record.cmake: -D${var}=... is required")
  endif()
endforeach()

execute_process(
  COMMAND "${CMAKE_COMMAND}" "-DLIB=${NAME}" -P "${CMAKE_CURRENT_LIST_DIR}/version.cmake"
  OUTPUT_VARIABLE version
  OUTPUT_STRIP_TRAILING_WHITESPACE
  COMMAND_ERROR_IS_FATAL ANY)
execute_process(
  COMMAND git -C "${CMAKE_CURRENT_LIST_DIR}/../${NAME}/source" rev-parse HEAD
  OUTPUT_VARIABLE commit
  OUTPUT_STRIP_TRAILING_WHITESPACE
  COMMAND_ERROR_IS_FATAL ANY)

set(manifest "version=${version}\ncommit=${commit}\n")

if(DEFINED SDL_STAGE)
  # SDL's own manifest says exactly which SDL is in the stage.
  file(STRINGS "${SDL_STAGE}/manifest/SDL.txt" sdl REGEX "^(version|commit)=")
  foreach(line IN LISTS sdl)
    string(APPEND manifest "sdl-${line}\n")
  endforeach()
endif()

file(WRITE "${STAGE}/manifest/${NAME}.txt" "${manifest}")
message(STATUS "${NAME} ${version} (${commit})")
