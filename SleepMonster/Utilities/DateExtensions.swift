import Foundation

extension Date {
    /// 時:分 の文字列（例: "07:30"）
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }

    /// 日付の文字列（例: "2/7"）
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: self)
    }

    /// 今日の開始時刻
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// 指定した時:分のDateを今日の日付で生成
    static func today(hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: .now)
        components.hour = hour
        components.minute = minute
        components.second = 0
        return calendar.date(from: components) ?? .now
    }
}
