import SwiftUI
import SwiftData

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: StatsViewModel?
    @State private var displayYear: Int = Calendar.current.component(.year, from: .now)
    @State private var displayMonth: Int = Calendar.current.component(.month, from: .now)

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    ScrollView {
                        VStack(spacing: 24) {
                            // サマリーカード
                            HStack(spacing: 16) {
                                StatSummaryCard(title: "連続", value: "\(vm.currentStreak)日", color: .orange)
                                StatSummaryCard(title: "最高", value: "\(vm.bestStreak)日", color: .purple)
                                StatSummaryCard(title: "起床率", value: "\(Int(vm.onTimeRate * 100))%", color: .green)
                            }
                            .padding(.horizontal, 16)

                            // カレンダーヒートマップ
                            VStack(spacing: 12) {
                                HStack {
                                    Button {
                                        previousMonth()
                                    } label: {
                                        Image(systemName: "chevron.left")
                                    }
                                    .accessibilityLabel("前の月")

                                    Spacer()
                                    Text("\(String(displayYear))年\(displayMonth)月")
                                        .font(.headline)
                                    Spacer()

                                    Button {
                                        nextMonth()
                                    } label: {
                                        Image(systemName: "chevron.right")
                                    }
                                    .accessibilityLabel("次の月")
                                }
                                .padding(.horizontal, 16)

                                CalendarHeatmapView(
                                    year: displayYear,
                                    month: displayMonth,
                                    data: vm.recordsForMonth(year: displayYear, month: displayMonth)
                                )
                                .padding(.horizontal, 16)
                            }

                            // 詳細統計
                            VStack(alignment: .leading, spacing: 12) {
                                Text("統計詳細")
                                    .font(.headline)
                                    .padding(.horizontal, 16)

                                VStack(spacing: 8) {
                                    StatDetailRow(label: "総記録数", value: "\(vm.totalRecords)回", icon: "list.bullet")
                                    StatDetailRow(label: "時間通り", value: "\(vm.onTimeCount)回", icon: "checkmark.circle.fill")
                                    StatDetailRow(label: "遅刻", value: "\(vm.lateCount)回", icon: "clock.fill")
                                    StatDetailRow(label: "寝坊", value: "\(vm.missedCount)回", icon: "moon.zzz.fill")
                                }
                                .padding(.horizontal, 16)
                            }

                            Spacer(minLength: 40)
                        }
                        .padding(.top, 16)
                    }
                } else {
                    ProgressView()
                        .onAppear { viewModel = StatsViewModel(modelContext: modelContext) }
                }
            }
            .navigationTitle("統計")
        }
    }

    private func previousMonth() {
        if displayMonth == 1 {
            displayMonth = 12
            displayYear -= 1
        } else {
            displayMonth -= 1
        }
    }

    private func nextMonth() {
        if displayMonth == 12 {
            displayMonth = 1
            displayYear += 1
        } else {
            displayMonth += 1
        }
    }
}

// MARK: - サマリーカード

struct StatSummaryCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(value)
    }
}

// MARK: - 統計詳細行

struct StatDetailRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 24)
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    StatsView()
        .modelContainer(for: [WakeUpRecord.self], inMemory: true)
}
