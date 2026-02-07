import Foundation

enum Constants {
    // MARK: - Notification
    enum Notification {
        static let alarmCategoryIdentifier = "ALARM_CATEGORY"
        static let dismissActionIdentifier = "ALARM_DISMISS"
        static let snoozeActionIdentifier = "ALARM_SNOOZE"
        static let sentinelCategoryIdentifier = "SENTINEL_CATEGORY"
        static let alarmNotificationPrefix = "alarm_"
        static let snoozeNotificationPrefix = "snooze_"
        static let sentinelNotificationPrefix = "sentinel_"
        static let chainNotificationPrefix = "chain_"
        static let snoozeDurationMinutes = 5
        static let sentinelDelayMinutes = 10
        static let soundChainCount = 3
        static let soundChainIntervalSeconds = 30
    }

    // MARK: - Creature
    enum CreatureDefaults {
        static let maxHP = 100
        static let maxHappiness = 100
        static let defaultName = "ネムリン"
        static let revivalChallengeDays = 7
    }

    // MARK: - App Group
    static let appGroupIdentifier = "group.com.sleepmonster.app"

    // MARK: - Sounds
    enum Sound {
        static let defaultAlarm = "default_alarm"
        static let gentleAlarm = "gentle_alarm"
        static let energeticAlarm = "energetic_alarm"

        static let allSounds: [(id: String, name: String)] = [
            (defaultAlarm, "デフォルト"),
            (gentleAlarm, "やさしい"),
            (energeticAlarm, "元気な"),
        ]
    }
}
