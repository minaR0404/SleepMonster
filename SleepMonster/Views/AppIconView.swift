import SwiftUI

/// アプリアイコン用のヤマネ顔ビュー（静的・アニメーションなし）
/// 1024pt基準のスケーリングで任意サイズに描画可能
struct AppIconView: View {
    let size: CGFloat

    private var s: CGFloat { size / 1024.0 }

    var body: some View {
        ZStack {
            // 背景グラデーション
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.purple.opacity(0.5),
                            Color.indigo.opacity(0.7)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // 耳
            HStack(spacing: 60 * s) {
                iconEar
                    .rotationEffect(.degrees(-20))
                iconEar
                    .rotationEffect(.degrees(20))
            }
            .offset(y: -280 * s)

            // 体（まんまる）
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.brown.opacity(0.45),
                            Color.brown.opacity(0.65)
                        ],
                        center: .center,
                        startRadius: 80 * s,
                        endRadius: 360 * s
                    )
                )
                .frame(width: 720 * s, height: 720 * s)
                .offset(y: 40 * s)

            // ハイライト
            Circle()
                .fill(.white.opacity(0.35))
                .frame(width: 180 * s, height: 180 * s)
                .offset(x: -120 * s, y: -120 * s)

            // ほっぺ
            HStack(spacing: 360 * s) {
                Circle()
                    .fill(.pink.opacity(0.4))
                    .frame(width: 90 * s, height: 90 * s)
                Circle()
                    .fill(.pink.opacity(0.4))
                    .frame(width: 90 * s, height: 90 * s)
            }
            .offset(y: 40 * s)

            // 目（にっこり）
            HStack(spacing: 140 * s) {
                HappyEyeShape()
                    .stroke(.black, lineWidth: 14 * s)
                    .frame(width: 80 * s, height: 40 * s)
                HappyEyeShape()
                    .stroke(.black, lineWidth: 14 * s)
                    .frame(width: 80 * s, height: 40 * s)
            }
            .offset(y: -60 * s)

            // 口
            HappyMouthShape()
                .fill(.pink.opacity(0.6))
                .frame(width: 100 * s, height: 60 * s)
                .offset(y: 50 * s)
        }
        .frame(width: size, height: size)
        .clipped()
    }

    private var iconEar: some View {
        ZStack {
            Ellipse()
                .fill(Color.brown.opacity(0.5))
                .frame(width: 155 * s, height: 195 * s)
            Ellipse()
                .fill(Color.pink.opacity(0.35))
                .frame(width: 90 * s, height: 112 * s)
        }
    }
}

#Preview("App Icon 1024") {
    AppIconView(size: 1024)
}

#Preview("App Icon 180 (Home Screen @3x)") {
    AppIconView(size: 180)
}

#Preview("App Icon 60 (Home Screen @1x)") {
    AppIconView(size: 60)
}
