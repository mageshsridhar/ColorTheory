# Color Theory
An interactive iOS game that teaches the fundamentals of color theory. Each level is a short puzzle: put shuffled colors back in order, then read a quick recap of the idea behind them.

<div align="center">
  <img src="docs/demo.webp" width="300" alt="Opening the Primary Colors level, reading how to play, and swapping color blocks into order" />
</div>

### How to play
Tap an unlocked color, then tap another to swap them. Blocks with a lock stay where they are and act as hints. The level is complete when the colors are arranged to match its objective.

### Levels
**Color Wheel**
- **Primary:** red, yellow and blue.
- **Secondary:** the colors you get by mixing two primaries.
- **Tertiary:** the mix of a primary and a neighboring secondary.
- **Warm:** colors of energy, brightness and action.
- **Cool:** colors of calm and serenity.

**Color Schemes**
- **Complementary:** opposites on the color wheel.
- **Analogous:** neighbors on the color wheel.
- **Triadic:** three colors spaced evenly around the wheel.

### It's all in the details:
- Every level pairs its puzzle with a short explanation, plus a How to Play overlay and a recap when you finish.
- Swaps are animated. Picking a color, swapping it and finishing a level each play their own sound.
- Finishing all eight levels unlocks a final screen where you can start over.

### Tools and Frameworks used:
- SwiftUI
- SpriteKit, shown inside SwiftUI with `SpriteView`
- [GlassMorphismic](https://github.com/taichi-dm/GlassMorphismic) for the blurred overlays

### Requirements
- iOS 14 or later
- Xcode with Swift Package Manager, which fetches GlassMorphismic
