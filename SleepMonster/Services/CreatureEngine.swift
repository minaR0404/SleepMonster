import Foundation

struct CreatureEngine {

    struct EvaluationResult {
        let hpDelta: Int
        let happinessDelta: Int
        let streakBroken: Bool
        let newEvolutionStage: EvolutionStage?
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

        // 進化チェック
        let newStreak = streakBroken ? 0 : creature.streak + 1
        let newHP = min(100, max(0, creature.hp + hpDelta))
        let candidateStage = checkEvolution(
            streak: newStreak,
            hp: newHP,
            currentStage: creature.evolutionStage
        )

        return EvaluationResult(
            hpDelta: hpDelta,
            happinessDelta: happinessDelta,
            streakBroken: streakBroken,
            newEvolutionStage: candidateStage != creature.evolutionStage ? candidateStage : nil
        )
    }

    // MARK: - 進化判定（退化はしない）

    static func checkEvolution(
        streak: Int,
        hp: Int,
        currentStage: EvolutionStage
    ) -> EvolutionStage {
        if streak >= 60 && hp > 90 {
            return max(currentStage, .master)
        }
        if streak >= 21 && hp > 80 {
            return max(currentStage, .adult)
        }
        if streak >= 7 && hp > 70 {
            return max(currentStage, .young)
        }
        if streak >= 3 {
            return max(currentStage, .baby)
        }
        return currentStage
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

        if let newStage = result.newEvolutionStage {
            creature.evolutionStage = newStage
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
        creature.evolutionStage = .egg
        creature.bornDate = .now
        creature.lastInteractionDate = .now
    }
}

// MARK: - EvolutionStage Comparable

extension EvolutionStage: Comparable {
    static func < (lhs: EvolutionStage, rhs: EvolutionStage) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
