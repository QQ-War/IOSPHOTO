import SpriteKit
import CoreMotion
import UIKit

final class GravityScene: SKScene {
    private let motionManager = CMMotionManager()
    private var hasSeededDefaultAvatars = false

    override func didMove(to view: SKView) {
        configurePhysicsBounds()
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        startMotionUpdatesIfNeeded()

        if !hasSeededDefaultAvatars {
            addPlaceholderAvatars(count: 12)
            hasSeededDefaultAvatars = true
        }
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        configurePhysicsBounds()
    }

    deinit {
        motionManager.stopDeviceMotionUpdates()
    }

    func addAvatarImages(_ images: [UIImage]) {
        guard !images.isEmpty else { return }

        for image in images {
            let side = CGFloat.random(in: 68...104)
            let texture = SKTexture(image: image)
            let node = SKSpriteNode(texture: texture, size: CGSize(width: side, height: side))
            node.name = "avatar"
            node.position = randomSpawnPosition(halfExtent: side / 2)
            node.zRotation = CGFloat.random(in: -0.4...0.4)

            let body = SKPhysicsBody(rectangleOf: node.size)
            body.restitution = 0.72
            body.friction = 0.35
            body.linearDamping = 0.08
            body.angularDamping = 0.12
            body.allowsRotation = true
            node.physicsBody = body

            // Thin border to make blocks clearer on dark background.
            let border = SKShapeNode(rectOf: node.size, cornerRadius: 6)
            border.strokeColor = .white.withAlphaComponent(0.55)
            border.lineWidth = 2
            border.zPosition = 1
            node.addChild(border)

            addChild(node)
        }
    }

    private func addPlaceholderAvatars(count: Int) {
        let colors: [UIColor] = [.systemPink, .systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemYellow, .systemCyan]

        for index in 0..<count {
            let side = CGFloat.random(in: 64...96)
            let node = SKSpriteNode(color: colors[index % colors.count], size: CGSize(width: side, height: side))
            node.name = "avatar"
            node.position = randomSpawnPosition(halfExtent: side / 2)
            node.zRotation = CGFloat.random(in: -0.3...0.3)

            let body = SKPhysicsBody(rectangleOf: node.size)
            body.restitution = 0.72
            body.friction = 0.35
            body.linearDamping = 0.08
            body.angularDamping = 0.12
            body.allowsRotation = true
            node.physicsBody = body

            let border = SKShapeNode(rectOf: node.size, cornerRadius: 6)
            border.strokeColor = .white.withAlphaComponent(0.55)
            border.lineWidth = 2
            border.zPosition = 1
            node.addChild(border)

            addChild(node)
        }
    }

    private func configurePhysicsBounds() {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }

    private func startMotionUpdatesIfNeeded() {
        guard motionManager.isDeviceMotionAvailable else { return }
        guard motionManager.isDeviceMotionActive == false else { return }

        motionManager.deviceMotionUpdateInterval = 1 / 60
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let motion else { return }
            self?.physicsWorld.gravity = CGVector(
                dx: motion.gravity.x * 12.0,
                dy: motion.gravity.y * 12.0
            )
        }
    }

    private func randomSpawnPosition(halfExtent: CGFloat) -> CGPoint {
        let minX = halfExtent
        let maxX = max(minX + 1, frame.width - halfExtent)
        let minY = halfExtent
        let maxY = max(minY + 1, frame.height - halfExtent)

        let x = CGFloat.random(in: minX...maxX)
        let y = CGFloat.random(in: minY...maxY)
        return CGPoint(x: x, y: y)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        for node in children {
            guard let body = node.physicsBody else { continue }

            let dx = node.position.x - location.x
            let dy = node.position.y - location.y
            let distance = sqrt(dx * dx + dy * dy)

            if distance < 220 {
                let force: CGFloat = 1100 / (distance + 1)
                body.applyImpulse(CGVector(dx: dx * force, dy: dy * force))
            }
        }
    }
}
