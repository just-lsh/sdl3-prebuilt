# Fetches Microsoft's prebuilt DXC for Windows and copies its runtime and
# import library into the stage. (Linux and macOS build DXC from source.)
#
#   cmake -DBUILD=<build dir> -DSTAGE=<stage dir> [-DARCH=x64|arm64] -P dxc.cmake
#
# ARCH picks the binaries from the release archive, which holds x86, x64 and
# arm64; it defaults to x64.
#
# The download URL and hash are pinned by shadercross's own script, which
# unpacks into source/external/DirectXShaderCompiler-binaries/: shadercross's
# CMakeLists expects it there. The import library is for linking the static
# shadercross library.
foreach(var BUILD STAGE)
  if(NOT DEFINED ${var})
    message(FATAL_ERROR "dxc.cmake: -D${var}=... is required")
  endif()
endforeach()
if(NOT DEFINED ARCH)
  set(ARCH x64)
endif()
if(NOT ARCH MATCHES "^(x64|arm64)$")
  message(FATAL_ERROR "dxc.cmake: ARCH must be x64 or arm64, not '${ARCH}'")
endif()

# Picks which archive the script downloads.
set(CMAKE_SYSTEM_NAME Windows)
# FetchContent puts its scratch folders here instead of the current directory.
set(CMAKE_CURRENT_BINARY_DIR "${BUILD}")
include("${CMAKE_CURRENT_LIST_DIR}/source/build-scripts/download-prebuilt-DirectXShaderCompiler.cmake")
# (sets DXC_ROOT)

set(dir "${DXC_ROOT}/windows")
file(COPY "${dir}/bin/${ARCH}/dxcompiler.dll" "${dir}/bin/${ARCH}/dxil.dll" DESTINATION "${STAGE}/bin")
file(COPY "${dir}/lib/${ARCH}/dxcompiler.lib" DESTINATION "${STAGE}/lib")

file(GLOB licenses "${dir}/LICENSE*")
file(COPY ${licenses} DESTINATION "${STAGE}/licenses/vendored/DirectXShaderCompiler")
