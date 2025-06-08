# SwiftFPSGame Skeleton

This folder now contains a very simple first-person shooter example for iPad built with Swift and SceneKit. The player begins in a helicopter, taps to jump down and then shoots red enemy spheres while three NPC teammates follow along. A small health bar shows damage taken and the game ends in victory when all enemies are gone or in defeat if your health reaches zero.

**Note:** This code is intentionally lightweight and lacks advanced input, graphics or networking. It simply demonstrates one way to structure a basic playable scene on iPad.

## Files

- `iPadFPSApp/App/AppDelegate.swift` – Application setup.
- `iPadFPSApp/App/SceneDelegate.swift` – Creates the main window and sets `GameViewController`.
- `iPadFPSApp/Game/GameViewController.swift` – Hosts a `SCNView`, overlays simple UI and forwards taps to the scene.
- `iPadFPSApp/Game/GameScene.swift` – Handles jumping from the helicopter, enemy spawning, shooting and win/lose logic.
- `iPadFPSApp/Game/NPC.swift` – Very small class for teammate movement.

To build a complete game you would need to add input controls, physics, enemy AI, networking, graphics, and a large amount of custom gameplay code.
