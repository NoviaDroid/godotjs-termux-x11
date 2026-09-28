#!/usr/bin/env bash
# Isolated metadata + download test. Never installs packages or edits system sources.
set -euo pipefail
repo=https://noviadroid.github.io/godotjs-termux-x11
stage=$(mktemp -d)
chmod 755 "$stage"
mkdir -p "$stage/lists/partial" "$stage/cache/archives/partial" "$stage/download"
touch "$stage/status"
curl -fL --retry 3 "$repo/repo-key.asc" -o "$stage/repo-key.asc"
printf '%s  %s\n' 4aec9cf09aa248c70d0e12effedb5eba905736d8905c1c2421af3b2b27b5d6b8 "$stage/repo-key.asc" | sha256sum -c -
gpg --batch --dearmor --output "$stage/repo-key.gpg" "$stage/repo-key.asc"
printf 'deb [arch=aarch64 signed-by=%s/repo-key.gpg] %s stable main\n' "$stage" "$repo" > "$stage/sources.list"
options=(
  -o Dir::Etc::sourcelist="$stage/sources.list" -o Dir::Etc::sourceparts=-
  -o Dir::Etc::main=- -o Dir::Etc::parts=-
  -o Dir::State::lists="$stage/lists" -o Dir::State::status="$stage/status"
  -o Dir::Cache="$stage/cache" -o APT::Architecture=aarch64
  -o APT::Architectures::=aarch64
)
apt-get "${options[@]}" update
apt-cache "${options[@]}" policy godotjs
(cd "$stage/download" && apt-get "${options[@]}" download godotjs:aarch64)
printf '%s  %s\n' e6b595f5dbe984d76aa0d62088942ff73089e34420be9394e23b672ec83a7c60 "$stage/download/godotjs_4.6.1-1_aarch64.deb" | sha256sum -c -
printf 'Isolated APT test passed. Artifacts retained: %s\n' "$stage"

