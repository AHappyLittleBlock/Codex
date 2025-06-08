# Road Trip Simulator Skeleton

This folder contains a minimal SpriteKit-based example of an endless road trip simulator for iPad. The project now features simple fuel, hunger, and rest mechanics along with obstacles. It cycles from day to night and includes a basic score based on distance travelled. The scene now starts with a "Tap to Start" prompt and shows a "Game Over" message when you run out of health, fuel, hunger, or rest. Biomes change colour as you drive further.

**Note:** This is still only a starting point. A full game would require additional code for proper physics, better UI, saving, and more content.

## Files
- `App/AppDelegate.swift` – Application setup.
- `App/SceneDelegate.swift` – Creates the main window and shows `GameViewController`.
- `Game/GameViewController.swift` – Hosts a `SKView` and displays the scene.
- `Game/GameScene.swift` – Handles the day/night cycle, basic stats bars, and spawns obstacles and animals.
