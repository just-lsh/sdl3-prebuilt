# Fetches Microsoft's prebuilt DXC for Windows and copies its runtime and
# import library into the stage. (Linux and macOS build DXC from source.)
#
#   cmake -DBUILD=<build dir> -DSTAGE=<stage dir> -P dxc.cmake
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

# Picks which archive the script downloads.
set(CMAKE_SYSTEM_NAME Windows)
# FetchContent puts its scratch folders here instead of the current directory.
set(CMAKE_CURRENT_BINARY_DIR "${BUILD}")
include("${CMAKE_CURRENT_LIST_DIR}/source/build-scripts/download-prebuilt-DirectXShaderCompiler.cmake")
# (sets DXC_ROOT)

set(dir "${DXC_ROOT}/windows")
file(COPY "${dir}/bin/x64/dxcompiler.dll" "${dir}/bin/x64/dxil.dll" DESTINATION "${STAGE}/bin")
file(COPY "${dir}/lib/x64/dxcompiler.lib" DESTINATION "${STAGE}/lib")

file(GLOB licenses "${dir}/LICENSE*")
file(COPY ${licenses} DESTINATION "${STAGE}/licenses/vendored/DirectXShaderCompiler")
