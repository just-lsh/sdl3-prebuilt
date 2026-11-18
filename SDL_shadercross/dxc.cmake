# Fetches Microsoft's prebuilt DXC and copies its runtime into the stage.
#
#   cmake -DSYSTEM=Windows|Linux -DBUILD=<build dir> -DSTAGE=<stage dir> -P dxc.cmake
#
# The download URL and hash are pinned by shadercross's own script, which
# unpacks into source/external/DirectXShaderCompiler-binaries/: shadercross's
# CMakeLists expects it there. Windows also gets the import library, for
# linking the static shadercross library.
foreach(var SYSTEM BUILD STAGE)
  if(NOT DEFINED ${var})
    message(FATAL_ERROR "dxc.cmake: -D${var}=... is required")
  endif()
endforeach()

# Picks which archive the script downloads.
set(CMAKE_SYSTEM_NAME "${SYSTEM}")
# FetchContent puts its scratch folders here instead of the current directory.
set(CMAKE_CURRENT_BINARY_DIR "${BUILD}")
include("${CMAKE_CURRENT_LIST_DIR}/source/build-scripts/download-prebuilt-DirectXShaderCompiler.cmake")
# (sets DXC_ROOT)

if(SYSTEM STREQUAL "Windows")
  set(dir "${DXC_ROOT}/windows")
  file(COPY "${dir}/bin/x64/dxcompiler.dll" "${dir}/bin/x64/dxil.dll" DESTINATION "${STAGE}/bin")
  file(COPY "${dir}/lib/x64/dxcompiler.lib" DESTINATION "${STAGE}/lib")
elseif(SYSTEM STREQUAL "Linux")
  set(dir "${DXC_ROOT}/linux")
  # Keeps the .so symlinks as symlinks.
  file(GLOB libs "${dir}/lib/libdxcompiler.so*" "${dir}/lib/libdxil.so*")
  file(COPY ${libs} DESTINATION "${STAGE}/lib")
else()
  message(FATAL_ERROR "dxc.cmake: no prebuilt DXC for SYSTEM=${SYSTEM}")
endif()

file(GLOB licenses "${dir}/LICENSE*")
file(COPY ${licenses} DESTINATION "${STAGE}/licenses/vendored/DirectXShaderCompiler")
