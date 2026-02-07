import WidgetKit
import SwiftUI

// MARK: - ウィジェットデータ

struct CreatureWidgetEntry: TimelineEntry {
    let date: Date
    let creatureName: String
    let hp: Int
    let happiness: Int
    let evolutionStage: Int
    let streak: Int
    let nextAlarmTime: String?
    let isDead: Bool
}

// MARK: - タイムラインプロバイダ

struct CreatureTimelineProvider: TimelineProvider {
    private let defaults = UserDefaults(suiteName: Constants.appGroupIdentifier)

    func placeholder(in context: Context) -> CreatureWidgetEntry {
        CreatureWidgetEntry(
            date: .now,
            creatureName: "ネムリン",
            hp: 80,
            happiness: 70,
            evolutionStage: 1,
            streak: 5,
            nextAlarmTime: "07:00",
            isDead: false
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CreatureWidgetEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CreatureWidgetEntry>) -> Void) {
        let entry = loadEntry()
        // 15分ごとに更新
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> CreatureWidgetEntry {
        CreatureWidgetEntry(
            date: .now,
            creatureName: defaults?.string(forKey: "widget_creature_name") ?? "ネムリン",
            hp: defaults?.integer(forKey: "widget_creature_hp") ?? 100,
            happiness: defaults?.integer(forKey: "widget_creature_happiness") ?? 100,
            evolutionStage: defaults?.integer(forKey: "widget_creature_stage") ?? 0,
            streak: defaults?.integer(forKey: "widget_creature_streak") ?? 0,
            nextAlarmTime: defaults?.string(forKey: "widget_next_alarm"),
            isDead: defaults?.bool(forKey: "widget_creature_dead") ?? false
        )
    }
}

// MARK: - 小ウィジェット

struct SmallCreatureWidgetView: View {
    let entry: CreatureWidgetEntry

    var body: some View {
        VStack(spacing: 6) {
            // 生き物の顔（簡易版）
            MiniCreatureFace(
                stage: EvolutionStage(rawValue: entry.evolutionStage) ?? .egg,
                hp: entry.hp,
                isDead: entry.isDead
            )
            .frame(width: 50, height: 50)

            // 名前
            Text(entry.creatureName)
                .font(.caption2)
                .fontWeight(.medium)
                .lineLimit(1)

            // 次のアラーム
            if let time = entry.nextAlarmTime {
                HStack(spacing: 2) {
                    Image(systemName: "alarm.fill")
                        .font(.system(size: 8))
                    Text(time)
                        .font(.caption2)
                }
                .foregroundStyle(.secondary)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - 中ウィジェット

struct MediumCreatureWidgetView: View {
    let entry: CreatureWidgetEntry

    var body: some View {
        HStack(spacing: 16) {
            // 左: 生き物
            VStack(spacing: 4) {
                MiniCreatureFace(
                    stage: EvolutionStage(rawValue: entry.evolutionStage) ?? .egg,
                    hp: entry.hp,
                    isDead: entry.isDead
                )
                .frame(width: 60, height: 60)

                Text(entry.creatureName)
                    .font(.caption2)
                    .fontWeight(.medium)
            }

            // 右: ステータス
            VStack(alignment: .leading, spacing: 8) {
                // HP
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.caption2)
                        .foregroundStyle(.red)
                    WidgetProgressBar(value: Double(entry.hp) / 100.0, color: .green)
                    Text("\(entry.hp)")
                        .font(.caption2)
                        .monospacedDigit()
                }

                // 連続記録
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    Text("\(entry.streak)日連続")
                        .font(.caption2)
                }

                // 次のアラーム
                if let time = entry.nextAlarmTime {
                    HStack(spacing: 4) {
                        Image(systemName: "alarm.fill")
                            .font(.caption2)
                            .foregroundStyle(.purple)
                        Text(time)
                            .font(.caption2)
                    }
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - ミニ生き物顔

struct MiniCreatureFace: View {
    let stage: EvolutionStage
    let hp: Int
    let isDead: Bool

    var expression: CreatureExpression {
        if isDead { return .dead }
        return CreatureExpression.from(hp: hp, happiness: hp)
    }

    var bodyColor: Color {
        switch stage {
        case .egg: return .purple.opacity(0.5)
        case .baby: return .mint.opacity(0.7)
        case .young, .adult, .master: return .purple.opacity(0.6)
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(bodyColor)

            VStack(spacing: 3) {
                HStack(spacing: 8) {
                    miniEye
                    miniEye
                }
                miniMouth
            }
        }
    }

    @ViewBuilder
    private var miniEye: some View {
        switch expression {
        case .happy:
            HappyEyeShape()
                .stroke(.black, lineWidth: 1.5)
                .frame(width: 8, height: 4)
        case .dead:
            Text("×").font(.system(size: 8))
        default:
            Circle().fill(.black).frame(width: 5, height: 5)
        }
    }

    @ViewBuilder
    private var miniMouth: some View {
        switch expression {
        case .happy:
            HappyMouthShape()
                .fill(.pink.opacity(0.5))
                .frame(width: 10, height: 6)
        case .sad:
            SadMouthShape()
                .stroke(.black, lineWidth: 1)
                .frame(width: 8, height: 4)
        case .dead:
            Text("〜").font(.system(size: 6)).foregroundStyle(.gray)
        default:
            Capsule().fill(.pink.opacity(0.4)).frame(width: 6, height: 3)
        }
    }
}

// MARK: - ウィジェット用プログレスバー

struct WidgetProgressBar: View {
    let value: Double
    let color: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(color.opacity(0.2))
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: geo.size.width * min(1, max(0, value)))
            }
        }
        .frame(height: 6)
    }
}

// MARK: - ウィジェット定義

struct SleepMonsterWidget: Widget {
    let kind = "SleepMonsterWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CreatureTimelineProvider()) { entry in
            switch entry.widgetFamily {
            case .systemSmall:
                SmallCreatureWidgetView(entry: entry)
            default:
                MediumCreatureWidgetView(entry: entry)
            }
        }
        .configurationDisplayName("ねむモン")
        .description("ネムリンの状態と次のアラームを表示します")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// ウィジェットファミリーへのアクセス用
extension CreatureWidgetEntry {
    var widgetFamily: WidgetFamily { .systemSmall }
}

// MARK: - ウィジェットバンドル

@main
struct SleepMonsterWidgetBundle: WidgetBundle {
    var body: some Widget {
        SleepMonsterWidget()
    }
}

#Preview("小ウィジェット", as: .systemSmall) {
    SleepMonsterWidget()
} timeline: {
    CreatureWidgetEntry(
        date: .now,
        creatureName: "ネムリン",
        hp: 85,
        happiness: 70,
        evolutionStage: 2,
        streak: 7,
        nextAlarmTime: "07:00",
        isDead: false
    )
}

#Preview("中ウィジェット", as: .systemMedium) {
    SleepMonsterWidget()
} timeline: {
    CreatureWidgetEntry(
        date: .now,
        creatureName: "ネムリン",
        hp: 85,
        happiness: 70,
        evolutionStage: 2,
        streak: 7,
        nextAlarmTime: "07:00",
        isDead: false
    )
}
