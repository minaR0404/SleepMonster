import Foundation
import SwiftData

@MainActor
final class AlarmRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() -> [Alarm] {
        let descriptor = FetchDescriptor<Alarm>(
            sortBy: [SortDescriptor(\.hour), SortDescriptor(\.minute)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func find(byId id: UUID) -> Alarm? {
        let descriptor = FetchDescriptor<Alarm>(
            predicate: #Predicate { $0.id == id }
        )
        return try? modelContext.fetch(descriptor).first
    }

    func find(byIdString idString: String) -> Alarm? {
        guard let uuid = UUID(uuidString: idString) else { return nil }
        return find(byId: uuid)
    }

    func create(hour: Int, minute: Int, label: String = "", repeatDays: [Int] = []) -> Alarm {
        let alarm = Alarm(hour: hour, minute: minute, label: label, repeatDays: repeatDays)
        modelContext.insert(alarm)
        save()
        return alarm
    }

    func delete(_ alarm: Alarm) {
        NotificationService.shared.cancelAlarm(alarm)
        modelContext.delete(alarm)
        save()
    }

    func save() {
        try? modelContext.save()
    }

    /// 次にトリガーされるアラームを取得
    func nextAlarm() -> Alarm? {
        fetchAll()
            .filter(\.isEnabled)
            .compactMap { alarm -> (Alarm, Date)? in
                guard let fireDate = alarm.nextFireDate else { return nil }
                return (alarm, fireDate)
            }
            .min(by: { $0.1 < $1.1 })
            .map(\.0)
    }

    /// 起床記録を保存
    func recordWakeUp(
        alarm: Alarm,
        dismissTime: Date,
        snoozeCount: Int,
        result: WakeUpResult,
        hpChange: Int,
        happinessChange: Int
    ) {
        let calendar = Calendar.current
        var scheduledComponents = DateComponents()
        scheduledComponents.year = calendar.component(.year, from: dismissTime)
        scheduledComponents.month = calendar.component(.month, from: dismissTime)
        scheduledComponents.day = calendar.component(.day, from: dismissTime)
        scheduledComponents.hour = alarm.hour
        scheduledComponents.minute = alarm.minute
        let scheduledTime = calendar.date(from: scheduledComponents) ?? dismissTime

        let record = WakeUpRecord(date: .now, scheduledTime: scheduledTime)
        record.actualDismissTime = dismissTime
        record.snoozeCount = snoozeCount
        record.result = result
        record.hpChange = hpChange
        record.happinessChange = happinessChange

        modelContext.insert(record)

        alarm.snoozeCount = 0
        alarm.lastTriggeredDate = .now

        // 1回限りのアラームは無効化
        if alarm.repeatDays.isEmpty {
            alarm.isEnabled = false
        }

        save()
    }
}
