import SceneKit

class GameScene {
    static func createScene() -> SCNScene {
        let scene = SCNScene()

        // Camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 1.6, 0)
        scene.rootNode.addChildNode(cameraNode)

        // Placeholder helicopter the player jumps from
        let helicopter = SCNNode(geometry: SCNBox(width: 2, height: 0.5, length: 4, chamferRadius: 0))
        helicopter.position = SCNVector3(0, 10, 0)
        scene.rootNode.addChildNode(helicopter)

        // Simple ground
        let ground = SCNNode(geometry: SCNFloor())
        scene.rootNode.addChildNode(ground)

        return scene
    }
}
