#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
output=${1:?absolute empty output directory is required}
python3 "$root/.github/rpg-runtime/candidate_descriptor.py" prepare "$output"
mkdir -p "$root/.retrom-build"
work=$(mktemp -d "$root/.retrom-build/retrom-mame2003-web.XXXXXX")
trap 'rm -rf "$work"' EXIT INT TERM
mkdir -p "$work/raw" "$work/build"
"$root/.github/rpg-runtime/test-native.sh" "$work"
source_digest=$(python3 "$root/.github/rpg-runtime/candidate_descriptor.py" digest "$output")
python3 "$root/.github/rpg-runtime/candidate_descriptor.py" paths "$output" > "$work/source-files"
tar -C "$root" --null --verbatim-files-from -T "$work/source-files" -cf "$work/source.tar"

export RETROM_HOST_UID="$(id -u)"
export RETROM_HOST_GID="$(id -g)"
if ! docker run --rm --platform linux/amd64 --hostname retrom-mame2003 \
  --env RETROM_HOST_UID --env RETROM_HOST_GID \
  --volume "$work/source.tar:/source.tar:ro" \
  --volume "$root/.github/rpg-runtime:/recipe:ro" \
  --volume "$work/build:/work" \
  --volume "$work/raw:/output" \
  emscripten/emsdk@sha256:af45409f3199d88db4b1b03af0098532c8fb33a375ac257463eeb0a622870d06 \
  /recipe/build-emulatorjs-core.sh mame2003 \
  >"$work/build.log" 2>&1; then
  tail -200 "$work/build.log" >&2
  exit 1
fi

test "$source_digest" = "$(python3 "$root/.github/rpg-runtime/candidate_descriptor.py" digest "$output")"
stage="$work/stage"
mkdir -p "$stage"
install -m 0644 "$work/raw/mame2003_libretro.js" "$stage/"
install -m 0644 "$work/raw/mame2003_libretro.wasm" "$stage/"
install -m 0644 "$root/LICENSE.md" "$stage/license.txt"
printf '%s\n' '{"minimumEJSVersion":"4.2.2","version":"1.2"}' > "$stage/build.json"
printf '%s\n' '{"name":"mame2003","extensions":["zip"],"makeoptions":{"buildpath":"./","makescript":"Makefile","arguments":[]},"options":{"file":"MAME 2003 (0.78)/MAME 2003 (0.78).opt","settings":{"mame2003_skip_disclaimer":"enabled","mame2003_skip_warnings":"enabled"}},"save":false,"license":"LICENSE.md","repo":"https://github.com/retrom-project/mame2003-libretro"}' > "$stage/core.json"

(cd "$stage" && 7z a -mtm=off -mta=off -mtc=off -bd -bso0 -bsp0 -t7z "$output/mame2003-wasm.data" \
  mame2003_libretro.js mame2003_libretro.wasm build.json core.json license.txt)
install -m 0644 "$root/LICENSE.md" "$output/LICENSE.md"

gzip -n -c "$work/source.tar" > "$output/source.tar.gz"
