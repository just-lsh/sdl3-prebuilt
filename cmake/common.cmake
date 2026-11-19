# Settings every library gets. Included from each <lib>/cache.cmake,
# which the build scripts pass to CMake with -C.
set(CMAKE_BUILD_TYPE Release CACHE STRING "")
set(CMAKE_INSTALL_LIBDIR lib CACHE PATH "")
set(CMAKE_INSTALL_BINDIR bin CACHE PATH "")
set(CMAKE_INSTALL_INCLUDEDIR include CACHE PATH "")

# MSVC only (ignored elsewhere): static CRT (/MT), matching what Odin links
# (libcmt). Without it, linking the static libraries into an Odin program
# gives CRT conflicts. The policy makes projects that predate CMake 3.15
# (e.g. SPIRV-Cross) honor the setting instead of silently using /MD.
set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreaded CACHE STRING "")
set(CMAKE_POLICY_DEFAULT_CMP0091 NEW CACHE STRING "")
