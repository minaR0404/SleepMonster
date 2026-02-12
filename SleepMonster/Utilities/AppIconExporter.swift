import SwiftUI

/// AppIconViewを1024x1024 PNGとして書き出すユーティリティ
/// Xcode 15+では1024x1024の1枚で全サイズ自動生成される
@MainActor
struct AppIconExporter {

    /// 1024x1024のPNG Dataを生成
    static func exportPNG() -> Data? {
        let renderer = ImageRenderer(content: AppIconView(size: 1024))
        renderer.scale = 1.0
        guard let image = renderer.uiImage else { return nil }
        return image.pngData()
    }

    /// ドキュメントディレクトリにPNGを保存して、ファイルURLを返す
    static func saveToDocuments() -> URL? {
        guard let data = exportPNG() else { return nil }
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AppIcon.png")
        do {
            try data.write(to: url)
            return url
        } catch {
            print("AppIcon export failed: \(error)")
            return nil
        }
    }
}
