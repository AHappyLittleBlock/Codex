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

    func follow(target: SCNNode) {
        let dest = target.presentation.worldPosition
        let dir = (dest - node.position).normalized() * 0.01
        node.position += dir
    }
}

// Minimal vector helpers
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
    func length() -> Float { sqrtf(x*x + y*y + z*z) }
    func normalized() -> SCNVector3 {
        let l = length()
        return l > 0 ? self * (1/l) : self
    }
}
