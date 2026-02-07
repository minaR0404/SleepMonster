import SwiftUI

struct CreatureView: View {
    let stage: EvolutionStage
    let expression: CreatureExpression
    let hp: Double
    let happiness: Double

    // アニメーション状態
    @State private var breathScale: CGFloat = 1.0
    @State private var blinkOpacity: Double = 1.0
    @State private var bounceOffset: CGFloat = 0
    @State private var wobble: Double = 0

    var body: some View {
        ZStack {
            switch stage {
            case .egg:
                EggView(expression: expression)
            case .baby:
                BabyCreatureView(expression: expression)
            case .young:
                YoungCreatureView(expression: expression)
            case .adult:
                AdultCreatureView(expression: expression)
            case .master:
                MasterCreatureView(expression: expression)
            }
        }
        .scaleEffect(breathScale)
        .offset(y: bounceOffset)
        .rotationEffect(.degrees(wobble))
        .onAppear {
            startBreathingAnimation()
            startBlinkingAnimation()
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

    private func startBlinkingAnimation() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.15)) {
                blinkOpacity = 0.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    blinkOpacity = 1.0
                }
            }
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

// MARK: - タマゴ

struct EggView: View {
    let expression: CreatureExpression
    @State private var wobble = false

    var body: some View {
        ZStack {
            // タマゴ本体
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.3), .purple.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 100, height: 130)
                .overlay(
                    Ellipse()
                        .fill(.white.opacity(0.3))
                        .frame(width: 30, height: 40)
                        .offset(x: -15, y: -20)
                )

            // ひび割れ模様
            ZigZagLine()
                .stroke(.purple.opacity(0.4), lineWidth: 2)
                .frame(width: 80, height: 20)
                .offset(y: 10)

            // 顔（うっすら見える）
            VStack(spacing: 8) {
                HStack(spacing: 20) {
                    Circle().fill(.purple.opacity(0.4)).frame(width: 8, height: 8)
                    Circle().fill(.purple.opacity(0.4)).frame(width: 8, height: 8)
                }
                RoundedRectangle(cornerRadius: 2)
                    .fill(.purple.opacity(0.3))
                    .frame(width: 10, height: 4)
            }
            .offset(y: -15)
        }
        .rotationEffect(.degrees(wobble ? 3 : -3))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                wobble = true
            }
        }
    }
}

// MARK: - ベビモン

struct BabyCreatureView: View {
    let expression: CreatureExpression

    var body: some View {
        ZStack {
            // 体
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.mint.opacity(0.5), .mint.opacity(0.8)],
                        center: .center,
                        startRadius: 10,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)

            // ハイライト
            Circle()
                .fill(.white.opacity(0.4))
                .frame(width: 35, height: 35)
                .offset(x: -20, y: -20)

            // 顔
            CreatureFace(expression: expression, eyeSize: 14, eyeSpacing: 24, mouthScale: 1.0)
        }
    }
}

// MARK: - ヤングモン

struct YoungCreatureView: View {
    let expression: CreatureExpression

    var body: some View {
        ZStack {
            // 耳
            HStack(spacing: 70) {
                Ellipse()
                    .fill(Color.indigo.opacity(0.5))
                    .frame(width: 25, height: 35)
                    .rotationEffect(.degrees(-20))
                Ellipse()
                    .fill(Color.indigo.opacity(0.5))
                    .frame(width: 25, height: 35)
                    .rotationEffect(.degrees(20))
            }
            .offset(y: -55)

            // 体
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.indigo.opacity(0.4), .indigo.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 130, height: 150)

            // ハイライト
            Ellipse()
                .fill(.white.opacity(0.3))
                .frame(width: 40, height: 50)
                .offset(x: -20, y: -20)

            // 腕
            HStack(spacing: 100) {
                Capsule()
                    .fill(Color.indigo.opacity(0.5))
                    .frame(width: 20, height: 40)
                    .rotationEffect(.degrees(20))
                Capsule()
                    .fill(Color.indigo.opacity(0.5))
                    .frame(width: 20, height: 40)
                    .rotationEffect(.degrees(-20))
            }
            .offset(y: 10)

            // 顔
            CreatureFace(expression: expression, eyeSize: 16, eyeSpacing: 28, mouthScale: 1.2)
                .offset(y: -15)
        }
    }
}

