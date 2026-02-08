import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var creatureVM: CreatureViewModel?
    @State private var alarmVM: AlarmViewModel?

    var body: some View {
        NavigationStack {
            if let vm = creatureVM, let alarmVM = alarmVM {
                ScrollView {
                    VStack(spacing: 24) {
                        // 生き物の名前
                        VStack(spacing: 4) {
                            Text(vm.creature.name)
                                .font(.title2)
                                .fontWeight(.bold)

                            // 解放済みアクセサリー数
                            Text("アクセサリー \(vm.creature.unlockedAccessoryIDs.count)/\(AccessoryCatalog.all.count)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        // 生き物の表示
                        CreatureView(
                            expression: vm.creature.expression,
                            hp: vm.creature.hpRatio,
                            happiness: vm.creature.happinessRatio,
                            equippedHead: vm.creature.equippedHead,
                            equippedNeck: vm.creature.equippedNeck,
                            equippedHeld: vm.creature.equippedHeld,
                            equippedBack: vm.creature.equippedBack,
                            equippedBackground: vm.creature.equippedBackground
                        )
                        .frame(width: 200, height: 200)

                        // HPとしあわせ度ゲージ
                        HStack(spacing: 24) {
                            CircularStatCard(
                                title: "HP",
                                value: vm.creature.hpRatio,
                                color: hpColor(vm.creature.hpRatio),
                                icon: "heart.fill"
                            )
                            CircularStatCard(
                                title: "しあわせ",
                                value: vm.creature.happinessRatio,
                                color: .orange,
                                icon: "star.fill"
                            )
                        }
                        .padding(.horizontal, 16)

                        // 連続起床記録
                        HStack(spacing: 24) {
                            InfoCard(
                                title: "連続起床",
                                value: "\(vm.creature.streak)日",
                                icon: "flame.fill",
                                color: .orange
                            )
                            InfoCard(
                                title: "次のアラーム",
                                value: alarmVM.nextAlarmText,
                                icon: "alarm.fill",
                                color: .purple
                            )
                        }
                        .padding(.horizontal, 16)

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 20)
                }
                .navigationTitle("やまねむ")
                .alert("新しいアクセサリー！", isPresented: Binding(
                    get: { vm.showAccessoryAlert },
                    set: { vm.showAccessoryAlert = $0 }
                )) {
                    Button("やったー！") {}
                } message: {
                    let names = vm.newlyUnlockedAccessories.map(\.name).joined(separator: "、")
                    Text("\(vm.creature.name)が「\(names)」を手に入れたよ！")
                }
                .alert("ヤマネが…", isPresented: Binding(
                    get: { vm.showDeathAlert },
                    set: { vm.showDeathAlert = $0 }
                )) {
                    Button("復活チャレンジ") {
                        vm.revive()
                    }
                } message: {
                    Text("\(vm.creature.name)は力尽きてしまいました…\n7日連続起床で復活できます")
                }
            } else {
                ProgressView()
                    .onAppear { setup() }
            }
        }
    }

    private func setup() {
        creatureVM = CreatureViewModel(modelContext: modelContext)
        alarmVM = AlarmViewModel(modelContext: modelContext)
        creatureVM?.applyDailyDecayIfNeeded()
    }

    private func hpColor(_ ratio: Double) -> Color {
        if ratio > 0.6 { return .green }
        if ratio > 0.3 { return .yellow }
        return .red
    }
}

// MARK: - 円形ステータスカード

struct CircularStatCard: View {
    let title: String
    let value: Double
    let color: Color
    let icon: String

    private let lineWidth: CGFloat = 8

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // 背景リング
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: lineWidth)

                // 値リング
                Circle()
                    .trim(from: 0, to: max(0, min(1, value)))
                    .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: value)

                // 中央のアイコンと数値
                VStack(spacing: 2) {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundStyle(color)
                    Text("\(Int(value * 100))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .monospacedDigit()
                }
            }
            .frame(width: 64, height: 64)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - 情報カード

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Creature.self, Alarm.self, WakeUpRecord.self], inMemory: true)
}
