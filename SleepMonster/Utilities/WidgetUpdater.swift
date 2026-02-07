import WidgetKit

/// ウィジェット用のデータ更新ヘルパー
struct WidgetUpdater {
    private static let defaults = UserDefaults(suiteName: Constants.appGroupIdentifier)

    static func update(creature: Creature, nextAlarmTime: String?) {
        defaults?.set(creature.name, forKey: "widget_creature_name")
        defaults?.set(creature.hp, forKey: "widget_creature_hp")
        defaults?.set(creature.happiness, forKey: "widget_creature_happiness")
        defaults?.set(creature.evolutionStageRaw, forKey: "widget_creature_stage")
        defaults?.set(creature.streak, forKey: "widget_creature_streak")
        defaults?.set(creature.isDead, forKey: "widget_creature_dead")

        if let time = nextAlarmTime {
            defaults?.set(time, forKey: "widget_next_alarm")
        } else {
            defaults?.removeObject(forKey: "widget_next_alarm")
        }

        WidgetCenter.shared.reloadAllTimelines()
    }
}
