# Choruskeeper

Choruskeeper is a cosy, offline-first iOS collection game about restoring music to a chain of floating islands. Cadents are living sounds—not dragons—and each one changes the ecology around it as your bond grows.

## The game loop

- **Restore melodies:** Replay visual tone sequences across 12 levels and four distinct islands.
- **Harmonise Cadents:** Combine fragments earned from levels. Results follow understandable recipes, with a guaranteed fabled discovery cadence.
- **Build bonds:** Spend ordinary play-earned sparks to deepen each Cadent's bond and reveal its lore.
- **Return gently:** Three daily goals and a community-event model reward regular play without streak loss, premium currency, energy, advertisements, or paid timers.

## Lore

The floating Aerialith once held itself together through the Grand Chorus. When a shard of soundless glass struck its central bell, the islands drifted apart and their natural voices condensed into hidden creatures called Cadents. The player is the newest Choruskeeper, travelling from Bellmeadow to the Gale Observatory to teach the islands their own songs again.

## Run and validate

Open `Choruskeeper.xcodeproj` in Xcode and run the Choruskeeper scheme on an iPhone running iOS 17 or later. Do not open the repository folder or `Package.swift` as the Xcode workspace: that selects the `ChoruskeeperCore` library package, which has no publishable app product or App Store name.

```sh
swift test
xcodebuild -project Choruskeeper.xcodeproj -scheme Choruskeeper -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build
```

The event layer is protocol-based. The checked-in build uses a deterministic preview event so the app remains fully playable offline; swap `PreviewEventProvider` for `RemoteEventProvider` after configuring a production endpoint and trust model.

## Original assets

The background, five Cadent illustrations, and app icon were generated specifically for this project with the built-in image generation workflow. They are stored as named sets under `Choruskeeper/Resources/Assets.xcassets`.
