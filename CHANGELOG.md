# Changelog

## 0.5.0 - 2026-08-16

### Added

- Manual world-record loading from the Current Ghosts list.
- A world-record marker for loaded world-record ghosts.
- Always-visible replay exit and reset controls.
- Delayed tooltips for playback controls.
- Compatibility support for game version `2026-02-02_17_51`.

### Changed

- Improved playback timeline seeking, including forward seeking and a range based on the longest loaded ghost.
- Improved first-spectate camera initialization.
- Made saving current ghosts use the cached record flow.
- Corrected the ghost-opacity control for loaded ghosts.

### Build

- Release packages are copied to the configured Openplanet plugins directory.