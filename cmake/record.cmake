# Records which commit of a library was built, for the release manifest.
#
#   cmake -DNAME=<lib> -DSOURCE=<source dir> -DSTAGE=<stage dir> -P record.cmake
#
# Writes <stage>/manifest/<lib>.txt containing the source commit.
foreach(var NAME SOURCE STAGE)
  if(NOT DEFINED ${var})
    message(FATAL_ERROR "record.cmake: -D${var}=... is required")
  endif()
endforeach()

execute_process(
  COMMAND git -C "${SOURCE}" rev-parse HEAD
  OUTPUT_VARIABLE commit
  OUTPUT_STRIP_TRAILING_WHITESPACE
  COMMAND_ERROR_IS_FATAL ANY)

file(WRITE "${STAGE}/manifest/${NAME}.txt" "${commit}\n")
message(STATUS "${NAME}: ${commit}")
