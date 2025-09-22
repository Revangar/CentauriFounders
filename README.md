# Aster Miners: Riftfall

Aster Miners: Riftfall is a Metal-powered, mining-themed horde-survivor roguelite built for iOS 17+. The project targets Swift 6 and Metal 4, featuring an ECS-driven engine, GPU particle systems, destructible crystal buffs, and bilingual English/Russian localization.

## Features
- Procedurally generated arenas with crystal buffs influencing heat/light and spawn pacing.
- Auto-shooter combat with multiple weapon archetypes, deployables, and dynamic bosses.
- Upgrade draft system with weighted synergies, meta progression, and blueprint crafting.
- Touch controls with dual virtual sticks, dash/mine actions, haptics, and debug shortcuts.
- Metal renderer with instanced meshes, compute-driven particles, and bloom post processing.
- Runtime language switching (EN/RU) via localized resources and tests ensuring parity.
- Save system with checksum validation and user-configurable quality options.

All content in this repository is original programmer art/audio. No third-party IP is included.

## Requirements
- Xcode 15.4+ (iOS 17 SDK, Swift 6 toolchain)
- iOS 17.0 simulator or device with Metal support

## Building & Running
1. Open `AsterMiners.xcodeproj` in Xcode.
2. Select the **AsterMiners** scheme and an iOS 17+ device or simulator.
3. Build and run (`⌘R`).

## Controls & Debug
- **Left stick:** movement
- **Right stick:** aim (supports auto-aim toggle in Settings)
- **Buttons:** Dash, Mine, Interact, Pause, Extract
- **Long-press FPS label:** open debug menu with `grantCurrency`, `spawnBoss`, and `rerollUpgrades` commands

## Tests
Run unit tests with `⌘U` or via the `AsterMinersTests` scheme to verify save/load integrity, RNG reproducibility, and localization key coverage.

## Project Layout
```
AsterMiners/
  App/                 UIApplication + entry points
  Engine/              ECS core, systems, rendering, assets
  Game/                Content configs, localization, gameplay factories
  UI/                  SwiftUI menus and in-game HUD overlays
  Resources/           Metal shaders and shared assets
  Tests/               Unit tests and test Info.plist
```

## Legal
All gameplay code, configurations, text, and placeholder art/audio were authored for this project. No trademarks or copyrighted assets from third parties are used.
