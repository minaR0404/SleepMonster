import Foundation
import SwiftData

@Model
final class Creature {
    var name: String
    var hp: Int
    var happiness: Int
    var streak: Int
    var totalWakeUps: Int
    var totalMissed: Int
    var evolutionStageRaw: Int
    var isDead: Bool
    var bornDate: Date
    var lastInteractionDate: Date?

    var evolutionStage: EvolutionStage {
        get { EvolutionStage(rawValue: evolutionStageRaw) ?? .egg }
        set { evolutionStageRaw = newValue.rawValue }
    }

    var expression: CreatureExpression {
        CreatureExpression.from(hp: hp, happiness: happiness)
    }

    var hpRatio: Double {
        Double(hp) / 100.0
    }

    var happinessRatio: Double {
        Double(happiness) / 100.0
    }

    init(name: String = "ネムリン") {
        self.name = name
        self.hp = 100
        self.happiness = 100
        self.streak = 0
        self.totalWakeUps = 0
        self.totalMissed = 0
        self.evolutionStageRaw = EvolutionStage.egg.rawValue
        self.isDead = false
        self.bornDate = .now
    }

    func clampStats() {
        hp = min(100, max(0, hp))
        happiness = min(100, max(0, happiness))
        if hp <= 0 {
            isDead = true
        }
    }
}
