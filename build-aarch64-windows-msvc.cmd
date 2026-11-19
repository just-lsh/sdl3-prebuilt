@echo off
rem Build every library for aarch64-windows-msvc into a fresh stage\aarch64-windows-msvc\.
rem Run from an x64-hosted ARM64 cross MSVC environment
rem (vcvarsamd64_arm64.bat). Order matters: the
rem other libraries build against the SDL in the stage.
setlocal

if exist "%~dp0stage\aarch64-windows-msvc" rmdir /s /q "%~dp0stage\aarch64-windows-msvc"

call "%~dp0SDL\build-aarch64-windows-msvc.cmd" || exit /b 1
call "%~dp0SDL_image\build-aarch64-windows-msvc.cmd" || exit /b 1
call "%~dp0SDL_ttf\build-aarch64-windows-msvc.cmd" || exit /b 1
call "%~dp0SDL_mixer\build-aarch64-windows-msvc.cmd" || exit /b 1
call "%~dp0SDL_shadercross\build-aarch64-windows-msvc.cmd" || exit /b 1
