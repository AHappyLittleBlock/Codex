# Road Trip Simulator Skeleton

This folder contains a minimal SpriteKit-based example of an endless road trip simulator for iPad. The project now features fuel, hunger, rest and health bars, random obstacles, fuel pumps and rest stops. Animals appear at night and collisions reduce health. Biomes cycle colours as distance increases. A start screen appears on launch and the game ends with a summary of distance travelled.

**Note:** This is still only a starting point. A full game would require additional code for proper physics, better UI, saving, and more content.

## Files
- `App/AppDelegate.swift` – Application setup.
- `App/SceneDelegate.swift` – Creates the main window and shows `GameViewController`.
- `Game/GameViewController.swift` – Hosts a `SKView` and displays the scene.
- `Game/GameScene.swift` – Handles the day/night cycle, basic stats bars, and spawns obstacles and animals.
