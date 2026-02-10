import SwiftUI
import SwiftData

struct AlarmListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: AlarmViewModel?
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    if vm.alarms.isEmpty {
                        ContentUnavailableView(
                            "アラームなし",
                            systemImage: "alarm",
                            description: Text("右上の＋ボタンからアラームを追加しよう")
                        )
                    } else {
                        List {
                            ForEach(vm.alarms, id: \.id) { alarm in
                                AlarmRow(alarm: alarm) {
                                    vm.toggleAlarm(alarm)
                                }
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    vm.deleteAlarm(vm.alarms[index])
                                }
                            }
                        }
                    }
                } else {
                    ProgressView()
                        .onAppear { viewModel = AlarmViewModel(modelContext: modelContext) }
                }
            }
            .navigationTitle("アラーム")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                viewModel?.reload()
            } content: {
                AlarmEditView { hour, minute, label, repeatDays in
                    viewModel?.createAlarm(
                        hour: hour,
                        minute: minute,
                        label: label,
                        repeatDays: repeatDays
                    )
                }
            }
        }
    }
}

// MARK: - アラーム行

struct AlarmRow: View {
    let alarm: Alarm
    let onToggle: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(alarm.timeString)
                    .font(.system(size: 40, weight: .light, design: .rounded))
                    .foregroundStyle(alarm.isEnabled ? .primary : .secondary)

                HStack(spacing: 6) {
                    if !alarm.label.isEmpty {
                        Text(alarm.label)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(alarm.repeatDaysText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
            .accessibilityLabel("アラーム切り替え")
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityHint("スワイプで削除")
    }
}

#Preview {
    AlarmListView()
        .modelContainer(for: [Alarm.self], inMemory: true)
}
