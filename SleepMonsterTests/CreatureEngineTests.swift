import Testing
import Foundation
@testable import SleepMonster

@Suite("CreatureEngine Tests")
struct CreatureEngineTests {

    // MARK: - 起床評価テスト

    @Test("1分以内の起床で HP+5, しあわせ+10")
    func onTimeWakeUp() {
        let creature = Creature()
        creature.hp = 80
        creature.happiness = 60
        creature.streak = 5

        let scheduled = Date()
        let dismiss = scheduled.addingTimeInterval(30) // 30秒後

        let result = CreatureEngine.evaluate(
            dismissTime: dismiss,
            scheduledTime: scheduled,
            snoozeCount: 0,
            creature: creature
        )

        #expect(result.hpDelta == 5)
        #expect(result.happinessDelta == 10)
        #expect(result.streakBroken == false)
    }

    @Test("1〜5分の起床で HP±0, しあわせ+3")
    func lateWakeUp() {
        let creature = Creature()
        let scheduled = Date()
        let dismiss = scheduled.addingTimeInterval(120) // 2分後

        let result = CreatureEngine.evaluate(
            dismissTime: dismiss,
            scheduledTime: scheduled,
            snoozeCount: 0,
            creature: creature
        )

        #expect(result.hpDelta == 0)
        #expect(result.happinessDelta == 3)
        #expect(result.streakBroken == false)
    }

    @Test("5〜10分の起床で HP-10, しあわせ-15, 連続リセット")
    func veryLateWakeUp() {
        let creature = Creature()
        creature.streak = 10

        let scheduled = Date()
        let dismiss = scheduled.addingTimeInterval(420) // 7分後

        let result = CreatureEngine.evaluate(
            dismissTime: dismiss,
            scheduledTime: scheduled,
            snoozeCount: 0,
            creature: creature
        )

        #expect(result.hpDelta == -10)
        #expect(result.happinessDelta == -15)
        #expect(result.streakBroken == true)
    }

    @Test("10分以上の放置で HP-20, しあわせ-30, 連続リセット")
    func missedWakeUp() {
        let creature = Creature()
        let scheduled = Date()
        let dismiss = scheduled.addingTimeInterval(700) // 11分後

        let result = CreatureEngine.evaluate(
            dismissTime: dismiss,
            scheduledTime: scheduled,
            snoozeCount: 0,
            creature: creature
        )

        #expect(result.hpDelta == -20)
        #expect(result.happinessDelta == -30)
        #expect(result.streakBroken == true)
    }

    @Test("スヌーズペナルティ: 1回で HP-5, しあわせ-10 追加")
    func snoozeOnce() {
        let creature = Creature()
        let scheduled = Date()
        let dismiss = scheduled.addingTimeInterval(30) // 時間通り

        let result = CreatureEngine.evaluate(
            dismissTime: dismiss,
            scheduledTime: scheduled,
            snoozeCount: 1,
            creature: creature
        )

        // 時間通り(+5, +10) + スヌーズ1回(-5, -10)
        #expect(result.hpDelta == 0)
        #expect(result.happinessDelta == 0)
    }

    @Test("スヌーズ3回で大きなペナルティ")
    func snoozeThreeTimes() {
        let creature = Creature()
        let scheduled = Date()
        let dismiss = scheduled.addingTimeInterval(30)

        let result = CreatureEngine.evaluate(
            dismissTime: dismiss,
            scheduledTime: scheduled,
            snoozeCount: 3,
            creature: creature
        )

        // 時間通り(+5, +10) + スヌーズ3回(-15, -30)
        #expect(result.hpDelta == -10)
        #expect(result.happinessDelta == -20)
    }

    // MARK: - アクセサリー解放テスト

    @Test("連続3日でナイトキャップが解放される")
    func unlockNightcap() {
        let accessories = CreatureEngine.checkNewAccessories(
            bestStreak: 3,
            unlockedIDs: []
        )
        let ids = accessories.map(\.id)
        #expect(ids.contains("nightcap"))
    }

    @Test("連続7日でマフラーと雲の上が解放される")
    func unlockAtSevenDays() {
        let accessories = CreatureEngine.checkNewAccessories(
            bestStreak: 7,
            unlockedIDs: ["nightcap", "pillow_mini"]
        )
        let ids = accessories.map(\.id)
        #expect(ids.contains("scarf_fluffy"))
        #expect(ids.contains("bg_clouds"))
    }

