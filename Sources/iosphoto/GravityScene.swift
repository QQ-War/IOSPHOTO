import SpriteKit
import CoreMotion
import UIKit

class GravityScene: SKScene {
    let motionManager = CMMotionManager()
    
    override func didMove(to view: SKView) {
        // 1. 设置物理边界（像一个玻璃盒子）
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        
        // 2. 开启陀螺仪更新
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1/60
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
                guard let motion = motion else { return }
                // 实时根据手机姿态旋转重力方向
                // motion.gravity.x 和 y 的范围是 -1 到 1
                self?.physicsWorld.gravity = CGVector(
                    dx: motion.gravity.x * 12.0, 
                    dy: motion.gravity.y * 12.0
                )
            }
        }
        
        // 3. 初始化头像
        addAvatars()
    }
    
    func addAvatars() {
        let colors: [UIColor] = [.systemPink, .systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemYellow, .systemCyan]
        
        for i in 0..<15 {
            let radius = CGFloat.random(in: 25...45)
            // 这里创建圆形的占位节点，实际项目中可以替换为图片
            let avatar = SKShapeNode(circleOfRadius: radius)
            avatar.fillColor = colors[i % colors.count]
            avatar.strokeColor = .white
            avatar.lineWidth = 2
            
            // 随机初始位置
            let x = CGFloat.random(in: radius...frame.width - radius)
            let y = CGFloat.random(in: radius...frame.height - radius)
            avatar.position = CGPoint(x: x, y: y)
            
            // 物理属性配置
            let body = SKPhysicsBody(circleOfRadius: radius)
            body.restitution = 0.8  // 弹性，让碰撞更有趣
            body.friction = 0.3     // 摩擦力
            body.linearDamping = 0.1 // 线性阻尼，模拟空气阻力
            body.angularDamping = 0.1 // 旋转阻尼
            body.allowsRotation = true
            
            avatar.physicsBody = body
            addChild(avatar)
        }
    }
    
    // 交互：点击时产生推力
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        for node in children {
            if let body = node.physicsBody {
                // 计算点击位置到头像的向量，产生推开的效果
                let dx = node.position.x - location.x
                let dy = node.position.y - location.y
                let distance = sqrt(dx*dx + dy*dy)
                
                if distance < 200 {
                    let force: CGFloat = 1000 / (distance + 1)
                    body.applyImpulse(CGVector(dx: dx * force, dy: dy * force))
                }
            }
        }
    }
}
