#!/usr/bin/env bash
set -euo pipefail
mode="${1:-zink}"
if (( $# )); then shift; fi
export DISPLAY="${DISPLAY:-:0}"
case "$mode" in
    zink)
        export MESA_LOADER_DRIVER_OVERRIDE=zink GALLIUM_DRIVER=zink
        exec godotjs --display-driver x11 --rendering-driver opengl3 \
            --rendering-method gl_compatibility "$@"
        ;;
    vulkan)
        exec godotjs --display-driver x11 --rendering-driver vulkan \
            --rendering-method mobile "$@"
        ;;
    *) echo 'Usage: bash launch-phone.sh {zink|vulkan} [Godot arguments]' >&2; exit 2 ;;
esac
