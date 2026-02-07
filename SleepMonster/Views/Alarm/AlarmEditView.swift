import SwiftUI

struct AlarmEditView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedHour = 7
    @State private var selectedMinute = 0
    @State private var label = ""
    @State private var selectedDays: Set<Int> = []
    @State private var soundName = Constants.Sound.defaultAlarm

    let onSave: (Int, Int, String, [Int]) -> Void

    private let dayOptions: [(id: Int, name: String)] = [
        (2, "月"), (3, "火"), (4, "水"), (5, "木"), (6, "金"), (7, "土"), (1, "日"),
    ]

    var body: some View {
        NavigationStack {
            Form {
                // 時刻選択
                Section {
                    HStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Picker("時", selection: $selectedHour) {
                                ForEach(0..<24, id: \.self) { h in
                                    Text(String(format: "%02d", h)).tag(h)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 80, height: 150)
                            .clipped()

                            Text(":")
                                .font(.title)

                            Picker("分", selection: $selectedMinute) {
                                ForEach(0..<60, id: \.self) { m in
                                    Text(String(format: "%02d", m)).tag(m)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 80, height: 150)
                            .clipped()
                        }
                        Spacer()
                    }
                }

                // ラベル
                Section("ラベル") {
                    TextField("アラーム名", text: $label)
                }

                // 繰り返し
                Section("くり返し") {
                    HStack(spacing: 8) {
                        ForEach(dayOptions, id: \.id) { day in
                            DayToggle(
                                name: day.name,
                                isSelected: selectedDays.contains(day.id)
                            ) {
                                if selectedDays.contains(day.id) {
                                    selectedDays.remove(day.id)
                                } else {
                                    selectedDays.insert(day.id)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)

                    // クイック選択
                    HStack(spacing: 12) {
                        QuickSelectButton(title: "平日") {
                            selectedDays = [2, 3, 4, 5, 6]
                        }
                        QuickSelectButton(title: "週末") {
                            selectedDays = [1, 7]
                        }
                        QuickSelectButton(title: "毎日") {
                            selectedDays = Set(1...7)
                        }
                        QuickSelectButton(title: "クリア") {
                            selectedDays = []
                        }
                    }
                }

                // サウンド
                Section("サウンド") {
                    Picker("アラーム音", selection: $soundName) {
                        ForEach(Constants.Sound.allSounds, id: \.id) { sound in
                            Text(sound.name).tag(sound.id)
                        }
                    }
                }
            }
            .navigationTitle("新しいアラーム")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        onSave(selectedHour, selectedMinute, label, Array(selectedDays))
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}

// MARK: - 曜日トグル

struct DayToggle: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(isSelected ? Color.purple : Color.gray.opacity(0.2))
                )
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - クイック選択ボタン

struct QuickSelectButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption2)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(.purple.opacity(0.1))
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AlarmEditView { _, _, _, _ in }
}
