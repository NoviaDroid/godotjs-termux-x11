#!/usr/bin/env bash
set -euo pipefail
cd /home/builder/godotjs-module
test "$(git rev-parse HEAD)" = a8e2567e796b4688de64e7e40ef64279a0df8209
test -f quickjs-ng/quickjs.c
node --version
npm exec --yes --package=pnpm@10.11.0 -- pnpm install --frozen-lockfile
npm exec --yes --package=pnpm@10.11.0 -- pnpm build
cd /home/builder/termux-packages
./build-package.sh -a aarch64 -I godotjs
