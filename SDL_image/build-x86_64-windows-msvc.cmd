@echo off
rem Build SDL_image (shared and static) for x86_64-windows-msvc into stage\x86_64-windows-msvc\.
rem Needs SDL in the stage first. Run from an x64 MSVC environment (vcvars64.bat).
setlocal

set TARGET=x86_64-windows-msvc
for %%I in ("%~dp0.") do set DIR=%%~fI
for %%I in ("%~dp0..") do set ROOT=%%~fI
set DIR=%DIR:\=/%
set ROOT=%ROOT:\=/%
set BUILD=%ROOT%/build/%TARGET%/SDL_image
set STAGE=%ROOT%/stage/%TARGET%

rem Vendored third-party code for the enabled features (see cache.cmake).
git -C "%DIR%/source" submodule update --init --depth 1 -- external/libwebp || exit /b 1

call :build shared ON || exit /b 1
call :build static OFF || exit /b 1

cmake "-DSOURCE=%DIR%/source/external/libwebp" "-DNAME=libwebp" "-DSTAGE=%STAGE%" -P "%ROOT%/cmake/licenses.cmake" || exit /b 1
cmake "-DNAME=SDL_image" "-DSOURCE=%DIR%/source" "-DSTAGE=%STAGE%" -P "%ROOT%/cmake/record.cmake" || exit /b 1
exit /b 0

rem build <shared|static> <BUILD_SHARED_LIBS>
:build
cmake -S "%DIR%/source" -B "%BUILD%/%1" -G Ninja -C "%DIR%/cache.cmake" ^
  -DBUILD_SHARED_LIBS=%2 ^
  "-DCMAKE_INSTALL_PREFIX=%STAGE%" ^
  "-DCMAKE_PREFIX_PATH=%STAGE%" || exit /b 1
cmake --build "%BUILD%/%1" || exit /b 1
cmake --install "%BUILD%/%1" || exit /b 1
exit /b 0
