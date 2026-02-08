import SwiftUI

struct CreatureView: View {
    let expression: CreatureExpression
    let hp: Double
    let happiness: Double

    // 装備中アクセサリーID
    var equippedHead: String?
    var equippedNeck: String?
    var equippedHeld: String?
    var equippedBack: String?
    var equippedBackground: String?

    // アニメーション状態
    @State private var breathScale: CGFloat = 1.0
    @State private var bounceOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // 背景アクセサリー
            if let bg = equippedBackground {
                BackgroundAccessoryView(id: bg)
            }

            // せなかアクセサリー（本体の後ろ）
            if let back = equippedBack {
                BackAccessoryView(id: back)
            }

            // ヤマネ本体（常に子ヤマネ）
            YamaneBodyView(expression: expression)

            // くびアクセサリー
            if let neck = equippedNeck {
                NeckAccessoryView(id: neck)
            }

            // もちものアクセサリー
            if let held = equippedHeld {
                HeldAccessoryView(id: held)
            }

            // あたまアクセサリー
            if let head = equippedHead {
                HeadAccessoryView(id: head)
            }

            // HP高いときのキラキラ
            if hp >= 0.9 {
                SparkleEffect()
            }
        }
        .scaleEffect(breathScale)
        .offset(y: bounceOffset)
        .onAppear {
            startBreathingAnimation()
            if expression == .happy {
                startBounceAnimation()
            }
        }
        .onChange(of: expression) { _, newValue in
            if newValue == .happy {
                startBounceAnimation()
            }
        }
    }

    // MARK: - アニメーション

    private func startBreathingAnimation() {
        withAnimation(
            .easeInOut(duration: 2.5)
            .repeatForever(autoreverses: true)
        ) {
            breathScale = 1.05
        }
    }

    private func startBounceAnimation() {
        withAnimation(
            .easeInOut(duration: 0.6)
            .repeatForever(autoreverses: true)
        ) {
            bounceOffset = -8
        }
    }
}

// MARK: - ヤマネ本体（常に子ヤマネの姿）

struct YamaneBodyView: View {
    let expression: CreatureExpression

    var bodyColor: Color { .brown.opacity(0.45) }
    var bellyColor: Color { .orange.opacity(0.2) }

    var body: some View {
        ZStack {
            // 耳
            HStack(spacing: 70) {
                YamaneEar()
                    .rotationEffect(.degrees(-20))
                YamaneEar()
                    .rotationEffect(.degrees(20))
            }
            .offset(y: -50)

            // しっぽ
            YamaneTail()
                .offset(x: 55, y: 30)

            // 体（まんまる）
            Circle()
                .fill(
                    RadialGradient(
                        colors: [bodyColor, .brown.opacity(0.65)],
                        center: .center,
                        startRadius: 10,
                        endRadius: 65
                    )
                )
                .frame(width: 130, height: 130)

            // おなか
            Ellipse()
                .fill(bellyColor)
                .frame(width: 80, height: 70)
                .offset(y: 10)

            // ハイライト
            Circle()
                .fill(.white.opacity(0.35))
                .frame(width: 35, height: 35)
                .offset(x: -22, y: -25)

            // 手
            HStack(spacing: 95) {
                Capsule()
                    .fill(bodyColor)
                    .frame(width: 18, height: 30)
                    .rotationEffect(.degrees(20))
                Capsule()
                    .fill(bodyColor)
                    .frame(width: 18, height: 30)
                    .rotationEffect(.degrees(-20))
            }
            .offset(y: 15)

            // 足
            HStack(spacing: 35) {
                Capsule()
                    .fill(.brown.opacity(0.55))
                    .frame(width: 24, height: 18)
                Capsule()
                    .fill(.brown.opacity(0.55))
                    .frame(width: 24, height: 18)
            }
            .offset(y: 62)

            // ほっぺ
            HStack(spacing: 65) {
                Circle()
                    .fill(.pink.opacity(0.3))
                    .frame(width: 16, height: 16)
                Circle()
                    .fill(.pink.opacity(0.3))
                    .frame(width: 16, height: 16)
            }
            .offset(y: 0)

            // 顔
            CreatureFace(expression: expression, eyeSize: 15, eyeSpacing: 26, mouthScale: 1.1)
                .offset(y: -10)
        }
    }
}

// MARK: - ヤマネの耳

