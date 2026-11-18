# sdl3-prebuilt

Builds SDL3, SDL_image, SDL_ttf, SDL_mixer and SDL_shadercross (library + CLI) for
desktop targets and publishes them as GitHub releases. Projects download
the archive for their target instead of building SDL themselves.

| Target                | Runner           | shadercross                 |
|-----------------------|------------------|-----------------------------|
| `x86_64-windows-msvc` | `windows-latest` | yes (prebuilt DXC)          |
| `x86_64-linux-gnu`    | `ubuntu-22.04`   | yes (prebuilt DXC)          |
| `aarch64-macos`       | `macos-latest`   | yes (DXC from source, slow) |

Target names are Zig-style `<arch>-<os>[-<abi>]` triples. The ABI says what
the binaries are compatible with: `msvc` means MSVC libraries with the static
CRT (`/MT`), not MinGW; `gnu` means glibc, not musl. The Linux build needs at
least the glibc of Ubuntu 22.04 (2.35). macOS 11.0 or newer.

## Layout

```
<lib>/                          one folder per library: SDL, SDL_image, SDL_ttf,
                                SDL_mixer, SDL_shadercross
  source/                       submodule, pinned to the commit that gets built
  cache.cmake                   the library's CMake options, shared by all targets
  build-<target>.sh / .cmd      build this library for one target
build-<target>.sh / .cmd        build every library for one target, in order
cmake/
  common.cmake                  options every library gets (Release, install dirs)
  licenses.cmake                copy vendored third-party licenses into the stage
  record.cmake                  write stage/<target>/manifest/<lib>.txt
  package.cmake                 stage/<target>/ -> dist/<target>.tar.gz + .sha256
.github/workflows/
  build.yml                     matrix build, reused by the two below
  ci.yml                        pull requests: build all targets, keep artifacts 14 days
  release.yml                   tag push: build all targets, publish a release
```

Every script installs into `stage/<target>/`. The satellites and shadercross
find SDL there, so SDL has to be built first; the top-level
`build-<target>` scripts start from an empty stage and run the libraries in
order. Generated (ignored): `build/`, `stage/`, `dist/`.

## Getting started

```sh
git clone <this repo> && cd sdl3-prebuilt
git submodule update --init --depth 1   # top level only; build scripts fetch nested ones
./build-x86_64-linux-gnu.sh             # or the target for your machine
cmake -DTARGET=x86_64-linux-gnu -P cmake/package.cmake
```

`--depth 1` matters: without it Git fetches each library's full history
(~450 MB instead of ~40 MB).

Requirements: CMake 3.24+, Ninja, Git, and a C/C++ compiler.

