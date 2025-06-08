import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    private enum PhysicsCategory {
        static let car: UInt32 = 0x1 << 0
        static let obstacle: UInt32 = 0x1 << 1
        static let fuel: UInt32 = 0x1 << 2
        static let rest: UInt32 = 0x1 << 3
        static let animal: UInt32 = 0x1 << 4
    }

    private enum GamePhase {
        case ready, playing, gameOver
    }

    private var car: SKSpriteNode!
    private var road: SKSpriteNode!
    private var roadWidth: CGFloat = 0
    private var roadLeft: CGFloat { (size.width - roadWidth) / 2 }
    private var roadRight: CGFloat { size.width - roadLeft }
    private var timeOfDay: CGFloat = 0.0 // 0 = day, 1 = night

    private var phase: GamePhase = .ready
    private var messageLabel: SKLabelNode!
    private var distanceLabel: SKLabelNode!
    private var distance: CGFloat = 0
    private var lastUpdate: TimeInterval = 0
    private let biomes: [SKColor] = [.darkGray, .green, .yellow]

    private var fuelBar: SKSpriteNode!
    private var hungerBar: SKSpriteNode!
    private var restBar: SKSpriteNode!
    private var healthBar: SKSpriteNode!

    private var fuel: CGFloat = 1
    private var hunger: CGFloat = 1
    private var rest: CGFloat = 1
    private var health: CGFloat = 1

    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundColor = .cyan
        setupRoad()
        setupCar()
        setupUI()
        phase = .ready
        messageLabel = SKLabelNode(text: "Tap to Start")
        messageLabel.fontSize = 32
        messageLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(messageLabel)
        distanceLabel = SKLabelNode(text: "0m")
        distanceLabel.fontSize = 20
        distanceLabel.horizontalAlignmentMode = .right
        distanceLabel.position = CGPoint(x: size.width - 20, y: size.height - 20)
        addChild(distanceLabel)
        run(dayNightCycle())
    }

    func setupRoad() {
        roadWidth = size.width * 0.6
        road = SKSpriteNode(color: .darkGray,
                            size: CGSize(width: roadWidth, height: size.height))
        road.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        road.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(road)
    }

    func setupCar() {
        car = SKSpriteNode(color: .red, size: CGSize(width: 40, height: 80))
        car.position = CGPoint(x: size.width/2, y: 100)
        car.physicsBody = SKPhysicsBody(rectangleOf: car.size)
        car.physicsBody?.isDynamic = true
        car.physicsBody?.allowsRotation = false
        car.physicsBody?.categoryBitMask = PhysicsCategory.car
        car.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle |
            PhysicsCategory.fuel | PhysicsCategory.rest | PhysicsCategory.animal
        addChild(car)
    }

    func setupUI() {
        let barWidth = size.width * 0.2
        fuelBar = SKSpriteNode(color: .green, size: CGSize(width: barWidth, height: 8))
        fuelBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        fuelBar.position = CGPoint(x: 20, y: size.height - 20)
        addChild(fuelBar)

        hungerBar = SKSpriteNode(color: .orange, size: CGSize(width: barWidth, height: 8))
        hungerBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        hungerBar.position = CGPoint(x: 20, y: size.height - 35)
        addChild(hungerBar)

        restBar = SKSpriteNode(color: .blue, size: CGSize(width: barWidth, height: 8))
        restBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        restBar.position = CGPoint(x: 20, y: size.height - 50)
        addChild(restBar)

        healthBar = SKSpriteNode(color: .red, size: CGSize(width: barWidth, height: 8))
        healthBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        healthBar.position = CGPoint(x: 20, y: size.height - 65)
        addChild(healthBar)
    }

    func startGame() {
        phase = .playing
        messageLabel.isHidden = true
        fuel = 1
        hunger = 1
        rest = 1
        health = 1
        distance = 0
        distanceLabel.text = "0m"
        isPaused = false
        run(dayNightCycle())
        run(spawnAnimals())
        run(spawnObstacles())
        run(spawnFuelStations())
        run(spawnRestStops())
    }

    func showGameOver() {
        phase = .gameOver
        removeAllActions()
        messageLabel.text = "Game Over - Tap" + "\nDistance: \(Int(distance))m"
        messageLabel.numberOfLines = 2
        messageLabel.isHidden = false
        isPaused = true
    }

    func dayNightCycle() -> SKAction {
        let duration: TimeInterval = 10.0
        let toNight = SKAction.customAction(withDuration: duration) { [weak self] node, elapsed in
            self?.timeOfDay = elapsed / CGFloat(duration)
            self?.backgroundColor = SKColor(red: 1 - self!.timeOfDay * 0.5,
                                             green: 1 - self!.timeOfDay * 0.5,
                                             blue: 1,
                                             alpha: 1)
        }
        let toDay = SKAction.customAction(withDuration: duration) { [weak self] node, elapsed in
            self?.timeOfDay = 1 - elapsed / CGFloat(duration)
            self?.backgroundColor = SKColor(red: 0.5 + self!.timeOfDay * 0.5,
                                             green: 0.5 + self!.timeOfDay * 0.5,
                                             blue: 1,
                                             alpha: 1)
        }
        return SKAction.repeatForever(SKAction.sequence([toNight, toDay]))
    }

    func spawnAnimals() -> SKAction {
        let wait = SKAction.wait(forDuration: 2.0)
        let spawn = SKAction.run { [weak self] in
            guard let self = self else { return }
            if self.timeOfDay > 0.5 { // only at night
                let animal = SKSpriteNode(color: .brown, size: CGSize(width: 30, height: 30))
                animal.position = CGPoint(x: CGFloat.random(in: self.roadLeft+20...self.roadRight-20),
                                          y: self.size.height + 20)
                animal.physicsBody = SKPhysicsBody(rectangleOf: animal.size)
                animal.physicsBody?.isDynamic = false
                animal.physicsBody?.categoryBitMask = PhysicsCategory.animal
                animal.physicsBody?.contactTestBitMask = PhysicsCategory.car
                self.addChild(animal)
                let move = SKAction.moveBy(x: 0, y: -self.size.height-40, duration: 5)
                let remove = SKAction.removeFromParent()
                animal.run(SKAction.sequence([move, remove]))
            }
        }
        return SKAction.repeatForever(SKAction.sequence([wait, spawn]))
    }

    func spawnObstacles() -> SKAction {
        let wait = SKAction.wait(forDuration: 1.5)
        let spawn = SKAction.run { [weak self] in
            guard let self = self else { return }
            let obstacle = SKSpriteNode(color: .gray, size: CGSize(width: 40, height: 40))
            obstacle.position = CGPoint(x: CGFloat.random(in: self.roadLeft+20...self.roadRight-20),
                                         y: self.size.height + 20)
            obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
            obstacle.physicsBody?.isDynamic = false
            obstacle.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
            obstacle.physicsBody?.contactTestBitMask = PhysicsCategory.car
            self.addChild(obstacle)
            let move = SKAction.moveBy(x: 0, y: -self.size.height-40, duration: 4)
            let remove = SKAction.removeFromParent()
            obstacle.run(SKAction.sequence([move, remove]))
        }
        return SKAction.repeatForever(SKAction.sequence([wait, spawn]))
    }

    func spawnFuelStations() -> SKAction {
        let wait = SKAction.wait(forDuration: 8.0)
        let spawn = SKAction.run { [weak self] in
            guard let self = self else { return }
            let pump = SKSpriteNode(color: .green, size: CGSize(width: 30, height: 60))
            pump.position = CGPoint(x: CGFloat.random(in: self.roadLeft+20...self.roadRight-20),
                                     y: self.size.height + 20)
            pump.physicsBody = SKPhysicsBody(rectangleOf: pump.size)
            pump.physicsBody?.isDynamic = false
            pump.physicsBody?.categoryBitMask = PhysicsCategory.fuel
            pump.physicsBody?.contactTestBitMask = PhysicsCategory.car
            self.addChild(pump)
            let move = SKAction.moveBy(x: 0, y: -self.size.height-40, duration: 6)
            let remove = SKAction.removeFromParent()
            pump.run(SKAction.sequence([move, remove]))
        }
        return SKAction.repeatForever(SKAction.sequence([wait, spawn]))
    }

    func spawnRestStops() -> SKAction {
        let wait = SKAction.wait(forDuration: 12.0)
        let spawn = SKAction.run { [weak self] in
            guard let self = self else { return }
            let rest = SKSpriteNode(color: .blue, size: CGSize(width: 50, height: 60))
            rest.position = CGPoint(x: CGFloat.random(in: self.roadLeft+20...self.roadRight-20),
                                     y: self.size.height + 20)
            rest.physicsBody = SKPhysicsBody(rectangleOf: rest.size)
            rest.physicsBody?.isDynamic = false
            rest.physicsBody?.categoryBitMask = PhysicsCategory.rest
            rest.physicsBody?.contactTestBitMask = PhysicsCategory.car
            self.addChild(rest)
            let move = SKAction.moveBy(x: 0, y: -self.size.height-40, duration: 6)
            let remove = SKAction.removeFromParent()
            rest.run(SKAction.sequence([move, remove]))
        }
        return SKAction.repeatForever(SKAction.sequence([wait, spawn]))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch phase {
        case .ready:
            startGame()
        case .gameOver:
            startGame()
        case .playing:
            break
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        car.position.x = max(roadLeft + 20, min(location.x, roadRight - 20))
    }

    override func update(_ currentTime: TimeInterval) {
        let dt = currentTime - lastUpdate
        lastUpdate = currentTime
        guard phase == .playing else { return }
        fuel -= 0.0005
        hunger -= 0.0003
        rest -= 0.0002
        distance += CGFloat(dt * 60)
        distanceLabel.text = "\(Int(distance))m"
        let biomeIndex = Int(distance / 500) % biomes.count
        road.color = biomes[biomeIndex]

        fuelBar.xScale = max(fuel, 0)
        hungerBar.xScale = max(hunger, 0)
        restBar.xScale = max(rest, 0)
        healthBar.xScale = max(health, 0)

        if car.position.x < roadLeft || car.position.x > roadRight {
            health -= 0.01
        }

        if fuel <= 0 || hunger <= 0 || rest <= 0 || health <= 0 {
            showGameOver()
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if mask == PhysicsCategory.car | PhysicsCategory.obstacle ||
            mask == PhysicsCategory.car | PhysicsCategory.animal {
            health -= 0.2
            if health <= 0 { showGameOver() }
        } else if mask == PhysicsCategory.car | PhysicsCategory.fuel {
            fuel = 1
            if contact.bodyA.categoryBitMask == PhysicsCategory.fuel {
                contact.bodyA.node?.removeFromParent()
            } else {
                contact.bodyB.node?.removeFromParent()
            }
        } else if mask == PhysicsCategory.car | PhysicsCategory.rest {
            hunger = 1
            rest = 1
            if contact.bodyA.categoryBitMask == PhysicsCategory.rest {
                contact.bodyA.node?.removeFromParent()
            } else {
                contact.bodyB.node?.removeFromParent()
            }
        }
    }

}
