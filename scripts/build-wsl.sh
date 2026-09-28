#!/usr/bin/env bash
set -euo pipefail
workflow="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
work="${1:-/opt/godotjs-rebuild}"
container=godotjs-rebuild
image=ghcr.io/termux/package-builder@sha256:1db92723f6a82fd3ba45288d68ff99dbdeb08a3e9f3f0c4750115178cc7a6879
framework=f7394465d24dd1b5e4ca99290f04a95e6072357d
module=a8e2567e796b4688de64e7e40ef64279a0df8209
if [[ "$work" != /* || -e "$work" ]]; then
  echo 'Provide an absolute, not-yet-existing Linux workspace path.' >&2
  exit 2
fi
if [[ $(id -u) != 0 ]]; then
  echo 'Run with sudo: source mounts need the container builder UID.' >&2
  exit 2
fi
docker info >/dev/null
if docker container inspect "$container" >/dev/null 2>&1; then
  echo "Container $container already exists; resume it instead." >&2
  exit 2
fi
mkdir -p -- "$work"
git init "$work/termux-packages"
git -C "$work/termux-packages" remote add origin https://github.com/termux/termux-packages.git
git -C "$work/termux-packages" fetch --depth 1 origin "$framework"
git -C "$work/termux-packages" checkout --detach "$framework"
python3 "$workflow/scripts/prepare-termux.py" "$work/termux-packages"
git clone --depth 1 --branch v1.1.0.beta1-4.6.1 --recurse-submodules \
  https://github.com/godotjs/GodotJS.git "$work/module"
test "$(git -C "$work/module" rev-parse HEAD)" = "$module"
docker pull "$image"
chown -R 1001:1001 "$work/termux-packages" "$work/module"
docker run -d --name "$container" \
  --mount "type=bind,src=$work/termux-packages,dst=/home/builder/termux-packages" \
  --mount "type=bind,src=$work/module,dst=/home/builder/godotjs-module" \
  --mount "type=bind,src=$workflow,dst=/workflow,readonly" \
  "$image" sleep infinity
docker exec -u root "$container" bash -lc 'apt-get update && apt-get install -y nodejs npm'
docker exec "$container" bash /workflow/scripts/container-build.sh
printf '\nPackages: %s/termux-packages/output/\n' "$work"
