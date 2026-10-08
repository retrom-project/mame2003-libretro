# Retrom mame2003 Web build

Source baseline is EmulatorJS/mame2003-libretro `b6c6d52d8d630d1a172b6b771443dcbbdb45b76d`.
It is the explicit maintenance baseline preceding the deployed EmulatorJS binary's
build date. The old binary does not declare a source commit; this repository does
not claim to reproduce that binary. New candidates record their exact source
commit and source tree digest.

`master` remains the upstream mirror; Retrom maintenance is
`retrom/gb6c6d52d8d63`. `.github/rpg-runtime/test-native.sh /absolute/scratch`
compiles the actual Renegade driver, video registration and MAME serializer. It
saves nondefault scroll, ROM bank, MCU transaction and interrupt state, discards
the registry, starts a new registry and maps a different ROM allocation, then
checks restoration and the next IRQ/NMI. Only hardware/frontend dependencies
are stubbed. No ROM is needed. The test fails on the upstream missing state.

The fix registers the driver's mutable machine state, including the background
scroll register responsible for missing streets after a cold restore. ROM bank
pointers are reconstructed after load. Bootleg family drivers also register state.
The core's existing state container remains authoritative; no frontend timing
workaround or compatibility reader is added.

Run `make pfb-core-build PFB=<name> CORE=mame2003` from the workspace root.
The candidate recipe runs the native regression, archives only source paths,
and builds with the pinned Emscripten image and EmulatorJS RetroArch linker in
`retrom-fork.json`. It produces `mame2003-wasm.data`, `LICENSE.md`,
`source.tar.gz` and `retrom-core-candidate.json`. All drivers remain enabled.
The internal `path_basedir` declaration and implementation use the length return
value of the pinned frontend library, so static Web linking has one C ABI.
The core owns its CHD implementation, so the frontend CHD reader is disabled
to avoid duplicate symbols; core driver CHD support is retained.
No game files or external BIOS downloads are included. Runtime only consumes
these artifacts. A real published game, public save, fresh cookies-only browser
restore and continued direction/confirm input are required before release.

The workflow verifies PRs into the maintenance branch. Annotated
`retrom-core-gb6c6d52d8d63-rN[-rc.N]` tags build immutable release assets and
`rpg-runtime-release.json`. The Web core uses the single-threaded EmulatorJS
loader; supported content uses `.zip` archives.