struct YamaneEar: View {
    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color.brown.opacity(0.5))
                .frame(width: 28, height: 35)
            Ellipse()
                .fill(Color.pink.opacity(0.25))
                .frame(width: 16, height: 20)
        }
    }
}

// MARK: - ヤマネのしっぽ

struct YamaneTail: View {
    var body: some View {
        Capsule()
            .fill(Color.brown.opacity(0.45))
            .frame(width: 40, height: 16)
            .rotationEffect(.degrees(-30))
    }
}

// MARK: - アクセサリー描画

struct HeadAccessoryView: View {
    let id: String

    var body: some View {
        Group {
            switch id {
            case "nightcap":
                // ナイトキャップ
                ZStack {
                    Triangle()
                        .fill(Color.indigo.opacity(0.7))
                        .frame(width: 40, height: 45)
                    Circle()
                        .fill(.white)
                        .frame(width: 10, height: 10)
                        .offset(x: 12, y: -20)
                }
                .offset(x: 15, y: -68)
                .rotationEffect(.degrees(15))

            case "crown_flower":
                // 花冠
                HStack(spacing: 6) {
                    FlowerShape().fill(.pink).frame(width: 14, height: 14)
                    FlowerShape().fill(.yellow).frame(width: 14, height: 14)
                    FlowerShape().fill(.pink).frame(width: 14, height: 14)
                    FlowerShape().fill(.yellow).frame(width: 14, height: 14)
                }
                .offset(y: -70)

            case "crown_gold":
                // 王冠
                CrownShape()
                    .fill(.yellow.opacity(0.85))
                    .frame(width: 45, height: 22)
                    .offset(y: -72)

            default:
                EmptyView()
            }
        }
    }
}

struct NeckAccessoryView: View {
    let id: String

    var body: some View {
        Group {
            switch id {
            case "scarf_fluffy":
                // もこもこマフラー
                ZStack {
                    Capsule()
                        .fill(Color.red.opacity(0.6))
                        .frame(width: 100, height: 22)
                    // マフラーの垂れ部分
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.red.opacity(0.5))
                        .frame(width: 18, height: 30)
                        .offset(x: 30, y: 18)
                }
                .offset(y: 30)

            case "pendant_star":
                // 星のペンダント
                VStack(spacing: 0) {
                    Capsule()
                        .fill(.yellow.opacity(0.4))
                        .frame(width: 60, height: 3)
                    Image(systemName: "star.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.yellow)
                }
                .offset(y: 35)

            default:
                EmptyView()
            }
        }
    }
}

struct HeldAccessoryView: View {
    let id: String

    var body: some View {
        Group {
            switch id {
            case "pillow_mini":
                // ミニまくら
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.cyan.opacity(0.5))
                    .frame(width: 28, height: 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(.white.opacity(0.5), lineWidth: 1)
                    )
                    .rotationEffect(.degrees(-10))
                    .offset(x: -58, y: 20)

            case "wand_star":
                // 星のステッキ
                ZStack(alignment: .top) {
                    Capsule()
                        .fill(.yellow.opacity(0.6))
                        .frame(width: 5, height: 45)
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.yellow)
                        .offset(y: -8)
                }
                .offset(x: -60, y: -5)

            default:
                EmptyView()
            }
        }
    }
}

struct BackAccessoryView: View {
    let id: String

