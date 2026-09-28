#!/usr/bin/env bash
# Read-only diagnostics. Does not install packages or change driver settings.
set -u
export DISPLAY="${DISPLAY:-:0}"
printf 'Architecture: '; uname -m
printf 'DISPLAY=%s\nPREFIX=%s\n' "$DISPLAY" "${PREFIX:-unset}"
for variable in VK_DRIVER_FILES VK_ICD_FILENAMES MESA_LOADER_DRIVER_OVERRIDE GALLIUM_DRIVER; do
  printf '%s=%s\n' "$variable" "${!variable-unset}"
done
if command -v godotjs >/dev/null 2>&1; then
  godotjs --headless --version
else
  echo 'godotjs not installed or missing from PATH.'
fi
if command -v vulkaninfo >/dev/null 2>&1; then
  vulkaninfo --summary
else
  echo 'vulkaninfo not installed; Vulkan driver has not been checked.'
fi
if command -v glxinfo >/dev/null 2>&1; then
  MESA_LOADER_DRIVER_OVERRIDE=zink GALLIUM_DRIVER=zink glxinfo -B
else
  echo 'glxinfo not installed; Zink rendering has not been checked.'
fi
