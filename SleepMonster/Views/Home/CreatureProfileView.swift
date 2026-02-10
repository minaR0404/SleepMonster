import SwiftUI

struct CreatureProfileView: View {
    var vm: CreatureViewModel
    @State private var editingName: String = ""
    @FocusState private var isNameFocused: Bool

    var body: some View {
        Form {
            Section("名前") {
                TextField("ヤマネの名前", text: $editingName)
                    .focused($isNameFocused)
                    .onSubmit {
                        vm.rename(editingName)
                    }
                    .submitLabel(.done)
            }

            Section("アクセサリー") {
                NavigationLink {
                    AccessoryListView(vm: vm)
                } label: {
                    HStack {
                        Text("コレクション")
                        Spacer()
                        Text("\(vm.creature.unlockedAccessoryIDs.count)/\(AccessoryCatalog.all.count)")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("記録") {
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

                HStack {
                    Text("最高連続起床")
                    Spacer()
                    Text("\(vm.creature.bestStreak)日")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("プロフィール")
        .onAppear {
            editingName = vm.creature.name
        }
        .onChange(of: isNameFocused) { _, focused in
            if !focused {
                vm.rename(editingName)
            }
        }
    }
}

// Preview は HomeView 経由で確認