    var body: some View {
        Group {
            switch id {
            case "wings_angel":
                // 天使の羽
                HStack(spacing: 90) {
                    WingShape()
                        .fill(.white.opacity(0.6))
                        .frame(width: 35, height: 40)
                        .scaleEffect(x: -1)
                    WingShape()
                        .fill(.white.opacity(0.6))
                        .frame(width: 35, height: 40)
                }
                .offset(y: -5)

            case "cape_moon":
                // 月のマント
                CapeShape()
                    .fill(
                        LinearGradient(
                            colors: [.indigo.opacity(0.5), .purple.opacity(0.4)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 140, height: 80)
                    .offset(y: 30)

            default:
                EmptyView()
            }
        }
    }
}

struct BackgroundAccessoryView: View {
    let id: String

    var body: some View {
        Group {
            switch id {
            case "bg_clouds":
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.3))
                        .frame(width: 180, height: 180)
                    CloudShape()
                        .fill(.white.opacity(0.5))
                        .frame(width: 80, height: 30)
                        .offset(x: -50, y: 60)
                    CloudShape()
                        .fill(.white.opacity(0.4))
                        .frame(width: 60, height: 22)
                        .offset(x: 55, y: 50)
                }

            case "bg_flowers":
                ZStack {
                    ForEach(0..<5) { i in
                        FlowerShape()
                            .fill([Color.pink, .yellow, .orange, .purple, .red][i % 5])
                            .frame(width: 12, height: 12)
                            .offset(
                                x: CGFloat([-60, -30, 0, 30, 60][i]),
                                y: CGFloat([65, 72, 68, 74, 66][i])
                            )
                    }
                }

            case "bg_starry":
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.indigo.opacity(0.15), .clear],
                                center: .center,
                                startRadius: 40,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                    ForEach(0..<6) { i in
                        Image(systemName: "star.fill")
                            .font(.system(size: CGFloat([6, 8, 5, 7, 6, 9][i])))
                            .foregroundStyle(.yellow.opacity(0.6))
                            .offset(
                                x: CGFloat([-70, 65, -50, 75, -80, 40][i]),
                                y: CGFloat([-60, -55, 30, 40, -10, -70][i])
                            )
                    }
                }

            case "bg_rainbow":
                RainbowArc()
                    .stroke(
                        AngularGradient(
                            colors: [.red, .orange, .yellow, .green, .blue, .purple, .red],
                            center: .bottom
                        ),
                        lineWidth: 6
                    )
                    .frame(width: 180, height: 90)
                    .offset(y: -30)
                    .opacity(0.4)

            default:
                EmptyView()
            }
        }
    }
}

// MARK: - キラキラエフェクト

struct SparkleEffect: View {
    @State private var opacity: Double = 0.3

    var body: some View {
        ForEach(0..<3) { i in
            Image(systemName: "sparkle")
                .font(.system(size: CGFloat([10, 8, 12][i])))
                .foregroundStyle(.yellow.opacity(opacity))
                .offset(
                    x: CGFloat([-55, 60, -40][i]),
                    y: CGFloat([-50, -40, 35][i])
                )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                opacity = 0.8
            }
        }
    }
}

// MARK: - 共通パーツ: 顔

struct CreatureFace: View {
    let expression: CreatureExpression
    let eyeSize: CGFloat
    let eyeSpacing: CGFloat
    let mouthScale: CGFloat

    @State private var blinkProgress: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 8 * mouthScale) {
            HStack(spacing: eyeSpacing) {
                EyeView(size: eyeSize, expression: expression, blinkProgress: blinkProgress)
                EyeView(size: eyeSize, expression: expression, blinkProgress: blinkProgress)
            }
            MouthView(expression: expression, scale: mouthScale)
        }
        .onAppear {
            startBlinking()
        }
    }

    private func startBlinking() {
        Timer.scheduledTimer(withTimeInterval: Double.random(in: 2.5...4.0), repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                blinkProgress = 0.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    blinkProgress = 1.0
                }
            }
        }
    }
}

// MARK: - 目

struct EyeView: View {
    let size: CGFloat
    let expression: CreatureExpression
    let blinkProgress: CGFloat

    var body: some View {
        ZStack {
            switch expression {
            case .happy:
                HappyEyeShape()
                    .stroke(.black, lineWidth: 2.5)
                    .frame(width: size, height: size * 0.5)

            case .neutral:
                Ellipse()
                    .fill(.black)
                    .frame(width: size * 0.8, height: size * blinkProgress)
                Circle()
                    .fill(.white)
                    .frame(width: size * 0.3, height: size * 0.3)
                    .offset(x: -size * 0.1, y: -size * 0.1)
                    .opacity(blinkProgress)

            case .sad:
                VStack(spacing: 2) {
                    SadEyebrowShape()
                        .stroke(.black, lineWidth: 2)
                        .frame(width: size, height: size * 0.3)
                    Ellipse()
                        .fill(.black)
                        .frame(width: size * 0.7, height: size * 0.6 * blinkProgress)
                }

            case .sleeping:
                Text("−")
                    .font(.system(size: size))
                    .fontWeight(.bold)

            case .dead:
                Text("×")
                    .font(.system(size: size))
                    .foregroundStyle(.gray)
            }
        }
    }
}

// MARK: - 口

struct MouthView: View {
    let expression: CreatureExpression
    let scale: CGFloat

