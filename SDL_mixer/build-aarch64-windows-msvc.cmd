@echo off
rem Build SDL_mixer (shared and static) for aarch64-windows-msvc into stage\aarch64-windows-msvc\SDL_mixer\.
rem Needs SDL built first. Run from an x64-hosted ARM64 cross MSVC environment
rem (vcvarsamd64_arm64.bat).
setlocal

set TARGET=aarch64-windows-msvc
for %%I in ("%~dp0.") do set DIR=%%~fI
for %%I in ("%~dp0..") do set ROOT=%%~fI
set DIR=%DIR:\=/%
set ROOT=%ROOT:\=/%
set BUILD=%ROOT%/build/%TARGET%/SDL_mixer
set STAGE=%ROOT%/stage/%TARGET%/SDL_mixer
rem Cross-compile: cl targets ARM64, but CMake would otherwise describe
rem the target as the x64 host.
set CROSS=-DCMAKE_SYSTEM_NAME=Windows -DCMAKE_SYSTEM_VERSION=10.0 -DCMAKE_SYSTEM_PROCESSOR=ARM64
set SDL_STAGE=%ROOT%/stage/%TARGET%/SDL

rem Shared libraries.
cmake -S "%DIR%/source" -B "%BUILD%/shared" -G Ninja %CROSS% -C "%DIR%/cache.cmake" ^
  -DBUILD_SHARED_LIBS=ON ^
  "-DCMAKE_INSTALL_PREFIX=%STAGE%" ^
  "-DCMAKE_PREFIX_PATH=%SDL_STAGE%" || exit /b 1
cmake --build "%BUILD%/shared" || exit /b 1
cmake --install "%BUILD%/shared" || exit /b 1

rem Static libraries.
cmake -S "%DIR%/source" -B "%BUILD%/static" -G Ninja %CROSS% -C "%DIR%/cache.cmake" ^
  -DBUILD_SHARED_LIBS=OFF ^
  "-DCMAKE_INSTALL_PREFIX=%STAGE%" ^
  "-DCMAKE_PREFIX_PATH=%SDL_STAGE%" || exit /b 1
cmake --build "%BUILD%/static" || exit /b 1
cmake --install "%BUILD%/static" || exit /b 1

cmake "-DNAME=SDL_mixer" "-DSTAGE=%STAGE%" "-DSDL_STAGE=%SDL_STAGE%" -P "%ROOT%/cmake/record.cmake" || exit /b 1
