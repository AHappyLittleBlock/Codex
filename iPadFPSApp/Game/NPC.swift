import SceneKit

class NPC {
    var node: SCNNode

    init(position: SCNVector3) {
        node = SCNNode(geometry: SCNSphere(radius: 0.3))
        node.position = position
    }

    func move(to destination: SCNVector3) {
        let moveAction = SCNAction.move(to: destination, duration: 2.0)
        node.runAction(moveAction)
    }
}
