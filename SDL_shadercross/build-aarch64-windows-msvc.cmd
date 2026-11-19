@echo off
rem Build SDL_shadercross (shared + static library and the CLI) for
rem aarch64-windows-msvc into stage\aarch64-windows-msvc\SDL_shadercross\,
rem using Microsoft's prebuilt DXC. Needs SDL built first.
rem Run from an x64-hosted ARM64 cross MSVC environment
rem (vcvarsamd64_arm64.bat).
setlocal

set TARGET=aarch64-windows-msvc
for %%I in ("%~dp0.") do set DIR=%%~fI
for %%I in ("%~dp0..") do set ROOT=%%~fI
set DIR=%DIR:\=/%
set ROOT=%ROOT:\=/%
set BUILD=%ROOT%/build/%TARGET%/SDL_shadercross
set STAGE=%ROOT%/stage/%TARGET%/SDL_shadercross
rem Cross-compile: cl targets ARM64, but CMake would otherwise describe
rem the target as the x64 host.
set CROSS=-DCMAKE_SYSTEM_NAME=Windows -DCMAKE_SYSTEM_VERSION=10.0 -DCMAKE_SYSTEM_PROCESSOR=ARM64
set SDL_STAGE=%ROOT%/stage/%TARGET%/SDL

git -C "%DIR%/source" submodule update --init --depth 1 -- external/SPIRV-Cross || exit /b 1

rem DXC first: shadercross's configure step looks for it.
cmake "-DBUILD=%BUILD%" "-DSTAGE=%STAGE%" "-DARCH=arm64" -P "%DIR%/dxc.cmake" || exit /b 1

cmake -S "%DIR%/source/external/SPIRV-Cross" -B "%BUILD%/SPIRV-Cross" -G Ninja %CROSS% -C "%DIR%/spirv-cross.cmake" ^
  "-DCMAKE_INSTALL_PREFIX=%STAGE%" || exit /b 1
cmake --build "%BUILD%/SPIRV-Cross" || exit /b 1
cmake --install "%BUILD%/SPIRV-Cross" || exit /b 1

cmake -S "%DIR%/source" -B "%BUILD%/shadercross" -G Ninja %CROSS% -C "%DIR%/cache.cmake" ^
  -DSDLSHADERCROSS_VENDORED=OFF ^
  "-DCMAKE_INSTALL_PREFIX=%STAGE%" ^
  "-DCMAKE_PREFIX_PATH=%STAGE%;%SDL_STAGE%" || exit /b 1
cmake --build "%BUILD%/shadercross" || exit /b 1
cmake --install "%BUILD%/shadercross" || exit /b 1

cmake "-DSOURCE=%DIR%/source/external/SPIRV-Cross" "-DNAME=SPIRV-Cross" "-DSTAGE=%STAGE%" -P "%ROOT%/cmake/licenses.cmake" || exit /b 1
cmake "-DNAME=SDL_shadercross" "-DSTAGE=%STAGE%" "-DSDL_STAGE=%SDL_STAGE%" -P "%ROOT%/cmake/record.cmake" || exit /b 1
