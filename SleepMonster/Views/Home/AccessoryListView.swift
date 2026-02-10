import SwiftUI

struct AccessoryListView: View {
    var vm: CreatureViewModel

    var body: some View {
        List {
            ForEach(AccessoryCategory.allCases, id: \.self) { category in
                Section(category.displayName) {
                    let items = AccessoryCatalog.all.filter { $0.category == category }
                    ForEach(items) { accessory in
                        AccessoryRow(
                            accessory: accessory,
                            isUnlocked: vm.creature.unlockedAccessoryIDs.contains(accessory.id),
                            isEquipped: vm.creature.equippedAccessoryID(for: category) == accessory.id
                        ) {
                            if vm.creature.equippedAccessoryID(for: category) == accessory.id {
                                vm.unequip(category: category)
                            } else {
                                vm.equip(accessory)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("アクセサリー")
    }
}

// MARK: - アクセサリー行

private struct AccessoryRow: View {
    let accessory: Accessory
    let isUnlocked: Bool
    let isEquipped: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: isUnlocked ? "checkmark.seal.fill" : "lock.fill")
                    .foregroundStyle(isUnlocked ? .purple : .secondary)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(accessory.name)
                        .foregroundStyle(isUnlocked ? .primary : .secondary)
                    Text("連続\(accessory.requiredStreak)日で解放")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isEquipped {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.orange)
                }
            }
        }
        .disabled(!isUnlocked)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(accessory.name)、\(accessory.category.displayName)")
        .accessibilityValue(
            !isUnlocked ? "未解放、連続\(accessory.requiredStreak)日で解放" :
            isEquipped ? "装備中" : "装備可能"
        )
        .accessibilityHint(isUnlocked ? "タップで装備を切り替え" : "")
    }
}

// Preview は HomeView 経由で確認