- **Windows:** Visual Studio 2022 or newer with the C++ workload. Run the
  `.cmd` scripts from an x64 MSVC environment (the "x64 Native Tools Command
  Prompt", or after calling `vcvars64.bat`); the scripts don't set it up.
- **Linux:** the packages listed in `.github/workflows/build.yml`.
- **macOS:** Xcode command line tools and `brew install ninja`.

To rebuild one library, run its script directly, e.g.
`SDL_image/build-x86_64-linux-gnu.sh`. It installs over what is already in
the stage.

## Updating a library

Each library is pinned by its submodule commit, nothing else:

```sh
git switch -c bump-sdl
git -C SDL/source fetch --depth 1 origin tag release-3.4.22
git -C SDL/source checkout release-3.4.22
git add SDL/source
git commit -m "Bump SDL to release-3.4.22"
git push -u origin bump-sdl              # open a PR; ci.yml builds all targets
```

SDL_shadercross has no release tags yet; fetch and check out a commit
instead.

## Releasing

After the PR is merged:

```sh
git tag 3.4.22-r1 && git push origin 3.4.22-r1
```

Tags are `<SDL version>-r<n>`. Increase `n` when only satellites, shadercross
or build options changed. The release contains `<target>.tar.gz` and
`<target>.tar.gz.sha256` for every target, and notes listing each library's
commit and the checksums.

## Archive contents

```
<target>/
  lib/          Linux/macOS: libSDL3.so.0 / libSDL3.0.dylib (+ symlinks) and libSDL3.a
                Windows:     SDL3.lib (import lib) and SDL3-static.lib
                ...same for SDL3_image, SDL3_ttf, SDL3_mixer, SDL3_shadercross
                (MSVC static: SDL3_shadercross-static.lib)
                plus spirv-cross-*.a/.lib and the DXC library (see shadercross below)
  bin/          Windows: the DLLs. All: the shadercross CLI
  include/      C headers
  licenses/     one folder per library, including vendored third-party code
  manifest/     <lib>.txt: the commit each library was built from
```

## Notes for linking from Odin

- **Shared libraries** are the simple default. Third-party code (libwebp,
  FreeType, HarfBuzz, ...) is linked *into* each satellite, so each one is a
  single file next to `SDL3`. Linux libraries have `RPATH=$ORIGIN` and macOS
  ones use `@rpath`/`@loader_path`, so they find each other when placed
  together.
- **Static libraries** need their vendored dependencies too:
  - `SDL3_image-static` also needs the installed `libwebp`, `libwebpdemux`,
    `libwebpmux` and `libsharpyuv` archives.
  - `SDL3_ttf-static` contains HarfBuzz, which is C++: link the C++ runtime
    (`-lstdc++` on Linux, `-lc++` on macOS).
  - Static SDL needs the system libraries/frameworks it was built against.
    The exact list is in `lib/pkgconfig/sdl3.pc` (`Libs.private`), and the
    same goes for each satellite's `.pc` file.
- **Windows CRT:** everything is built with the static CRT (`/MT`), matching
  Odin's default (`libcmt`). If you build your Odin program with a different
  CRT setting, change `CMAKE_MSVC_RUNTIME_LIBRARY` in `cmake/common.cmake`.
- **Picking the folder:** map `ODIN_OS`/`ODIN_ARCH` to a target name:
  `.Windows`/`.amd64` -> `x86_64-windows-msvc`, `.Linux`/`.amd64` ->
  `x86_64-linux-gnu`, `.Darwin`/`.arm64` -> `aarch64-macos`.

## shadercross

Shipped as a shared library, a static library and the `shadercross` CLI, for
building your own shader tooling (HLSL to SPIR-V, MSL, DXIL, plus
reflection). None of it is meant to go into the app itself.

Both library variants call into **DXC** (`dxcompiler`) directly, and DXC only
exists as a shared library. So whatever you build needs `dxcompiler` at link
time and `dxcompiler` + `dxil` next to it at run time (`dxil` signs DXIL
output; without it DXIL compilation fails).

**Shared:** link `SDL3_shadercross` and `SDL3`. SPIRV-Cross is inside
`SDL3_shadercross`.

**Static:** link, in this order:

| What | Linux / macOS | Windows |
|---|---|---|
| shadercross | `libSDL3_shadercross.a` | `SDL3_shadercross-static.lib` |
| SPIRV-Cross | `libspirv-cross-{c,msl,hlsl,glsl,cpp,reflect,core}.a` | `spirv-cross-{...}.lib` |
| SDL | `libSDL3.a` (or the shared one) | `SDL3-static.lib` (or `SDL3.lib`) |
| DXC | `libdxcompiler.so` / `.dylib` | `dxcompiler.lib` (import lib) |
| C++ runtime | `stdc++` (Linux), `c++` (macOS) | automatic |

All seven SPIRV-Cross archives are needed: `spirv-cross-c` references the
C++ and reflection backends. Tested from Odin on Linux:

```odin
foreign import shadercross {
	"lib/libSDL3_shadercross.a",
	"lib/libspirv-cross-c.a",
	"lib/libspirv-cross-msl.a",
	"lib/libspirv-cross-hlsl.a",
	"lib/libspirv-cross-glsl.a",
	"lib/libspirv-cross-cpp.a",
	"lib/libspirv-cross-reflect.a",
	"lib/libspirv-cross-core.a",
	"lib/libSDL3.a",
	"system:dxcompiler",   // with -extra-linker-flags:"-L<lib> -Wl,-rpath,$ORIGIN"
	"system:stdc++",
	"system:m",
}
```

### Where DXC comes from

- **Windows, Linux:** Microsoft's prebuilt DXC release, whose URL and hash are
  pinned by shadercross itself (`SDL_shadercross/dxc.cmake` downloads it and
  copies the runtime into the stage). SPIRV-Cross is built first as a
  separate project.
- **macOS:** no prebuilt release exists, so DXC (an LLVM fork) is built from
  source together with shadercross. Expect 30-60+ minutes.

`SDLSHADERCROSS_INSTALL_RUNTIME` is deliberately off: it would download
vkd3d and Vulkan components from unpinned `main` branches.

## Changing enabled features

Edit the library's `cache.cmake`. To turn on a format that needs a
third-party library, set its option `ON` and add the matching nested
submodule to the `git submodule update` line in that library's build
scripts (the comments in `cache.cmake` list them), plus a `licenses.cmake`
line for it.
