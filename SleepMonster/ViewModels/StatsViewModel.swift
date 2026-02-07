import Foundation
import SwiftData
import Observation

@Observable
@MainActor
final class StatsViewModel {
    private let modelContext: ModelContext
    private(set) var records: [WakeUpRecord] = []

    var currentStreak: Int {
        var streak = 0
        let calendar = Calendar.current
        let sorted = records
            .filter { $0.result != .missed }
            .sorted { $0.date > $1.date }

        var expectedDate = calendar.startOfDay(for: .now)

        for record in sorted {
            let recordDay = calendar.startOfDay(for: record.date)
            if recordDay == expectedDate {
                streak += 1
                expectedDate = calendar.date(byAdding: .day, value: -1, to: expectedDate)!
            } else if recordDay < expectedDate {
                break
            }
        }

        return streak
    }

    var bestStreak: Int {
        var best = 0
        var current = 0
        let calendar = Calendar.current
        let sorted = records.sorted { $0.date < $1.date }

        var lastDate: Date?

        for record in sorted {
            let recordDay = calendar.startOfDay(for: record.date)

            if record.result == .missed {
                current = 0
                lastDate = recordDay
                continue
            }

            if let last = lastDate {
                let dayDiff = calendar.dateComponents([.day], from: last, to: recordDay).day ?? 0
                if dayDiff <= 1 {
                    current += 1
                } else {
                    current = 1
                }
            } else {
                current = 1
            }

            best = max(best, current)
            lastDate = recordDay
        }

        return best
    }

    var onTimeRate: Double {
        guard !records.isEmpty else { return 0 }
        let onTimeCount = records.filter { $0.result == .onTime }.count
        return Double(onTimeCount) / Double(records.count)
    }

    var totalRecords: Int { records.count }
    var onTimeCount: Int { records.filter { $0.result == .onTime }.count }
    var lateCount: Int { records.filter { $0.result == .late }.count }
    var missedCount: Int { records.filter { $0.result == .missed }.count }

    /// 月間のデータ（カレンダーヒートマップ用）
    func recordsForMonth(year: Int, month: Int) -> [Int: WakeUpResult] {
        let calendar = Calendar.current
        var result: [Int: WakeUpResult] = [:]

        for record in records {
            let components = calendar.dateComponents([.year, .month, .day], from: record.date)
            if components.year == year && components.month == month, let day = components.day {
                result[day] = record.result
            }
        }

        return result
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        reload()
    }

    func reload() {
        let descriptor = FetchDescriptor<WakeUpRecord>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        records = (try? modelContext.fetch(descriptor)) ?? []
    }
}
