@echo off
rem Build SDL for x86_64-windows-msvc into stage\x86_64-windows-msvc\.
rem Run from an x64 MSVC environment (vcvars64.bat).
setlocal

set TARGET=x86_64-windows-msvc
for %%I in ("%~dp0.") do set DIR=%%~fI
for %%I in ("%~dp0..") do set ROOT=%%~fI
set DIR=%DIR:\=/%
set ROOT=%ROOT:\=/%
set BUILD=%ROOT%/build/%TARGET%/SDL
set STAGE=%ROOT%/stage/%TARGET%

cmake -S "%DIR%/source" -B "%BUILD%" -G Ninja -C "%DIR%/cache.cmake" ^
  "-DCMAKE_INSTALL_PREFIX=%STAGE%" || exit /b 1
cmake --build "%BUILD%" || exit /b 1
cmake --install "%BUILD%" || exit /b 1
cmake "-DNAME=SDL" "-DSOURCE=%DIR%/source" "-DSTAGE=%STAGE%" -P "%ROOT%/cmake/record.cmake" || exit /b 1
