import Foundation
import SwiftData

@Model
final class Creature {
    var name: String
    var hp: Int
    var happiness: Int
    var streak: Int
    var bestStreak: Int
    var totalWakeUps: Int
    var totalMissed: Int
    var isDead: Bool
    var bornDate: Date
    var lastInteractionDate: Date?

    // アクセサリー
    var unlockedAccessoryIDs: [String]
    var equippedHead: String?
    var equippedNeck: String?
    var equippedHeld: String?
    var equippedBack: String?
    var equippedBackground: String?

    var expression: CreatureExpression {
        CreatureExpression.from(hp: hp, happiness: happiness)
    }

    var hpRatio: Double {
        Double(hp) / 100.0
    }

    var happinessRatio: Double {
        Double(happiness) / 100.0
    }

    /// カテゴリごとの装備中アクセサリーIDを取得
    func equippedAccessoryID(for category: AccessoryCategory) -> String? {
        switch category {
        case .head: return equippedHead
        case .neck: return equippedNeck
        case .held: return equippedHeld
        case .back: return equippedBack
        case .background: return equippedBackground
        }
    }

    /// カテゴリごとにアクセサリーを装備/解除
    func equip(_ accessoryID: String?, for category: AccessoryCategory) {
        switch category {
        case .head: equippedHead = accessoryID
        case .neck: equippedNeck = accessoryID
        case .held: equippedHeld = accessoryID
        case .back: equippedBack = accessoryID
        case .background: equippedBackground = accessoryID
        }
    }

    /// 装備中の全アクセサリーを取得
    var equippedAccessories: [Accessory] {
        let ids = [equippedHead, equippedNeck, equippedHeld, equippedBack, equippedBackground]
            .compactMap { $0 }
        return ids.compactMap { AccessoryCatalog.find(id: $0) }
    }

    init(name: String = "ヤマネ") {
        self.name = name
        self.hp = 100
        self.happiness = 100
        self.streak = 0
        self.bestStreak = 0
        self.totalWakeUps = 0
        self.totalMissed = 0
        self.isDead = false
        self.bornDate = .now
        self.unlockedAccessoryIDs = []
    }

    func clampStats() {
        hp = min(100, max(0, hp))
        happiness = min(100, max(0, happiness))
        if hp <= 0 {
            isDead = true
        }
    }
}
