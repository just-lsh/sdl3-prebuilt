# Copies the license files of vendored third-party code, which doesn't always
# install them itself.
#
#   cmake -DSOURCE=<dir> -DNAME=<name> -DSTAGE=<stage dir> -P licenses.cmake
#
# Looks in <dir> and one level below it, and copies matches to
# <stage>/licenses/vendored/<name>/, keeping their relative paths.
foreach(var SOURCE NAME STAGE)
  if(NOT DEFINED ${var})
    message(FATAL_ERROR "licenses.cmake: -D${var}=... is required")
  endif()
endforeach()

file(GLOB candidates RELATIVE "${SOURCE}" "${SOURCE}/*" "${SOURCE}/*/*")
set(found 0)
foreach(rel IN LISTS candidates)
  if(IS_DIRECTORY "${SOURCE}/${rel}" OR rel MATCHES "(^|/)(\\.git|test[^/]*)/")
    continue()
  endif()
  get_filename_component(name "${rel}" NAME)
  string(TOLOWER "${name}" name)
  if(name MATCHES "^(license|copying|thirdpartynotices|notice)" OR name STREQUAL "ftl.txt")
    get_filename_component(subdir "${rel}" DIRECTORY)
    file(COPY "${SOURCE}/${rel}" DESTINATION "${STAGE}/licenses/vendored/${NAME}/${subdir}")
    math(EXPR found "${found} + 1")
  endif()
endforeach()

if(found EQUAL 0)
  message(FATAL_ERROR "licenses.cmake: no license files found in ${SOURCE}")
endif()
message(STATUS "${NAME}: ${found} license file(s)")
