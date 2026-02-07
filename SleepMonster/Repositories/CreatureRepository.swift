import Foundation
import SwiftData

@MainActor
final class CreatureRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// 現在の生き物を取得（なければ新規作成）
    func getOrCreate() -> Creature {
        let descriptor = FetchDescriptor<Creature>()
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }
        let creature = Creature()
        modelContext.insert(creature)
        try? modelContext.save()
        return creature
    }

    func save() {
        try? modelContext.save()
    }

    /// 日次減衰を適用（最後の操作日から経過日数分）
    func applyDailyDecay(creature: Creature) {
        guard let lastDate = creature.lastInteractionDate else {
            creature.lastInteractionDate = .now
            return
        }

        let calendar = Calendar.current
        let daysSince = calendar.dateComponents([.day], from: lastDate, to: .now).day ?? 0

        guard daysSince > 0 else { return }

        let decay = CreatureEngine.dailyDecay()
        creature.hp += decay.hpDelta * daysSince
        creature.happiness += decay.happinessDelta * daysSince
        creature.lastInteractionDate = .now
        creature.clampStats()

        save()
    }
}