// MARK: - アダルトモン

struct AdultCreatureView: View {
    let expression: CreatureExpression

    var body: some View {
        ZStack {
            // 耳
            HStack(spacing: 80) {
                Ellipse()
                    .fill(Color.purple.opacity(0.5))
                    .frame(width: 30, height: 45)
                    .rotationEffect(.degrees(-15))
                Ellipse()
                    .fill(Color.purple.opacity(0.5))
                    .frame(width: 30, height: 45)
                    .rotationEffect(.degrees(15))
            }
            .offset(y: -65)

            // 体
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.4), .purple.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 140, height: 165)

            // ほっぺ
            HStack(spacing: 80) {
                Circle()
                    .fill(.pink.opacity(0.3))
                    .frame(width: 20, height: 20)
                Circle()
                    .fill(.pink.opacity(0.3))
                    .frame(width: 20, height: 20)
            }
            .offset(y: -5)

            // ハイライト
            Ellipse()
                .fill(.white.opacity(0.3))
                .frame(width: 45, height: 55)
                .offset(x: -22, y: -25)

            // 腕
            HStack(spacing: 115) {
                Capsule()
                    .fill(Color.purple.opacity(0.5))
                    .frame(width: 22, height: 45)
                    .rotationEffect(.degrees(15))
                Capsule()
                    .fill(Color.purple.opacity(0.5))
                    .frame(width: 22, height: 45)
                    .rotationEffect(.degrees(-15))
            }
            .offset(y: 10)

            // 足
            HStack(spacing: 40) {
                Capsule()
                    .fill(Color.purple.opacity(0.6))
                    .frame(width: 28, height: 25)
                Capsule()
                    .fill(Color.purple.opacity(0.6))
                    .frame(width: 28, height: 25)
            }
            .offset(y: 80)

            // 顔
            CreatureFace(expression: expression, eyeSize: 18, eyeSpacing: 32, mouthScale: 1.3)
                .offset(y: -18)
        }
    }
}

// MARK: - マスターモン

struct MasterCreatureView: View {
    let expression: CreatureExpression
    @State private var glowOpacity: Double = 0.3

    var body: some View {
        ZStack {
            // グロー効果
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.yellow.opacity(glowOpacity), .clear],
                        center: .center,
                        startRadius: 50,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)

            // 王冠
            CrownShape()
                .fill(.yellow.opacity(0.8))
                .frame(width: 50, height: 25)
                .offset(y: -90)

            // 耳
            HStack(spacing: 85) {
                Ellipse()
                    .fill(Color.purple.opacity(0.6))
                    .frame(width: 32, height: 48)
                    .rotationEffect(.degrees(-15))
                Ellipse()
                    .fill(Color.purple.opacity(0.6))
                    .frame(width: 32, height: 48)
                    .rotationEffect(.degrees(15))
            }
            .offset(y: -65)

