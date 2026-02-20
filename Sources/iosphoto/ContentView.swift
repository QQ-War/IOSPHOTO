import SwiftUI
import SpriteKit
import PhotosUI

struct ContentView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var isImporting = false
    @State private var scene: GravityScene = {
        let screenSize = UIScreen.main.bounds.size
        let scene = GravityScene(size: screenSize)
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .black
        return scene
    }()

    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .statusBar(hidden: true)
                .persistentSystemOverlays(.hidden)

            VStack {
                HStack {
                    PhotosPicker(
                        selection: $selectedItems,
                        maxSelectionCount: 20,
                        matching: .images,
                        preferredItemEncoding: .automatic
                    ) {
                        Label("添加头像", systemImage: "person.crop.square.badge.plus")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                    .disabled(isImporting)

                    if isImporting {
                        ProgressView()
                            .tint(.white)
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 52)

                Spacer()

                VStack(spacing: 8) {
                    Text("旋转手机试试")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.75))

                    Text("从相册提取头像，追加到滚动方块")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.55))

                    Text("点击屏幕可弹开方块")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.45))
                }
                .padding(.bottom, 28)
                .allowsHitTesting(false)
            }
        }
        .onChange(of: selectedItems) { newItems in
            Task {
                await importSelectedItems(newItems)
            }
        }
    }

    private func importSelectedItems(_ items: [PhotosPickerItem]) async {
        guard !items.isEmpty else { return }

        await MainActor.run {
            isImporting = true
        }

        var avatars: [UIImage] = []

        for item in items {
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data)
            else {
                continue
            }

            if let avatar = await FaceAvatarExtractor.extractAvatar(from: image) {
                avatars.append(avatar)
            }
        }

        await MainActor.run {
            scene.addAvatarImages(avatars)
            selectedItems = []
            isImporting = false
        }
    }
}
