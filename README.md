# iOS 重力感应物理相册 (iosphoto)

这是一个基于 SwiftUI + SpriteKit 实现的带重力感应的物理动画 App。

### 🌟 核心功能
1. **真实物理模拟**：利用 SpriteKit 物理引擎，头像具有碰撞、弹性和摩擦力。
2. **重力感应 (CoreMotion)**：实时读取设备传感器，手机旋转时，物理世界的重力方向随之改变，头像会像在玻璃盒子里一样滚动。
3. **头像导入与提取**：支持从相册选择图片，自动提取人脸头像（若未识别到人脸则中心裁剪），生成滚动方块。
4. **多头像追加**：支持一次多选和多次追加，已添加的头像会持续保留在场景中参与碰撞。
5. **互动反馈**：
    - 点击屏幕时，周围的头像会受到冲击力弹开。
    - 沉浸式 UI 设计，隐藏状态栏和导航条。

### 📂 文件说明
- `GravityScene.swift`: 物理模拟逻辑的核心，管理 `SKPhysicsBody` 和 `CMMotionManager`。
- `ContentView.swift`: SwiftUI 视图，承载 SpriteKit 场景。
- `IOSPhotoApp.swift`: 应用入口。
- `GravityWidget.swift`: 锁屏小组件实现（圆形、长方形、行内）。
- `project.yml`: XcodeGen 工程定义（App + Widget）。
- `scripts/build_ios.sh`: 本地/CI 通用构建与 IPA 打包脚本。
- `.github/workflows/ios-build.yml`: GitHub Actions 构建与发布流程。

### 🚀 本地构建 (Mac + Xcode)
1. 安装 XcodeGen：`brew install xcodegen`
2. 生成工程：`xcodegen generate --spec project.yml`
3. 一键构建并打包 IPA：`./scripts/build_ios.sh`
4. 构建产物：
    - App: `build/DerivedData/Build/Products/Release-iphoneos/iosphoto.app`
    - IPA: `build/iosphoto-unsigned.ipa`

说明：
- 当前 CI/脚本产物为 **unsigned IPA**（无签名）。
- 真机完整安装仍需你自己的证书与签名流程。

### 🛠️ 小组件配置与测试
`GravityWidget` 已内置在 `project.yml` 中，不需要手工再加 Target。

真机测试步骤：
- 使用 Xcode 打开 `iosphoto.xcodeproj`（由 XcodeGen 生成）。
- 在 iPhone 上运行 App 至少一次。
- 锁定屏幕 -> 长按锁屏 -> 点击“自定” -> 选择“锁定屏幕”。
- 点击“添加小组件” -> 在列表中找到 `iosphoto`。
- 可见三种样式组件：**圆形、长方形、顶部文字行**。

要求：
- iOS 16.0+
- **必须在真机** 才能体验重力感应；模拟器仅能测试点击交互。

### 🤖 GitHub Actions 自动编译
Workflow：`.github/workflows/ios-build.yml`

自动触发条件（`main`）：
- `Sources/**/*.swift`
- `Config/**`
- `project.yml`
- `scripts/build_ios.sh`
- `.github/workflows/ios-build.yml`

流程包含：
- XcodeGen 生成工程
- `xcodebuild` Release 无签名构建
- 打包 `build/iosphoto-unsigned.ipa`
- 上传 Actions Artifact
- 发布到 GitHub Release（tag：`iosphoto-ci-latest`）

### 📦 Release 产物
- Release 名称：`iosphoto CI latest`
- Tag：`iosphoto-ci-latest`
- 文件：`IOSPHOTO.ipa`

每次 `main` 上触发构建后会自动更新该 Release。

### 📚 SideStore 源
- 源文件：`apps.json`
- 源地址：`https://raw.githubusercontent.com/QQ-War/IOSPHOTO/main/apps.json`
- IPA 下载地址（JSON 内）：`https://github.com/QQ-War/IOSPHOTO/releases/download/iosphoto-ci-latest/IOSPHOTO.ipa`

添加方法：
1. 在 SideStore 打开 `Sources`
2. 点击 `+`
3. 输入上面的源地址并添加

### 🔍 最终体验
由于锁屏界面的电池优化，系统不允许在小组件内直接运行实时物理引擎。

当点击锁屏小组件时：
1. 通过 URL Scheme 拉起 App。
2. App 打开后 `GravityScene` 被激活。
3. 头像会随重力感应开始滚动，形成“从锁屏坠入重力世界”的体验。

### 🛠️ 进阶玩法
- **真实头像**：将 `SKShapeNode` 替换为 `SKSpriteNode(imageNamed: "avatar")` 即可使用真实图片。
- **碰撞音效**：在 `SKPhysicsContactDelegate` 的回调中播放音效。
- **碰撞震动**：使用 `UIImpactFeedbackGenerator` 实现细腻的碰撞触觉反馈。
