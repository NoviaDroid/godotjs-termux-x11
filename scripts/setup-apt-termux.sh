#!/usr/bin/env bash
set -euo pipefail
if [[ "${PREFIX:-}" != /data/data/com.termux/files/usr || $(uname -m) != aarch64 ]]; then
  echo 'This repository is only for bare Termux aarch64 with the standard PREFIX.' >&2
  exit 2
fi
for cmd in curl sha256sum gpg apt; do
  command -v "$cmd" >/dev/null || { echo 'First run: pkg install x11-repo curl gnupg' >&2; exit 2; }
done
repo=https://noviadroid.github.io/godotjs-termux-x11
key_sha=4aec9cf09aa248c70d0e12effedb5eba905736d8905c1c2421af3b2b27b5d6b8
key_dir="$PREFIX/etc/apt/keyrings"
source_file="$PREFIX/etc/apt/sources.list.d/godotjs.list"
pin_file="$PREFIX/etc/apt/preferences.d/godotjs"
source_line="deb [arch=aarch64 signed-by=$key_dir/godotjs.gpg] $repo stable main"
pin_text=$'Package: godotjs\nPin: release o=GodotJS-Termux\nPin-Priority: 500\n\nPackage: *\nPin: release o=GodotJS-Termux\nPin-Priority: -1'
if [[ -e "$source_file" && $(<"$source_file") != "$source_line" ]]; then
  echo "Existing custom source differs: $source_file. Review it before proceeding." >&2; exit 2
fi
if [[ -e "$pin_file" && $(<"$pin_file") != "$pin_text" ]]; then
  echo "Existing custom pin differs: $pin_file. Review it before proceeding." >&2; exit 2
fi
stage=$(mktemp -d)
curl -fL --retry 3 "$repo/repo-key.asc" -o "$stage/repo-key.asc"
printf '%s  %s\n' "$key_sha" "$stage/repo-key.asc" | sha256sum -c -
gpg --batch --dearmor --output "$stage/godotjs.gpg" "$stage/repo-key.asc"
if [[ -e "$key_dir/godotjs.gpg" ]] && ! cmp -s "$key_dir/godotjs.gpg" "$stage/godotjs.gpg"; then
  echo 'An existing GodotJS key differs. Review key rotation manually.' >&2; exit 2
fi
mkdir -p "$key_dir" "$(dirname "$source_file")" "$(dirname "$pin_file")"
install -m 644 "$stage/godotjs.gpg" "$key_dir/godotjs.gpg"
printf '%s\n' "$source_line" > "$source_file"
printf '%s\n' "$pin_text" > "$pin_file"
apt update
echo 'Signed repository configured. Install with: apt install godotjs'
echo 'Driver conflicts must be reviewed; do not force package replacement.'
