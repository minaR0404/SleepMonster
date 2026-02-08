import UIKit
import UserNotifications
import SwiftData
import Combine

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = NotificationHandler.shared
        return true
    }
}

// MARK: - 通知ハンドラ

final class NotificationHandler: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
    static let shared = NotificationHandler()

    @Published var pendingAlarmResponse: AlarmResponse?

    struct AlarmResponse {
        let alarmId: String
        let actionIdentifier: String
        let dismissTime: Date
    }

    // フォアグラウンドで通知を表示
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        let categoryId = notification.request.content.categoryIdentifier

        if categoryId == Constants.Notification.alarmCategoryIdentifier {
            // フォアグラウンドならアラーム音をAVAudioPlayerで再生
            if let soundName = notification.request.content.userInfo["soundName"] as? String {
                AlarmSoundService.shared.playAlarmSound(named: soundName)
            }
            return [.banner, .sound, .badge]
        }

        return [.banner, .sound]
    }

    // 通知アクション応答
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        let categoryId = response.notification.request.content.categoryIdentifier

        guard categoryId == Constants.Notification.alarmCategoryIdentifier,
              let alarmId = userInfo["alarmId"] as? String else {
            return
        }

        AlarmSoundService.shared.stop()

        switch response.actionIdentifier {
        case Constants.Notification.dismissActionIdentifier,
             UNNotificationDefaultActionIdentifier:
            // 起床! → 結果を保存
            pendingAlarmResponse = AlarmResponse(
                alarmId: alarmId,
                actionIdentifier: Constants.Notification.dismissActionIdentifier,
                dismissTime: .now
            )

            // このアラームの残りのチェーン通知をキャンセル
            cancelRelatedNotifications(alarmId: alarmId)

        case Constants.Notification.snoozeActionIdentifier:
            // スヌーズ → 5分後に再通知
            pendingAlarmResponse = AlarmResponse(
                alarmId: alarmId,
                actionIdentifier: Constants.Notification.snoozeActionIdentifier,
                dismissTime: .now
            )

            let soundName = userInfo["soundName"] as? String ?? Constants.Sound.defaultAlarm
            await NotificationService.shared.scheduleSnooze(
                alarmId: UUID(uuidString: alarmId) ?? UUID(),
                soundName: soundName
            )

        default:
            // カスタムDismiss（通知をスワイプで消した場合）
            pendingAlarmResponse = AlarmResponse(
                alarmId: alarmId,
                actionIdentifier: "custom_dismiss",
                dismissTime: .now
            )
        }
    }

    private func cancelRelatedNotifications(alarmId: String) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let idsToRemove = requests
                .filter { $0.identifier.contains(alarmId) }
                .map(\.identifier)
            center.removePendingNotificationRequests(withIdentifiers: idsToRemove)
        }
    }
}
