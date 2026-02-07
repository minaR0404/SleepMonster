import Foundation

enum EvolutionStage: Int, Codable, CaseIterable {
    case egg = 0
    case baby = 1
    case young = 2
    case adult = 3
    case master = 4

    var name: String {
        switch self {
        case .egg: return "タマゴ"
        case .baby: return "ベビモン"
        case .young: return "ヤングモン"
        case .adult: return "アダルトモン"
        case .master: return "マスターモン"
        }
    }

    var requiredStreak: Int {
        switch self {
        case .egg: return 0
        case .baby: return 3
        case .young: return 7
        case .adult: return 21
        case .master: return 60
        }
    }

    var requiredHP: Int {
        switch self {
        case .egg: return 0
        case .baby: return 0
        case .young: return 70
        case .adult: return 80
        case .master: return 90
        }
    }
}

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
