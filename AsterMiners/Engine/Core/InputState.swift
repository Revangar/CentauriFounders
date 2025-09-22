import CoreGraphics

struct VirtualJoystick {
    var isActive: Bool = false
    var vector: CGVector = .zero
    var radius: CGFloat = 64

    mutating func update(with touchPoint: CGPoint?, origin: CGPoint) {
        guard let point = touchPoint else {
            isActive = false
            vector = .zero
            return
        }
        let dx = point.x - origin.x
        let dy = point.y - origin.y
        let length = max(sqrt(dx * dx + dy * dy), 0.0001)
        let normalized = CGVector(dx: dx / length, dy: dy / length)
        isActive = true
        vector = CGVector(dx: normalized.dx, dy: normalized.dy)
    }
}

struct InputState {
    var movementStick = VirtualJoystick()
    var aimStick = VirtualJoystick()
    var dashPressed = false
    var minePressed = false
    var interactPressed = false
    var autoAimEnabled = true
}
