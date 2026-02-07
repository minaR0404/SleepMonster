import Foundation
import SwiftData
import Observation

@Observable
@MainActor
final class AlarmViewModel {
    private let repository: AlarmRepository
    private(set) var alarms: [Alarm] = []

    var nextAlarmText: String {
        guard let next = repository.nextAlarm(),
              let fireDate = next.nextFireDate else {
            return "アラームなし"
        }

        let now = Date()
        let interval = fireDate.timeIntervalSince(now)

        if interval < 0 { return "アラームなし" }

        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60

        if hours > 0 {
            return "\(hours)時間\(minutes)分後"
        }
        return "\(minutes)分後"
    }

    init(modelContext: ModelContext) {
        self.repository = AlarmRepository(modelContext: modelContext)
        reload()
    }

    func reload() {
        alarms = repository.fetchAll()
    }

    // MARK: - CRUD

    func createAlarm(hour: Int, minute: Int, label: String = "", repeatDays: [Int] = []) {
        let alarm = repository.create(hour: hour, minute: minute, label: label, repeatDays: repeatDays)
        NotificationService.shared.scheduleAlarm(alarm)
        reload()
    }

    func updateAlarm(_ alarm: Alarm) {
        repository.save()
        NotificationService.shared.scheduleAlarm(alarm)
        reload()
    }

    func deleteAlarm(_ alarm: Alarm) {
        repository.delete(alarm)
        reload()
    }

    func toggleAlarm(_ alarm: Alarm) {
        alarm.isEnabled.toggle()
        repository.save()

        if alarm.isEnabled {
            NotificationService.shared.scheduleAlarm(alarm)
        } else {
            NotificationService.shared.cancelAlarm(alarm)
        }
        reload()
    }

    // MARK: - 全アラーム再スケジュール（アプリ起動時用）

    func rescheduleAll() {
        for alarm in alarms where alarm.isEnabled {
            NotificationService.shared.scheduleAlarm(alarm)
        }
    }

    // MARK: - 起床記録

    func recordWakeUp(
        alarmId: String,
        dismissTime: Date,
        snoozeCount: Int,
        hpChange: Int,
        happinessChange: Int
    ) {
        guard let alarm = repository.find(byIdString: alarmId) else { return }

        let result = CreatureEngine.classifyWakeUp(
            dismissTime: dismissTime,
            scheduledTime: makeScheduledDate(alarm: alarm, relativeTo: dismissTime),
            snoozeCount: snoozeCount
        )

        repository.recordWakeUp(
            alarm: alarm,
            dismissTime: dismissTime,
            snoozeCount: snoozeCount,
            result: result,
            hpChange: hpChange,
            happinessChange: happinessChange
        )
    }

    private func makeScheduledDate(alarm: Alarm, relativeTo date: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = alarm.hour
        components.minute = alarm.minute
        components.second = 0
        return calendar.date(from: components) ?? date
    }
}
