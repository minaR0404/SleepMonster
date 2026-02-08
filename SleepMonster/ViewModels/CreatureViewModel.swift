import Foundation
import SwiftData
import Observation

@Observable
@MainActor
final class CreatureViewModel {
    private let repository: CreatureRepository
    private(set) var creature: Creature

    var showAccessoryAlert = false
    var showDeathAlert = false
    var showRevivalAlert = false
    var newlyUnlockedAccessories: [Accessory] = []

    init(modelContext: ModelContext) {
        let repo = CreatureRepository(modelContext: modelContext)
        self.repository = repo
        self.creature = repo.getOrCreate()
    }

    // MARK: - 起床結果を処理

    func processWakeUp(alarm: Alarm, dismissTime: Date) {
        let result = CreatureEngine.evaluate(
            dismissTime: dismissTime,
            scheduledTime: makeScheduledDate(alarm: alarm, relativeTo: dismissTime),
            snoozeCount: alarm.snoozeCount,
            creature: creature
        )

        CreatureEngine.applyResult(result, to: creature)

        // アクセサリー解放チェック
        if !result.newAccessories.isEmpty {
            newlyUnlockedAccessories = result.newAccessories
            showAccessoryAlert = true
        }

        // 死亡チェック
        if creature.isDead {
            showDeathAlert = true
        }

        repository.save()
    }

    // MARK: - スヌーズ処理

    func processSnooze(alarm: Alarm) {
        creature.hp -= 5
        creature.happiness -= 10
        creature.clampStats()

        if creature.isDead {
            showDeathAlert = true
        }

        repository.save()
    }

    // MARK: - ミス処理

    func processMissedAlarm() {
        let (hpDelta, happinessDelta) = CreatureEngine.missedAlarm()
        creature.hp += hpDelta
        creature.happiness += happinessDelta
        creature.streak = 0
        creature.totalMissed += 1
        creature.clampStats()

        if creature.isDead {
            showDeathAlert = true
        }

        repository.save()
    }

    // MARK: - 日次減衰

    func applyDailyDecayIfNeeded() {
        repository.applyDailyDecay(creature: creature)
        if creature.isDead {
            showDeathAlert = true
        }
    }

    // MARK: - 復活

    func revive() {
        CreatureEngine.revive(creature)
        showDeathAlert = false
        showRevivalAlert = true
        repository.save()
    }

    // MARK: - 名前変更

    func rename(_ newName: String) {
        guard !newName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        creature.name = newName
        repository.save()
    }

    // MARK: - アクセサリー装備

    func equip(_ accessory: Accessory) {
        guard creature.unlockedAccessoryIDs.contains(accessory.id) else { return }
        creature.equip(accessory.id, for: accessory.category)
        repository.save()
    }

    func unequip(category: AccessoryCategory) {
        creature.equip(nil, for: category)
        repository.save()
    }

    // MARK: - ヘルパー

    private func makeScheduledDate(alarm: Alarm, relativeTo date: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = alarm.hour
        components.minute = alarm.minute
        components.second = 0
        return calendar.date(from: components) ?? date
    }
}