            // 体
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.5), .purple.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 145, height: 170)

            // 星マーク（胸元）
            Image(systemName: "star.fill")
                .font(.system(size: 20))
                .foregroundStyle(.yellow.opacity(0.7))
                .offset(y: 30)

            // ほっぺ
            HStack(spacing: 85) {
                Circle()
                    .fill(.pink.opacity(0.4))
                    .frame(width: 22, height: 22)
                Circle()
                    .fill(.pink.opacity(0.4))
                    .frame(width: 22, height: 22)
            }
            .offset(y: -5)

            // ハイライト
            Ellipse()
                .fill(.white.opacity(0.3))
                .frame(width: 48, height: 58)
                .offset(x: -24, y: -25)

            // 腕
            HStack(spacing: 120) {
                Capsule()
                    .fill(Color.purple.opacity(0.6))
                    .frame(width: 24, height: 48)
                    .rotationEffect(.degrees(15))
                Capsule()
                    .fill(Color.purple.opacity(0.6))
                    .frame(width: 24, height: 48)
                    .rotationEffect(.degrees(-15))
            }
            .offset(y: 10)

            // 足
            HStack(spacing: 45) {
                Capsule()
                    .fill(Color.purple.opacity(0.7))
                    .frame(width: 30, height: 28)
                Capsule()
                    .fill(Color.purple.opacity(0.7))
                    .frame(width: 30, height: 28)
            }
            .offset(y: 83)

            // 顔
            CreatureFace(expression: expression, eyeSize: 20, eyeSpacing: 34, mouthScale: 1.4)
                .offset(y: -20)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowOpacity = 0.6
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
            // 目
            HStack(spacing: eyeSpacing) {
                EyeView(size: eyeSize, expression: expression, blinkProgress: blinkProgress)
                EyeView(size: eyeSize, expression: expression, blinkProgress: blinkProgress)
            }

            // 口
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
                // にっこり目（U字）
                HappyEyeShape()
                    .stroke(.black, lineWidth: 2.5)
                    .frame(width: size, height: size * 0.5)

            case .neutral:
                // 通常の目
                Ellipse()
                    .fill(.black)
                    .frame(width: size * 0.8, height: size * blinkProgress)
                // ハイライト
                Circle()
                    .fill(.white)
                    .frame(width: size * 0.3, height: size * 0.3)
                    .offset(x: -size * 0.1, y: -size * 0.1)
                    .opacity(blinkProgress)

            case .sad:
                // 悲しい目（下がった眉付き）
                VStack(spacing: 2) {
                    // 眉
                    SadEyebrowShape()
                        .stroke(.black, lineWidth: 2)
                        .frame(width: size, height: size * 0.3)
                    // 目
                    Ellipse()
                        .fill(.black)
                        .frame(width: size * 0.7, height: size * 0.6 * blinkProgress)
                }

            case .sleeping:
                // 寝ている目
                Text("−")
                    .font(.system(size: size))
                    .fontWeight(.bold)

            case .dead:
                // ×目
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
                // 大きく開いた口
                HappyMouthShape()
                    .fill(.pink.opacity(0.6))
                    .frame(width: 20 * scale, height: 12 * scale)

            case .neutral:
                // 普通の口
                Capsule()
                    .fill(.pink.opacity(0.5))
                    .frame(width: 12 * scale, height: 5 * scale)

            case .sad:
                // への字口
                SadMouthShape()
                    .stroke(.black, lineWidth: 2)
                    .frame(width: 16 * scale, height: 8 * scale)

            case .sleeping:
                // Zzz
                Text("zzz")
                    .font(.system(size: 10 * scale))
                    .foregroundStyle(.secondary)

            case .dead:
                // 波線
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

// MARK: - プレビュー

#Preview("タマゴ") {
    CreatureView(stage: .egg, expression: .neutral, hp: 1.0, happiness: 1.0)
        .frame(width: 200, height: 200)
}

#Preview("ベビモン - 元気") {
    CreatureView(stage: .baby, expression: .happy, hp: 0.9, happiness: 0.9)
        .frame(width: 200, height: 200)
}

#Preview("ヤングモン - 普通") {
    CreatureView(stage: .young, expression: .neutral, hp: 0.7, happiness: 0.5)
        .frame(width: 200, height: 200)
}

#Preview("アダルトモン - 悲しい") {
    CreatureView(stage: .adult, expression: .sad, hp: 0.3, happiness: 0.2)
        .frame(width: 200, height: 200)
}

#Preview("マスターモン") {
    CreatureView(stage: .master, expression: .happy, hp: 1.0, happiness: 1.0)
        .frame(width: 200, height: 200)
}
