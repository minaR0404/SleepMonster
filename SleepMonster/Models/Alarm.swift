import Foundation
import SwiftData

@Model
final class Alarm {
    @Attribute(.unique) var id: UUID
    var hour: Int
    var minute: Int
    var label: String
    var isEnabled: Bool
    var repeatDays: [Int] // 1=日, 2=月, 3=火, 4=水, 5=木, 6=金, 7=土 (空=1回のみ)
    var soundName: String
    var snoozeEnabled: Bool
    var snoozeCount: Int
    var lastTriggeredDate: Date?

    var timeString: String {
        String(format: "%02d:%02d", hour, minute)
    }

    var repeatDaysText: String {
        if repeatDays.isEmpty { return "1回のみ" }
        let dayNames = ["日", "月", "火", "水", "木", "金", "土"]
        let sorted = repeatDays.sorted()
        if sorted == [2, 3, 4, 5, 6] { return "平日" }
        if sorted == [1, 7] { return "週末" }
        if sorted == Array(1...7) { return "毎日" }
        return sorted.map { dayNames[($0 - 1) % 7] }.joined(separator: " ")
    }

    var nextFireDate: Date? {
        let calendar = Calendar.current
        let now = Date()
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        components.second = 0

        if repeatDays.isEmpty {
            // 1回のみ: 今日のその時刻が過ぎていたら明日
            guard let today = calendar.nextDate(
                after: now,
                matching: components,
                matchingPolicy: .nextTime
            ) else { return nil }
            return today
        }

        // リピート: 次の該当曜日を探す
        var earliest: Date?
        for day in repeatDays {
            components.weekday = day
            if let next = calendar.nextDate(
                after: now,
                matching: components,
                matchingPolicy: .nextTime
            ) {
                if earliest == nil || next < earliest! {
                    earliest = next
                }
            }
        }
        return earliest
    }

    init(hour: Int, minute: Int, label: String = "", repeatDays: [Int] = []) {
        self.id = UUID()
        self.hour = hour
        self.minute = minute
        self.label = label
        self.isEnabled = true
        self.repeatDays = repeatDays
        self.soundName = "default_alarm"
        self.snoozeEnabled = true
        self.snoozeCount = 0
    }
}
