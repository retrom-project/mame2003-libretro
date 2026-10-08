# Retrom mame2003 fork

This repository owns the native core and its reproducible Web artifacts. Read
`retrom-fork.json` and `.github/rpg-runtime/README.md` before changing it.

- Upstream baseline: `b6c6d52d8d630d1a172b6b771443dcbbdb45b76d` from EmulatorJS/mame2003-libretro.
- Keep `master` as an upstream mirror. Retrom maintenance belongs to
  `retrom/gb6c6d52d8d63`; use a feature/fix branch for development.
- Build in the named PFB core checkout. Runtime consumes artifacts only; it must
  not compile or patch this core.
- Run `.github/rpg-runtime/test-native.sh /absolute/existing/scratch-directory`
  and `git diff --check` for driver/state changes. Run the explicit PFB candidate
  build and real fresh-browser save/restore/input validation before release.
- Keep ROMs, saves, credentials, generated binaries and build output out of Git.
- Release from an annotated `retrom-core-gb6c6d52d8d63-rN` tag after product
  validation; keep the immutable release descriptor and license with the assets.
