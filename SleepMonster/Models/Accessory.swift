import Foundation

// MARK: - アクセサリーカテゴリ

enum AccessoryCategory: String, Codable, CaseIterable {
    case head       // あたま
    case neck       // くび
    case held       // もちもの
    case back       // せなか
    case background // 背景

    var displayName: String {
        switch self {
        case .head: return "あたま"
        case .neck: return "くび"
        case .held: return "もちもの"
        case .back: return "せなか"
        case .background: return "背景"
        }
    }
}

// MARK: - アクセサリー

struct Accessory: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let category: AccessoryCategory
    let requiredStreak: Int
}

// MARK: - アクセサリーカタログ（全アイテム定義）

enum AccessoryCatalog {
    static let all: [Accessory] = [
        // あたま
        Accessory(id: "nightcap", name: "ナイトキャップ", category: .head, requiredStreak: 3),
        Accessory(id: "crown_flower", name: "花冠", category: .head, requiredStreak: 21),
        Accessory(id: "crown_gold", name: "王冠", category: .head, requiredStreak: 60),

        // くび
        Accessory(id: "scarf_fluffy", name: "もこもこマフラー", category: .neck, requiredStreak: 7),
        Accessory(id: "pendant_star", name: "星のペンダント", category: .neck, requiredStreak: 14),

        // もちもの
        Accessory(id: "pillow_mini", name: "ミニまくら", category: .held, requiredStreak: 5),
        Accessory(id: "wand_star", name: "星のステッキ", category: .held, requiredStreak: 10),

        // せなか
        Accessory(id: "wings_angel", name: "天使の羽", category: .back, requiredStreak: 30),
        Accessory(id: "cape_moon", name: "月のマント", category: .back, requiredStreak: 45),

        // 背景
        Accessory(id: "bg_clouds", name: "雲の上", category: .background, requiredStreak: 7),
        Accessory(id: "bg_flowers", name: "お花畑", category: .background, requiredStreak: 21),
        Accessory(id: "bg_starry", name: "星空", category: .background, requiredStreak: 45),
        Accessory(id: "bg_rainbow", name: "虹の橋", category: .background, requiredStreak: 60),
    ]

    static func find(id: String) -> Accessory? {
        all.first { $0.id == id }
    }

    static func unlockable(forStreak streak: Int, excluding unlocked: [String]) -> [Accessory] {
        all.filter { $0.requiredStreak <= streak && !unlocked.contains($0.id) }
    }
}

// MARK: - 表情

enum CreatureExpression: String, Codable {
    case happy
    case neutral
    case sad
    case sleeping
    case dead

    static func from(hp: Int, happiness: Int) -> CreatureExpression {
        if hp <= 0 { return .dead }
        if happiness >= 70 { return .happy }
        if happiness >= 30 { return .neutral }
        return .sad
    }
}
