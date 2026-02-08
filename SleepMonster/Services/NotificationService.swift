import Foundation
import UserNotifications
import Combine

@MainActor
final class NotificationService: ObservableObject {
    static let shared = NotificationService()

    @Published var isAuthorized = false

    private let center = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - 権限リクエスト

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(
                options: [.alert, .sound, .badge, .timeSensitive]
            )
            isAuthorized = granted
            return granted
        } catch {
            print("通知権限リクエストエラー: \(error)")
            return false
        }
    }

    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    // MARK: - アラームのスケジュール

    func scheduleAlarm(_ alarm: Alarm) {
        // 既存の通知をキャンセル
        cancelAlarm(alarm)

        guard alarm.isEnabled else { return }

        if alarm.repeatDays.isEmpty {
            // 1回のみ
            scheduleOneShot(alarm)
        } else {
            // リピート: 各曜日分スケジュール
            for day in alarm.repeatDays {
                scheduleRepeating(alarm, weekday: day)
            }
        }
    }

    private func scheduleOneShot(_ alarm: Alarm) {
        var dateComponents = DateComponents()
        dateComponents.hour = alarm.hour
        dateComponents.minute = alarm.minute
        dateComponents.second = 0

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )

        let content = makeAlarmContent(alarm)
        let request = UNNotificationRequest(
            identifier: "\(Constants.Notification.alarmNotificationPrefix)\(alarm.id.uuidString)",
            content: content,
            trigger: trigger
        )

        center.add(request)

        // サウンドチェーン（30秒間隔で追加通知）
        scheduleSoundChain(alarm: alarm, baseDateComponents: dateComponents, repeats: false)

        // ミス検知用センチネル通知
        scheduleSentinel(alarm: alarm, dateComponents: dateComponents, repeats: false)
    }

    private func scheduleRepeating(_ alarm: Alarm, weekday: Int) {
        var dateComponents = DateComponents()
        dateComponents.hour = alarm.hour
        dateComponents.minute = alarm.minute
        dateComponents.second = 0
        dateComponents.weekday = weekday

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let content = makeAlarmContent(alarm)
        let request = UNNotificationRequest(
            identifier: "\(Constants.Notification.alarmNotificationPrefix)\(alarm.id.uuidString)_\(weekday)",
            content: content,
            trigger: trigger
        )

        center.add(request)

        // サウンドチェーン
        scheduleSoundChain(alarm: alarm, baseDateComponents: dateComponents, repeats: true)

        // センチネル
        scheduleSentinel(alarm: alarm, dateComponents: dateComponents, repeats: true, weekday: weekday)
    }

    // MARK: - サウンドチェーン（30秒間隔で追加通知 → 長時間アラーム音）

    private func scheduleSoundChain(alarm: Alarm, baseDateComponents: DateComponents, repeats: Bool) {
        let baseMinute = baseDateComponents.minute ?? 0
        let baseSecond = 0

        for i in 1..<Constants.Notification.soundChainCount {
            var chainComponents = baseDateComponents
            let totalSeconds = baseSecond + (i * Constants.Notification.soundChainIntervalSeconds)
            chainComponents.second = totalSeconds % 60
            chainComponents.minute = baseMinute + (totalSeconds / 60)

            let content = makeAlarmContent(alarm)
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: chainComponents,
                repeats: repeats
            )

            let weekdaySuffix = baseDateComponents.weekday.map { "_\($0)" } ?? ""
            let request = UNNotificationRequest(
                identifier: "\(Constants.Notification.chainNotificationPrefix)\(alarm.id.uuidString)\(weekdaySuffix)_\(i)",
                content: content,
                trigger: trigger
            )

            center.add(request)
        }
    }

    // MARK: - センチネル通知（ミス検知用、アラーム10分後）

    private func scheduleSentinel(
        alarm: Alarm,
        dateComponents: DateComponents,
        repeats: Bool,
        weekday: Int? = nil
    ) {
        var sentinelComponents = dateComponents
        let baseMinute = dateComponents.minute ?? 0
        sentinelComponents.minute = baseMinute + Constants.Notification.sentinelDelayMinutes

        // 60分超えの処理
        if let min = sentinelComponents.minute, min >= 60 {
            sentinelComponents.minute = min - 60
            sentinelComponents.hour = (sentinelComponents.hour ?? 0) + 1
            if let hour = sentinelComponents.hour, hour >= 24 {
                sentinelComponents.hour = hour - 24
            }
        }

        let content = UNMutableNotificationContent()
        content.title = "ヤマネが心配してるよ…"
        content.body = "まだ寝てる？ヤマネが元気なくなっちゃうよ！"
        content.sound = .default
        content.interruptionLevel = .timeSensitive
        content.categoryIdentifier = Constants.Notification.sentinelCategoryIdentifier

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: sentinelComponents,
            repeats: repeats
        )

        let weekdaySuffix = weekday.map { "_\($0)" } ?? ""
        let request = UNNotificationRequest(
            identifier: "\(Constants.Notification.sentinelNotificationPrefix)\(alarm.id.uuidString)\(weekdaySuffix)",
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    // MARK: - 通知コンテンツ作成

    private func makeAlarmContent(_ alarm: Alarm) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = alarm.label.isEmpty ? "おはよう！" : alarm.label
        content.body = "ヤマネが待ってるよ！起きて世話をしよう！"
        content.sound = UNNotificationSound(named: UNNotificationSoundName("\(alarm.soundName).caf"))
        content.interruptionLevel = .timeSensitive
        content.categoryIdentifier = Constants.Notification.alarmCategoryIdentifier
        content.userInfo = [
            "alarmId": alarm.id.uuidString,
            "scheduledHour": alarm.hour,
            "scheduledMinute": alarm.minute,
        ]
        return content
    }

    // MARK: - スヌーズ

    func scheduleSnooze(alarmId: UUID, soundName: String) {
        let content = UNMutableNotificationContent()
        content.title = "スヌーズ終了！"
        content.body = "ヤマネがまだ待ってるよ…今度こそ起きよう！"
        content.sound = UNNotificationSound(named: UNNotificationSoundName("\(soundName).caf"))
        content.interruptionLevel = .timeSensitive
        content.categoryIdentifier = Constants.Notification.alarmCategoryIdentifier
        content.userInfo = ["alarmId": alarmId.uuidString]

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(Constants.Notification.snoozeDurationMinutes * 60),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "\(Constants.Notification.snoozeNotificationPrefix)\(alarmId.uuidString)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    // MARK: - キャンセル

    func cancelAlarm(_ alarm: Alarm) {
        let prefix = alarm.id.uuidString
        center.getPendingNotificationRequests { [weak self] requests in
            let idsToRemove = requests
                .filter { $0.identifier.contains(prefix) }
                .map(\.identifier)
            self?.center.removePendingNotificationRequests(withIdentifiers: idsToRemove)
            self?.center.removeDeliveredNotifications(withIdentifiers: idsToRemove)
        }
    }

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }

    // MARK: - 通知カテゴリ登録

    func registerCategories() {
        let dismissAction = UNNotificationAction(
            identifier: Constants.Notification.dismissActionIdentifier,
            title: "起きる！",
            options: [.foreground]
        )

        let snoozeAction = UNNotificationAction(
            identifier: Constants.Notification.snoozeActionIdentifier,
            title: "スヌーズ（5分）",
            options: []
        )

        let alarmCategory = UNNotificationCategory(
            identifier: Constants.Notification.alarmCategoryIdentifier,
            actions: [dismissAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        let sentinelCategory = UNNotificationCategory(
            identifier: Constants.Notification.sentinelCategoryIdentifier,
            actions: [dismissAction],
            intentIdentifiers: [],
            options: []
        )

        center.setNotificationCategories([alarmCategory, sentinelCategory])
    }

    // MARK: - 未応答通知の確認（アプリ起動時に呼ぶ）

    func checkMissedAlarms() async -> [String] {
        let delivered = await center.deliveredNotifications()
        let missedAlarmIds = delivered
            .filter { $0.request.content.categoryIdentifier == Constants.Notification.alarmCategoryIdentifier }
            .compactMap { $0.request.content.userInfo["alarmId"] as? String }

        if !missedAlarmIds.isEmpty {
            center.removeAllDeliveredNotifications()
        }

        return missedAlarmIds
    }
}
