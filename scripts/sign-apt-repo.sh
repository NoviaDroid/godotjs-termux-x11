#!/usr/bin/env bash
set -euo pipefail
# Usage: bash scripts/sign-apt-repo.sh package.deb /absolute/external/gnupg-home FINGERPRINT
# Private key storage must be outside this checkout. Never upload private keys.
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
package=$(realpath "${1:?package.deb required}")
signing_home=$(realpath "${2:?external GnuPG home required}")
fingerprint="${3:?signing fingerprint required}"
case "$signing_home/" in "$root/"*) echo 'Private key directory must be outside the checkout.' >&2; exit 2;; esac
test "$(dpkg-deb -f "$package" Package)" = godotjs
test "$(dpkg-deb -f "$package" Architecture)" = aarch64
version=$(dpkg-deb -f "$package" Version)
staging=$(mktemp -d)
mkdir -p "$staging/pool/main/g/godotjs" "$staging/dists/stable/main/binary-aarch64"
cp "$package" "$staging/pool/main/g/godotjs/godotjs_${version}_aarch64.deb"
(cd "$staging" && dpkg-scanpackages --multiversion pool /dev/null > dists/stable/main/binary-aarch64/Packages)
valid_until=$(date -Ru -d '+180 days')
{ printf 'Valid-Until: %s\n' "$valid_until"
(cd "$staging" && apt-ftparchive \
  -o APT::FTPArchive::Release::Origin=GodotJS-Termux \
  -o APT::FTPArchive::Release::Label=GodotJS-Termux \
  -o APT::FTPArchive::Release::Suite=stable \
  -o APT::FTPArchive::Release::Codename=stable \
  -o APT::FTPArchive::Release::Architectures=aarch64 \
  -o APT::FTPArchive::Release::Components=main \
  release dists/stable)
} > "$staging/Release"
mv "$staging/Release" "$staging/dists/stable/Release"
gpg --homedir "$signing_home" --batch --yes --local-user "$fingerprint" --digest-algo SHA256 \
  --clearsign -o "$staging/dists/stable/InRelease" "$staging/dists/stable/Release"
gpg --homedir "$signing_home" --batch --yes --local-user "$fingerprint" --digest-algo SHA256 \
  --armor --detach-sign -o "$staging/dists/stable/Release.gpg" "$staging/dists/stable/Release"
mkdir -p "$root/apt-repo"
cp -a "$staging/dists" "$root/apt-repo/"
gpg --homedir "$signing_home" --armor --export "$fingerprint" > "$root/apt-repo/repo-key.asc"
printf 'Signed metadata generated. Package staging retained at %s\n' "$staging"
sha256sum "$package" "$root/apt-repo/repo-key.asc"
