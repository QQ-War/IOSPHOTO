# iOS 重力感应物理相册 (iosphoto)

这是一个基于 SwiftUI + SpriteKit 实现的带重力感应的物理动画 App。

### 🌟 核心功能
1. **真实物理模拟**：利用 SpriteKit 物理引擎，头像具有碰撞、弹性和摩擦力。
2. **重力感应 (CoreMotion)**：实时读取设备传感器，手机旋转时，物理世界的重力方向随之改变，头像会像在玻璃盒子里一样滚动。
3. **互动反馈**：
    - 点击屏幕时，周围的头像会受到冲击力弹开。
    - 沉浸式 UI 设计，隐藏状态栏和导航条。

### 📂 文件说明
- `GravityScene.swift`: 物理模拟逻辑的核心，管理 `SKPhysicsBody` 和 `CMMotionManager`。
- `ContentView.swift`: SwiftUI 视图，承载 SpriteKit 场景。
- `IOSPhotoApp.swift`: 应用入口。

### 🚀 如何运行 (Mac + Xcode)
1. **创建项目**：在 Xcode 中创建一个新的 iOS 项目 (File -> New -> Project)。
2. **选择模板**：选择 **App**，Interface 选择 **SwiftUI**，Language 选择 **Swift**。
3. **导入文件**：将本项目 `Sources/iosphoto/` 目录下的所有 `.swift` 文件拖入你的 Xcode 项目。
4. **添加权限**：在 `Info.plist` 中添加以下权限说明（如果需要更高级的传感器数据）：
    - `Privacy - Motion Usage Description`: 用于读取手机重力感应数据实现头像滚动效果。
5. **真机运行**：
    - **必须在真机（iPhone/iPad）上运行**才能看到重力感应效果。
    - 模拟器无法模拟真实的重力倾斜，只能通过点击产生动力。

### 🛠️ 在 Xcode 中配置小组件 (Mac)
1. **添加新 Target**：
    - 在 Xcode 中，点击顶部菜单 `File -> New -> Target`。
    - 搜索并选择 **Widget Extension**。
    - 名字填入 `GravityWidget`（注意：**不要勾选** `Include Configuration Intent`）。
2. **导入代码**：
    - Xcode 会自动生成一些默认代码。
    - 删除自动生成的 `GravityWidget.swift` 内容。
    - 将本项目中的 `Sources/iosphoto/GravityWidget.swift` 内容全部粘贴进去。
3. **设置 `Info.plist`**：
    - 锁屏小组件需要 iOS 16+，确保 Deployment Target 设置为 iOS 16.0 或更高版本。
4. **运行与测试**：
    - 在 iPhone 上运行 App 至少一次。
    - 锁定屏幕 -> 长按锁屏 -> 点击“自定” -> 选择“锁定屏幕”。
    - 点击“添加小组件” -> 在列表中找到你的 `iosphoto` 应用。
    - 你会看到三种样式组件：**圆形、长方形、顶部文字行**。

### 🚀 最终效果
由于锁屏界面的电池优化，系统不允许在小组件内直接运行实时物理引擎。

当点击锁屏小组件时：
1. 通过 URL Scheme 拉起 App。
2. App 打开后 `GravityScene` 被激活。
3. 头像会随重力感应开始滚动，形成“从锁屏坠入重力世界”的体验。

### 🛠️ 进阶玩法
- **真实头像**：将 `SKShapeNode` 替换为 `SKSpriteNode(imageNamed: "avatar")` 即可使用真实图片。
- **碰撞音效**：在 `SKPhysicsContactDelegate` 的回调中播放音效。
- **碰撞震动**：使用 `UIImpactFeedbackGenerator` 实现细腻的碰撞触觉反馈。
