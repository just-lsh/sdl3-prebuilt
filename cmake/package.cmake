# Packs one library's stage into dist/<name>-<target>.zip on Windows or
# dist/<name>-<target>.tar.gz elsewhere (keeps the .so/.dylib symlinks),
# plus a .sha256 file.
#
#   cmake -DTARGET=<target> -DLIB=<lib> [-DNAME=<name>] -P cmake/package.cmake
#
# NAME defaults to LIB; releases pass the tag. The archive's top-level folder
# is <target>/, so archives of different libraries can be extracted into the
# same folder:
#   <target>/bin/        DLLs (Windows), shadercross CLI + its runtime
#   <target>/lib/        .so/.dylib/.a (Linux, macOS); .lib (Windows)
#   <target>/include/    C headers
#   <target>/licenses/   the library's and its vendored third-party code's
#   <target>/manifest/   <lib>.txt: version, commit, SDL it was built against
foreach(var TARGET LIB)
  if(NOT DEFINED ${var})
    message(FATAL_ERROR "package.cmake: -D${var}=... is required")
  endif()
endforeach()
if(NOT DEFINED NAME)
  set(NAME "${LIB}")
endif()

get_filename_component(ROOT "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)
set(STAGE "${ROOT}/stage/${TARGET}/${LIB}")
if(NOT EXISTS "${STAGE}/manifest/${LIB}.txt")
  message(FATAL_ERROR "stage/${TARGET}/${LIB} is missing or incomplete; build ${LIB} first")
endif()

# Copy to <work>/<target>/ so that the archive's top-level folder is the target.
set(work "${ROOT}/build/package/${LIB}")
file(REMOVE_RECURSE "${work}")
file(COPY "${STAGE}/" DESTINATION "${work}/${TARGET}")

# Licenses land in share/licenses/ (Unix) or licenses/ (MSVC). Use one place.
set(dir "${work}/${TARGET}")
if(IS_DIRECTORY "${dir}/share/licenses")
  file(COPY "${dir}/share/licenses/" DESTINATION "${dir}/licenses")
  file(REMOVE_RECURSE "${dir}/share/licenses")
  file(GLOB rest "${dir}/share/*")
  if(NOT rest)
    file(REMOVE_RECURSE "${dir}/share")
  endif()
endif()

if("${TARGET}" MATCHES "windows")
  set(file "${NAME}-${TARGET}.zip")
  set(archive "${ROOT}/dist/${file}")
  set(tar_args cf "${archive}" --format=zip)
else()
  set(file "${NAME}-${TARGET}.tar.gz")
  set(archive "${ROOT}/dist/${file}")
  set(tar_args czf "${archive}")
endif()
file(MAKE_DIRECTORY "${ROOT}/dist")
file(REMOVE "${archive}" "${archive}.sha256")
execute_process(
  COMMAND "${CMAKE_COMMAND}" -E tar ${tar_args} "${TARGET}"
  WORKING_DIRECTORY "${work}"
  COMMAND_ERROR_IS_FATAL ANY)

file(SHA256 "${archive}" hash)
# LF even on Windows, where file(WRITE) would write CRLF and break `sha256sum -c`.
file(CONFIGURE OUTPUT "${archive}.sha256" CONTENT "${hash}  ${file}\n" @ONLY NEWLINE_STYLE UNIX)
message(STATUS "${archive}")
