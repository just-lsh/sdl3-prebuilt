# Packs stage/<target>/ into dist/<target>.tar.gz plus a .sha256 file.
#
#   cmake -DTARGET=<target> -P cmake/package.cmake
#
# Archive layout (top-level folder = target name):
#   <target>/bin/        DLLs (Windows), shadercross CLI + its runtime
#   <target>/lib/        .so/.dylib/.a (Linux, macOS); .lib (Windows)
#   <target>/include/    C headers
#   <target>/licenses/   one folder per library, incl. vendored third-party code
#   <target>/manifest/   <lib>.txt: the commit each library was built from
if(NOT DEFINED TARGET)
  message(FATAL_ERROR "package.cmake: -DTARGET=... is required")
endif()

get_filename_component(ROOT "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)
set(STAGE "${ROOT}/stage/${TARGET}")
if(NOT IS_DIRECTORY "${STAGE}/manifest")
  message(FATAL_ERROR "stage/${TARGET} is missing or incomplete; run build-${TARGET} first")
endif()

# Licenses land in share/licenses/ (Unix) or licenses/ (MSVC). Use one place.
if(IS_DIRECTORY "${STAGE}/share/licenses")
  file(COPY "${STAGE}/share/licenses/" DESTINATION "${STAGE}/licenses")
  file(REMOVE_RECURSE "${STAGE}/share/licenses")
  file(GLOB rest "${STAGE}/share/*")
  if(NOT rest)
    file(REMOVE_RECURSE "${STAGE}/share")
  endif()
endif()

set(archive "${ROOT}/dist/${TARGET}.tar.gz")
file(MAKE_DIRECTORY "${ROOT}/dist")
file(REMOVE "${archive}" "${archive}.sha256")
execute_process(
  COMMAND "${CMAKE_COMMAND}" -E tar czf "${archive}" "${TARGET}"
  WORKING_DIRECTORY "${ROOT}/stage"
  COMMAND_ERROR_IS_FATAL ANY)

file(SHA256 "${archive}" hash)
file(WRITE "${archive}.sha256" "${hash}  ${TARGET}.tar.gz\n")
message(STATUS "${hash}  ${TARGET}.tar.gz")
