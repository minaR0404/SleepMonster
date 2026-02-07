import SwiftUI

struct CalendarHeatmapView: View {
    let year: Int
    let month: Int
    let data: [Int: WakeUpResult] // day -> result

    private let dayNames = ["日", "月", "火", "水", "木", "金", "土"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        VStack(spacing: 4) {
            // 曜日ヘッダー
            HStack(spacing: 4) {
                ForEach(dayNames, id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // 日付グリッド
            LazyVGrid(columns: columns, spacing: 4) {
                // 月初の曜日までの空セル
                ForEach(0..<firstWeekdayOffset, id: \.self) { _ in
                    Color.clear
                        .frame(height: 36)
                }

                // 各日
                ForEach(1...daysInMonth, id: \.self) { day in
                    DayCell(day: day, result: data[day])
                }
            }
        }
    }

    private var firstWeekdayOffset: Int {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        guard let date = calendar.date(from: components) else { return 0 }
        // Calendar.currentの週の始まり（日曜=1）に合わせる
        let weekday = calendar.component(.weekday, from: date)
        return weekday - 1
    }

    private var daysInMonth: Int {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        guard let date = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: date) else {
            return 30
        }
        return range.count
    }
}

// MARK: - 日付セル

struct DayCell: View {
    let day: Int
    let result: WakeUpResult?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(cellColor)

            VStack(spacing: 1) {
                Text("\(day)")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(textColor)
            }
        }
        .frame(height: 36)
    }

    private var cellColor: Color {
        guard let result else {
            return Color.gray.opacity(0.1)
        }
        switch result {
        case .onTime: return .green.opacity(0.6)
        case .late: return .yellow.opacity(0.5)
        case .veryLate: return .orange.opacity(0.5)
        case .missed: return .red.opacity(0.4)
        }
    }

    private var textColor: Color {
        result != nil ? .white : .secondary
    }
}

#Preview {
    CalendarHeatmapView(
        year: 2026,
        month: 2,
        data: [
            1: .onTime, 2: .onTime, 3: .late,
            4: .onTime, 5: .missed, 6: .onTime,
            7: .onTime,
        ]
    )
    .padding()
}
