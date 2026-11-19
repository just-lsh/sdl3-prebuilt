@echo off
rem Build every library for x86_64-windows-msvc into a fresh stage\x86_64-windows-msvc\.
rem Run from an x64 MSVC environment (vcvars64.bat). Order matters: the
rem other libraries build against the SDL in the stage.
setlocal

if exist "%~dp0stage\x86_64-windows-msvc" rmdir /s /q "%~dp0stage\x86_64-windows-msvc"

call "%~dp0SDL\build-x86_64-windows-msvc.cmd" || exit /b 1
call "%~dp0SDL_image\build-x86_64-windows-msvc.cmd" || exit /b 1
call "%~dp0SDL_ttf\build-x86_64-windows-msvc.cmd" || exit /b 1
call "%~dp0SDL_mixer\build-x86_64-windows-msvc.cmd" || exit /b 1
call "%~dp0SDL_shadercross\build-x86_64-windows-msvc.cmd" || exit /b 1
