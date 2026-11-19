@echo off
rem Build SDL for aarch64-windows-msvc into stage\aarch64-windows-msvc\SDL\.
rem Run from an x64-hosted ARM64 cross MSVC environment
rem (vcvarsamd64_arm64.bat).
setlocal

set TARGET=aarch64-windows-msvc
for %%I in ("%~dp0.") do set DIR=%%~fI
for %%I in ("%~dp0..") do set ROOT=%%~fI
set DIR=%DIR:\=/%
set ROOT=%ROOT:\=/%
set BUILD=%ROOT%/build/%TARGET%/SDL
set STAGE=%ROOT%/stage/%TARGET%/SDL
rem Cross-compile: cl targets ARM64, but CMake would otherwise describe
rem the target as the x64 host.
set CROSS=-DCMAKE_SYSTEM_NAME=Windows -DCMAKE_SYSTEM_VERSION=10.0 -DCMAKE_SYSTEM_PROCESSOR=ARM64

cmake -S "%DIR%/source" -B "%BUILD%" -G Ninja %CROSS% -C "%DIR%/cache.cmake" ^
  "-DCMAKE_INSTALL_PREFIX=%STAGE%" || exit /b 1
cmake --build "%BUILD%" || exit /b 1
cmake --install "%BUILD%" || exit /b 1
cmake "-DNAME=SDL" "-DSTAGE=%STAGE%" -P "%ROOT%/cmake/record.cmake" || exit /b 1
