@echo off
rem Build SDL_mixer (shared and static) for x86_64-windows-msvc into stage\x86_64-windows-msvc\SDL_mixer\.
rem Needs SDL built first. Run from an x64 MSVC environment (vcvars64.bat).
setlocal

set TARGET=x86_64-windows-msvc
for %%I in ("%~dp0.") do set DIR=%%~fI
for %%I in ("%~dp0..") do set ROOT=%%~fI
set DIR=%DIR:\=/%
set ROOT=%ROOT:\=/%
set BUILD=%ROOT%/build/%TARGET%/SDL_mixer
set STAGE=%ROOT%/stage/%TARGET%/SDL_mixer
set SDL_STAGE=%ROOT%/stage/%TARGET%/SDL

rem Shared libraries.
cmake -S "%DIR%/source" -B "%BUILD%/shared" -G Ninja -C "%DIR%/cache.cmake" ^
  -DBUILD_SHARED_LIBS=ON ^
  "-DCMAKE_INSTALL_PREFIX=%STAGE%" ^
  "-DCMAKE_PREFIX_PATH=%SDL_STAGE%" || exit /b 1
cmake --build "%BUILD%/shared" || exit /b 1
cmake --install "%BUILD%/shared" || exit /b 1

rem Static libraries.
cmake -S "%DIR%/source" -B "%BUILD%/static" -G Ninja -C "%DIR%/cache.cmake" ^
  -DBUILD_SHARED_LIBS=OFF ^
  "-DCMAKE_INSTALL_PREFIX=%STAGE%" ^
  "-DCMAKE_PREFIX_PATH=%SDL_STAGE%" || exit /b 1
cmake --build "%BUILD%/static" || exit /b 1
cmake --install "%BUILD%/static" || exit /b 1

cmake "-DNAME=SDL_mixer" "-DSOURCE=%DIR%/source" "-DSTAGE=%STAGE%" -P "%ROOT%/cmake/record.cmake" || exit /b 1