    @Test("既に解放済みのアクセサリーは重複しない")
    func noDuplicateUnlock() {
        let accessories = CreatureEngine.checkNewAccessories(
            bestStreak: 7,
            unlockedIDs: ["nightcap", "pillow_mini", "scarf_fluffy", "bg_clouds"]
        )
        let ids = accessories.map(\.id)
        #expect(!ids.contains("nightcap"))
        #expect(!ids.contains("scarf_fluffy"))
    }

    @Test("bestStreakでアクセサリーが解放される（現在のstreakがリセットされても）")
    func bestStreakPreservesUnlocks() {
        let creature = Creature()
        creature.bestStreak = 7
        creature.streak = 0 // リセット済み

        let accessories = CreatureEngine.checkNewAccessories(
            bestStreak: creature.bestStreak,
            unlockedIDs: creature.unlockedAccessoryIDs
        )
        let ids = accessories.map(\.id)
        #expect(ids.contains("nightcap"))
        #expect(ids.contains("scarf_fluffy"))
    }

    // MARK: - ステータス適用テスト

    @Test("結果を生き物に適用")
    func applyResult() {
        let creature = Creature()
        creature.hp = 80
        creature.happiness = 60
        creature.streak = 2

        let result = CreatureEngine.EvaluationResult(
            hpDelta: 5,
            happinessDelta: 10,
            streakBroken: false,
            newAccessories: [
                Accessory(id: "nightcap", name: "ナイトキャップ", category: .head, requiredStreak: 3)
            ]
        )

        CreatureEngine.applyResult(result, to: creature)

        #expect(creature.hp == 85)
        #expect(creature.happiness == 70)
        #expect(creature.streak == 3)
        #expect(creature.totalWakeUps == 1)
        #expect(creature.unlockedAccessoryIDs.contains("nightcap"))
    }

    @Test("HP上限は100")
    func hpClamped() {
        let creature = Creature()
        creature.hp = 98

        let result = CreatureEngine.EvaluationResult(
            hpDelta: 5,
            happinessDelta: 0,
            streakBroken: false,
            newAccessories: []
        )

        CreatureEngine.applyResult(result, to: creature)
        #expect(creature.hp == 100)
    }

    @Test("HP0で死亡フラグ")
    func deathOnZeroHP() {
        let creature = Creature()
        creature.hp = 10

        let result = CreatureEngine.EvaluationResult(
            hpDelta: -20,
            happinessDelta: -30,
            streakBroken: true,
            newAccessories: []
        )

        CreatureEngine.applyResult(result, to: creature)
        #expect(creature.hp == 0)
        #expect(creature.isDead == true)
    }

    // MARK: - 復活テスト

    @Test("復活で HP50, しあわせ50 に戻る")
    func revive() {
        let creature = Creature()
        creature.hp = 0
        creature.isDead = true
        creature.streak = 0
        creature.unlockedAccessoryIDs = ["nightcap"]

        CreatureEngine.revive(creature)

        #expect(creature.hp == 50)
        #expect(creature.happiness == 50)
        #expect(creature.isDead == false)
        // アクセサリーは失わない
        #expect(creature.unlockedAccessoryIDs.contains("nightcap"))
    }

    // MARK: - 日次減衰テスト

    @Test("日次減衰は HP-3, しあわせ-5")
    func dailyDecay() {
        let (hpDelta, happinessDelta) = CreatureEngine.dailyDecay()
        #expect(hpDelta == -3)
        #expect(happinessDelta == -5)
    }

    // MARK: - 起床結果分類テスト

    @Test("起床結果の分類")
    func classifyWakeUp() {
        let scheduled = Date()

        #expect(CreatureEngine.classifyWakeUp(
            dismissTime: scheduled.addingTimeInterval(30),
            scheduledTime: scheduled,
            snoozeCount: 0
        ) == .onTime)

        #expect(CreatureEngine.classifyWakeUp(
            dismissTime: scheduled.addingTimeInterval(120),
            scheduledTime: scheduled,
            snoozeCount: 0
        ) == .late)

        #expect(CreatureEngine.classifyWakeUp(
            dismissTime: scheduled.addingTimeInterval(400),
            scheduledTime: scheduled,
            snoozeCount: 0
        ) == .veryLate)

        #expect(CreatureEngine.classifyWakeUp(
            dismissTime: scheduled.addingTimeInterval(700),
            scheduledTime: scheduled,
            snoozeCount: 0
        ) == .missed)
    }
}
