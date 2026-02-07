import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var creatureVM: CreatureViewModel?
    @State private var editingName = ""
    @State private var showingNameEdit = false
    @StateObject private var notificationService = NotificationService.shared

    var body: some View {
        NavigationStack {
            Form {
                if let vm = creatureVM {
                    // 生き物セクション
                    Section("ネムリン") {
                        HStack {
                            Text("名前")
                            Spacer()
                            Text(vm.creature.name)
                                .foregroundStyle(.secondary)
                        }
                        .onTapGesture {
                            editingName = vm.creature.name
                            showingNameEdit = true
                        }

                        HStack {
                            Text("進化段階")
                            Spacer()
                            Text(vm.creature.evolutionStage.name)
                                .foregroundStyle(.secondary)
                        }

                        HStack {
                            Text("誕生日")
                            Spacer()
                            Text(vm.creature.bornDate, style: .date)
                                .foregroundStyle(.secondary)
                        }

                        HStack {
                            Text("総起床回数")
                            Spacer()
                            Text("\(vm.creature.totalWakeUps)回")
                                .foregroundStyle(.secondary)
                        }
                    }

                    // 通知セクション
                    Section("通知") {
                        HStack {
                            Text("通知許可")
                            Spacer()
                            Text(notificationService.isAuthorized ? "許可済み" : "未許可")
                                .foregroundStyle(notificationService.isAuthorized ? .green : .red)
                        }

                        if !notificationService.isAuthorized {
                            Button("設定で許可する") {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                    }

                    // アプリ情報
                    Section("アプリ情報") {
                        HStack {
                            Text("バージョン")
                            Spacer()
                            Text("1.0.0")
                                .foregroundStyle(.secondary)
                        }

                        HStack {
                            Text("アプリ名")
                            Spacer()
                            Text("ねむモン")
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    ProgressView()
                        .onAppear {
                            creatureVM = CreatureViewModel(modelContext: modelContext)
                        }
                }
            }
            .navigationTitle("設定")
            .alert("名前を変更", isPresented: $showingNameEdit) {
                TextField("名前", text: $editingName)
                Button("キャンセル", role: .cancel) {}
                Button("保存") {
                    creatureVM?.rename(editingName)
                }
            } message: {
                Text("ネムリンの名前を入力してください")
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [Creature.self], inMemory: true)
}
