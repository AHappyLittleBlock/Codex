import SceneKit
import UIKit

class GameScene: NSObject, SCNSceneRendererDelegate {
    enum Phase { case ready, jumping, playing, gameOver }

    let scnView: SCNView
    let messageLabel: UILabel
    let healthBar: UIProgressView
    let scene: SCNScene

    private var cameraNode = SCNNode()
    private var helicopter = SCNNode()
    private var playerNode = SCNNode()
    private var npcs: [NPC] = []
    private var enemies: [SCNNode] = []
    private var lastSpawn: TimeInterval = 0
    private var health: Float = 1

    private var phase: Phase = .ready

    init(view: SCNView, messageLabel: UILabel, healthBar: UIProgressView) {
        self.scnView = view
        self.messageLabel = messageLabel
        self.healthBar = healthBar
        scene = SCNScene()
        super.init()

        setupScene()
        scnView.scene = scene
        scnView.delegate = self
    }

    private func setupScene() {
        // Camera starts in helicopter
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 10, 0)
        scene.rootNode.addChildNode(cameraNode)

        helicopter = SCNNode(geometry: SCNBox(width: 2, height: 0.5, length: 4, chamferRadius: 0))
        helicopter.position = SCNVector3(0, 10, 0)
        scene.rootNode.addChildNode(helicopter)

        let ground = SCNNode(geometry: SCNFloor())
        ground.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(ground)

        playerNode.physicsBody = SCNPhysicsBody(type: .kinematic,
                                               shape: SCNPhysicsShape(geometry: SCNSphere(radius: 0.3),
                                                                       options: nil))
        scene.rootNode.addChildNode(playerNode)

        messageLabel.text = "Tap to Jump"
    }

    // MARK: - Input
    func handleTap() {
        switch phase {
        case .ready:
            startGame()
        case .jumping:
            break
        case .playing:
            shoot()
        case .gameOver:
            reset()
        }
    }

    // MARK: - Game Flow
    private func startGame() {
        phase = .jumping
        let drop = SCNAction.move(to: SCNVector3(0, 1.6, 0), duration: 2.0)
        cameraNode.runAction(drop) { [weak self] in
            self?.beginPlaying()
        }
    }

    private func beginPlaying() {
        phase = .playing
        messageLabel.text = "Tap to Shoot"
        spawnNPCs()
    }

    private func reset() {
        for e in enemies { e.removeFromParent() }
        enemies.removeAll()
        for npc in npcs { npc.node.removeFromParent() }
        npcs.removeAll()
        cameraNode.position = SCNVector3(0, 10, 0)
        playerNode.position = cameraNode.position
        health = 1
        healthBar.progress = 1
        phase = .ready
        messageLabel.text = "Tap to Jump"
    }

    private func win() {
        phase = .gameOver
        messageLabel.text = "You Win! Tap to Restart"
    }

    // MARK: - Spawning
    private func spawnNPCs() {
        for i in 0..<3 {
            let npc = NPC(position: SCNVector3(Float(i) - 1, 0, -2))
            scene.rootNode.addChildNode(npc.node)
            npcs.append(npc)
        }
    }

    private func spawnEnemy() {
        let enemy = SCNNode(geometry: SCNSphere(radius: 0.3))
        enemy.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        enemy.position = SCNVector3(Float.random(in: -5...5), 0, Float.random(in: -10...-5))
        enemy.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        scene.rootNode.addChildNode(enemy)
        enemies.append(enemy)
    }

    private func shoot() {
        let origin = cameraNode.presentation.worldPosition
        let dir = cameraNode.presentation.worldFront
        let end = origin + dir * 20
        let hits = scene.physicsWorld.rayTest(withSegmentFrom: origin, to: end, options: nil)
        if let first = hits.first, enemies.contains(first.node) {
            first.node.removeFromParent()
            enemies.removeAll { $0 == first.node }
            if enemies.isEmpty { win() }
        }
    }

    private func takeDamage() {
        health -= 0.2
        healthBar.progress = health
        if health <= 0 {
            phase = .gameOver
            messageLabel.text = "Game Over - Tap"
        }
    }

    // MARK: - SCNSceneRendererDelegate
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard phase == .playing else { return }
        if time - lastSpawn > 2, enemies.count < 5 {
            spawnEnemy()
            lastSpawn = time
        }

        let playerPos = cameraNode.presentation.worldPosition
        playerNode.position = playerPos

        for npc in npcs { npc.follow(target: playerNode) }

        for enemy in enemies {
            let dir = (playerPos - enemy.position).normalized() * 0.02
            enemy.position += dir
            if (enemy.position - playerPos).length() < 0.5 {
                enemy.removeFromParent()
                enemies.removeAll { $0 == enemy }
                takeDamage()
            }
        }
    }
}

// MARK: - Vector Helpers
fileprivate func + (lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
    return SCNVector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
}

fileprivate func - (lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
    return SCNVector3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
}

fileprivate func * (vector: SCNVector3, scalar: Float) -> SCNVector3 {
    return SCNVector3(vector.x * scalar, vector.y * scalar, vector.z * scalar)
}

extension SCNVector3 {
    func length() -> Float {
        return sqrtf(x*x + y*y + z*z)
    }

    func normalized() -> SCNVector3 {
        let len = length()
        guard len > 0 else { return self }
        return self * (1/len)
    }
}
