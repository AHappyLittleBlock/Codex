# SwiftFPSGame Skeleton

This repository contains a skeleton of a first-person shooter game for iPad built with Swift and SceneKit. It demonstrates basic structure for an iOS game app where players jump from a helicopter and cooperate with NPC teammates.

**Note:** This is not a full game. It is a minimal starting point illustrating how you might set up an iPad project with SceneKit.

## Files

- `iPadFPSApp/App/AppDelegate.swift` – Application setup.
- `iPadFPSApp/App/SceneDelegate.swift` – Creates the main window and sets `GameViewController`.
- `iPadFPSApp/Game/GameViewController.swift` – Hosts a `SCNView` and loads the game scene.
- `iPadFPSApp/Game/GameScene.swift` – Generates a basic scene with a helicopter and ground.
- `iPadFPSApp/Game/NPC.swift` – Example NPC class that can move around.

To build a complete game you would need to add input controls, physics, enemy AI, networking, graphics, and a large amount of custom gameplay code.
