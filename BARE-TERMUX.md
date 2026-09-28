# Bare Termux ARM64 build (compiled; phone validation pending)

Target: Snapdragon 8 Gen 2 / Adreno 740, Android Bionic and Termux:X11.
Build on x86_64 WSL2 with the official Termux Docker builder and Android NDK.
Run directly in Termux, without proot. Ubuntu glibc compilers/drivers do not apply.

Godot: 4.6.1. GodotJS: a8e2567e796b4688de64e7e40ef64279a0df8209
(v1.1.0.beta1-4.6.1). QuickJS-NG is pinned by its submodule.
Termux patches: 177b74a5677ad0d9d6cca46ec597ed37c389be3e.
Termux build framework: f7394465d24dd1b5e4ca99290f04a95e6072357d.
Builder image digest: sha256:1db92723f6a82fd3ba45288d68ff99dbdeb08a3e9f3f0c4750115178cc7a6879.

## Preparation

Install Docker Engine in WSL Ubuntu and start it. Use the WSL Linux filesystem.
Clone termux/termux-packages, checkout the framework commit above, and run:

```bash
python3 scripts/prepare-termux.py /absolute/path/to/termux-packages
git clone --depth 1 --branch v1.1.0.beta1-4.6.1 --recurse-submodules \
  https://github.com/godotjs/GodotJS.git module
docker pull ghcr.io/termux/package-builder@sha256:1db92723f6a82fd3ba45288d68ff99dbdeb08a3e9f3f0c4750115178cc7a6879
```

Mount the Termux tree at /home/builder/termux-packages, module at
/home/builder/godotjs-module, and this repository at /workflow in the container.
Make the source directories writable by the container builder user.
Install host Node.js 24 and npm in the container, then run
`bash /workflow/scripts/container-build.sh` as builder.

The recipe creates a separate godotjs package/command, retaining X11, Vulkan,
Volk and OpenGL. It disables Wayland and the upstream forced-OpenGL default.
Eight compiler jobs and no LTO are used on this machine. Bundled Godot libraries reduce
coupling to newer Termux system dependencies. The result appears in output/.
SDL is the exception: builtin_sdl=no uses Termux sdl3 because the bundled SDL
selects unavailable Android sources when compiled against Bionic.

The workflow applies no-fuse.patch to copy the NDK toolchain instead of using
FUSE mounts. This consumes extra disk space but requires no privileged container
or /dev/fuse passthrough. Keep WSL running while building.

Alternatively, `sudo bash scripts/build-wsl.sh /opt/godotjs-rebuild` prepares a
new workspace and performs these steps. Do not run it over the active build.
The source/image commits are pinned, but downloaded Termux dependencies and
Ubuntu host packages are resolved from their repositories at build time;
this is not a byte-for-byte reproducible build.

## Phone

Install the resulting .deb with `apt install ./<actual-filename>.deb` in Termux.
Enable Termux main/X11 repositories for dependency resolution. Termux:X11's
Android app and companion package must already be running.

GPU drivers are not bundled or replaced. Preserve your existing working Mesa
configuration. Turnip must support Android KGSL and Termux:X11 presentation.
Confirm `vulkaninfo --summary` reports Turnip/Adreno 740 and `glxinfo -B` reports
Zink, rather than llvmpipe/lavapipe software rendering. Do not guess ICD paths.

```bash
export DISPLAY=:0
# Vulkan -> Turnip
godotjs --display-driver x11 --rendering-driver vulkan --rendering-method mobile
# OpenGL -> Zink -> Turnip
MESA_LOADER_DRIVER_OVERRIDE=zink GALLIUM_DRIVER=zink \
  godotjs --display-driver x11 --rendering-driver opengl3 --rendering-method gl_compatibility
```

A complete cross-build succeeded on 2026-09-27, including final linking and
Termux ELF/symbol checks. The resulting package is godotjs_4.6.1-1_aarch64.deb.
The delivered package additionally includes the QuickJS-NG license and a copy
of Godot's third-party notices, without changing the compiled executable.
A successful compile does not establish phone GPU compatibility. Both paths and
a minimal GodotJS project still must be tested on the phone.

Sources: https://github.com/termux/termux-packages/tree/177b74a5677ad0d9d6cca46ec597ed37c389be3e/x11-packages/godot
and https://github.com/godotjs/GodotJS/tree/v1.1.0.beta1-4.6.1
