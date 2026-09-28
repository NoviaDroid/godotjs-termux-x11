TERMUX_PKG_HOMEPAGE=https://github.com/godotjs/GodotJS
TERMUX_PKG_DESCRIPTION="Godot 4.6.1 with QuickJS-NG for Termux X11"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION=4.6.1
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/godotengine/godot/archive/refs/tags/4.6.1-stable.tar.gz
TERMUX_PKG_SHA256=f5d887cda2589fd2995b1cf7e74fe1ec54220f56d7fd6729a8a0865d794fb287
TERMUX_PKG_DEPENDS="ca-certificates, fontconfig, libandroid-execinfo, libc++, libxcursor, libxi, libxinerama, libxkbcommon, libxrandr, opengl, pulseaudio, sdl3, vulkan-loader-generic"
# SCons is a host-only build tool already installed in the official builder.
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
    cp -a /home/builder/godotjs-module "$TERMUX_PKG_SRCDIR/modules/GodotJS"
}

termux_step_make() {
    export BUILD_NAME=termux_godotjs
    scons -j8 platform=linuxbsd arch=arm64 target=editor \
        use_llvm=yes use_static_cpp=no lto=none \
        x11=yes wayland=no vulkan=yes opengl3=yes use_volk=yes \
        builtin_sdl=no \
        alsa=no pulseaudio=yes udev=no dbus=no speechd=no \
        execinfo=yes accesskit=no module_camera_enabled=no \
        use_quickjs_ng=yes use_quickjs=no skip_js_runtime=yes \
        system_certs_path="$TERMUX_PREFIX/etc/tls/cert.pem" \
        AR="$(command -v "$AR")" CC="$(command -v "$CC")" \
        CXX="$(command -v "$CXX")" OBJCOPY="$(command -v "$OBJCOPY")" \
        STRIP="$(command -v "$STRIP")" \
        cflags="$CPPFLAGS $CFLAGS" cxxflags="$CPPFLAGS $CXXFLAGS" \
        linkflags="$LDFLAGS -landroid-execinfo" \
        CPPPATH="$TERMUX_PREFIX/include" LIBPATH="$TERMUX_PREFIX/lib"
}

termux_step_make_install() {
    install -Dm755 bin/godot.linuxbsd.editor.arm64.llvm "$TERMUX_PREFIX/bin/godotjs"
    install -Dm644 LICENSE.txt "$TERMUX_PREFIX/share/licenses/godotjs/Godot-LICENSE"
    install -Dm644 COPYRIGHT.txt "$TERMUX_PREFIX/share/licenses/godotjs/Godot-COPYRIGHT"
    install -Dm644 modules/GodotJS/LICENSE "$TERMUX_PREFIX/share/licenses/godotjs/GodotJS-LICENSE"
    install -Dm644 modules/GodotJS/quickjs-ng/LICENSE "$TERMUX_PREFIX/share/licenses/godotjs/QuickJS-NG-LICENSE"
}
