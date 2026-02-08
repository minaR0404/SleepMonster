import Foundation

struct CreatureEngine {

    struct EvaluationResult {
        let hpDelta: Int
        let happinessDelta: Int
        let streakBroken: Bool
        let newAccessories: [Accessory]
    }

    // MARK: - 起床結果の評価

    static func evaluate(
        dismissTime: Date,
        scheduledTime: Date,
        snoozeCount: Int,
        creature: Creature
    ) -> EvaluationResult {
        let delay = dismissTime.timeIntervalSince(scheduledTime)

        var hpDelta = 0
        var happinessDelta = 0
        var streakBroken = false

        // スヌーズペナルティ（1回ごとに -5HP, -10しあわせ度）
        hpDelta -= snoozeCount * 5
        happinessDelta -= snoozeCount * 10

        // 起床タイミングによる評価
        switch delay {
        case ..<60:        // 1分以内 → 成功
            hpDelta += 5
            happinessDelta += 10
        case 60..<300:     // 1〜5分 → やや遅刻
            happinessDelta += 3
        case 300..<600:    // 5〜10分 → かなり遅刻
            hpDelta -= 10
            happinessDelta -= 15
            streakBroken = true
        default:           // 10分以上 → 寝坊
            hpDelta -= 20
            happinessDelta -= 30
            streakBroken = true
        }

        // アクセサリー解放チェック
        let newStreak = streakBroken ? 0 : creature.streak + 1
        let bestStreak = max(creature.bestStreak, newStreak)
        let newAccessories = checkNewAccessories(
            bestStreak: bestStreak,
            unlockedIDs: creature.unlockedAccessoryIDs
        )

        return EvaluationResult(
            hpDelta: hpDelta,
            happinessDelta: happinessDelta,
            streakBroken: streakBroken,
            newAccessories: newAccessories
        )
    }

    // MARK: - アクセサリー解放判定

    static func checkNewAccessories(
        bestStreak: Int,
        unlockedIDs: [String]
    ) -> [Accessory] {
        AccessoryCatalog.unlockable(forStreak: bestStreak, excluding: unlockedIDs)
    }

    // MARK: - 日次減衰（アラーム未設定の日）

    static func dailyDecay() -> (hpDelta: Int, happinessDelta: Int) {
        (-3, -5)
    }

    // MARK: - ミス判定

    static func missedAlarm() -> (hpDelta: Int, happinessDelta: Int) {
        (-20, -30)
    }

    // MARK: - 起床結果の分類

    static func classifyWakeUp(
        dismissTime: Date,
        scheduledTime: Date,
        snoozeCount: Int
    ) -> WakeUpResult {
        let delay = dismissTime.timeIntervalSince(scheduledTime)
        switch delay {
        case ..<60: return .onTime
        case 60..<300: return .late
        case 300..<600: return .veryLate
        default: return .missed
        }
    }

    // MARK: - 生き物にステータス変更を適用

    static func applyResult(_ result: EvaluationResult, to creature: Creature) {
        creature.hp += result.hpDelta
        creature.happiness += result.happinessDelta

        if result.streakBroken {
            creature.streak = 0
        } else {
            creature.streak += 1
        }

        creature.bestStreak = max(creature.bestStreak, creature.streak)

        // 新アクセサリーを解放
        for accessory in result.newAccessories {
            if !creature.unlockedAccessoryIDs.contains(accessory.id) {
                creature.unlockedAccessoryIDs.append(accessory.id)
            }
        }

        creature.totalWakeUps += 1
        creature.lastInteractionDate = .now
        creature.clampStats()
    }

    // MARK: - 復活処理

    static func revive(_ creature: Creature) {
        creature.hp = 50
        creature.happiness = 50
        creature.streak = 0
        creature.isDead = false
        creature.bornDate = .now
        creature.lastInteractionDate = .now
    }
}
