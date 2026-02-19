import SwiftUI
import SpriteKit

struct ContentView: View {
    var scene: SKScene {
        let scene = GravityScene()
        // 设置场景大小为当前主屏幕的大小
        let screenSize = UIScreen.main.bounds.size
        scene.size = CGSize(width: screenSize.width, height: screenSize.height)
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .black
        return scene
    }
    
    var body: some View {
        ZStack {
            // 在 SwiftUI 中承载 SpriteKit 场景
            SpriteView(scene: scene)
                .edgesIgnoringSafeArea(.all)
                .statusBar(hidden: true)
                .persistentSystemOverlays(.hidden) // 沉浸式体验：隐藏底部横条
            
            // 可选：添加 UI 层（例如提示文字或重置按钮）
            VStack {
                Text("旋转手机试试！")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.top, 50)
                Spacer()
                Text("点击屏幕头像会跳开")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.bottom, 30)
            }
            .allowsHitTesting(false) // 确保 UI 不会拦截物理交互的点击
        }
    }
}
