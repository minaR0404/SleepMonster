import Foundation
import SwiftData

@Model
final class WakeUpRecord {
    var date: Date
    var scheduledTime: Date
    var actualDismissTime: Date?
    var snoozeCount: Int
    var resultRaw: String
    var hpChange: Int
    var happinessChange: Int

    var result: WakeUpResult {
        get { WakeUpResult(rawValue: resultRaw) ?? .missed }
        set { resultRaw = newValue.rawValue }
    }

    init(date: Date = .now, scheduledTime: Date) {
        self.date = date
        self.scheduledTime = scheduledTime
        self.snoozeCount = 0
        self.resultRaw = WakeUpResult.missed.rawValue
        self.hpChange = 0
        self.happinessChange = 0
    }
}

enum WakeUpResult: String, Codable {
    case onTime    // 1分以内
    case late      // 1〜5分
    case veryLate  // 5〜10分
    case missed    // 10分以上 or 無応答

    var displayText: String {
        switch self {
        case .onTime: return "起床成功!"
        case .late: return "ちょっと遅刻…"
        case .veryLate: return "かなり遅刻!"
        case .missed: return "寝坊…"
        }
    }

    var emoji: String {
        switch self {
        case .onTime: return "☀️"
        case .late: return "🌤"
        case .veryLate: return "☁️"
        case .missed: return "🌧"
        }
    }
}