    var body: some View {
        Group {
            switch expression {
            case .happy:
                HappyMouthShape()
                    .fill(.pink.opacity(0.6))
                    .frame(width: 20 * scale, height: 12 * scale)

            case .neutral:
                Capsule()
                    .fill(.pink.opacity(0.5))
                    .frame(width: 12 * scale, height: 5 * scale)

            case .sad:
                SadMouthShape()
                    .stroke(.black, lineWidth: 2)
                    .frame(width: 16 * scale, height: 8 * scale)

            case .sleeping:
                Text("zzz")
                    .font(.system(size: 10 * scale))
                    .foregroundStyle(.secondary)

            case .dead:
                Text("〜")
                    .font(.system(size: 12 * scale))
                    .foregroundStyle(.gray)
            }
        }
    }
}

// MARK: - カスタムシェイプ

struct HappyEyeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control: CGPoint(x: rect.midX, y: rect.minY)
        )
        return path
    }
}

struct SadEyebrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control: CGPoint(x: rect.midX, y: rect.midY)
        )
        return path
    }
}

struct HappyMouthShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.midX, y: rect.maxY + rect.height * 0.5)
        )
        path.closeSubpath()
        return path
    }
}

struct SadMouthShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.midX, y: rect.maxY)
        )
        return path
    }
}

struct ZigZagLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let segments = 5
        let segmentWidth = rect.width / CGFloat(segments)
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        for i in 0..<segments {
            let x = rect.minX + CGFloat(i) * segmentWidth + segmentWidth / 2
            let y = i % 2 == 0 ? rect.minY : rect.maxY
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

struct CrownShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width * 0.25, y: rect.maxY * 0.7))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.width * 0.75, y: rect.maxY * 0.7))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct FlowerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let petalRadius = rect.width * 0.35
        let centerRadius = rect.width * 0.2
        for i in 0..<5 {
            let angle = CGFloat(i) * .pi * 2 / 5 - .pi / 2
            let petalCenter = CGPoint(
                x: center.x + cos(angle) * petalRadius,
                y: center.y + sin(angle) * petalRadius
            )
            path.addEllipse(in: CGRect(
                x: petalCenter.x - centerRadius,
                y: petalCenter.y - centerRadius,
                width: centerRadius * 2,
                height: centerRadius * 2
            ))
        }
        path.addEllipse(in: CGRect(
            x: center.x - centerRadius * 0.6,
            y: center.y - centerRadius * 0.6,
            width: centerRadius * 1.2,
            height: centerRadius * 1.2
        ))
        return path
    }
}

struct WingShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.midY)
        )
        return path
    }
}

struct CapeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.15, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.15, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control: CGPoint(x: rect.maxX + 10, y: rect.midY)
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.15, y: rect.minY),
            control: CGPoint(x: rect.minX - 10, y: rect.midY)
        )
        return path
    }
}

struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: CGRect(x: rect.minX, y: rect.midY, width: rect.width * 0.4, height: rect.height))
        path.addEllipse(in: CGRect(x: rect.width * 0.2, y: rect.minY, width: rect.width * 0.5, height: rect.height))
        path.addEllipse(in: CGRect(x: rect.width * 0.5, y: rect.midY * 0.8, width: rect.width * 0.5, height: rect.height))
        return path
    }
}

struct RainbowArc: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.maxY),
            radius: rect.width / 2,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        return path
    }
}

// MARK: - プレビュー

#Preview("ヤマネ - 元気") {
    CreatureView(expression: .happy, hp: 0.95, happiness: 0.9)
        .frame(width: 200, height: 200)
}

#Preview("ヤマネ - 普通") {
    CreatureView(expression: .neutral, hp: 0.7, happiness: 0.5)
        .frame(width: 200, height: 200)
}

#Preview("ヤマネ - 悲しい") {
    CreatureView(expression: .sad, hp: 0.3, happiness: 0.2)
        .frame(width: 200, height: 200)
}

#Preview("ヤマネ - フル装備") {
    CreatureView(
        expression: .happy,
        hp: 0.95,
        happiness: 0.95,
        equippedHead: "crown_gold",
        equippedNeck: "pendant_star",
        equippedHeld: "wand_star",
        equippedBack: "wings_angel",
        equippedBackground: "bg_starry"
    )
    .frame(width: 200, height: 200)
}
