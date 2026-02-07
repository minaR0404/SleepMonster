import SwiftUI
import SwiftData

@main
struct SleepMonsterApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var notificationHandler = NotificationHandler.shared

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Creature.self,
            Alarm.self,
            WakeUpRecord.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("ModelContainer作成に失敗: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationHandler)
                .onAppear {
                    setupApp()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        Task {
                            await handleAppBecameActive()
                        }
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }

    private func setupApp() {
        Task {
            NotificationService.shared.registerCategories()
            await NotificationService.shared.requestAuthorization()
        }
    }

    private func handleAppBecameActive() async {
        // アプリ起動時にミスしたアラームをチェック
        await NotificationService.shared.checkAuthorizationStatus()
        let missedIds = await NotificationService.shared.checkMissedAlarms()

        if !missedIds.isEmpty {
            let context = sharedModelContainer.mainContext
            let descriptor = FetchDescriptor<Creature>()
            guard let creature = try? context.fetch(descriptor).first else { return }

            for _ in missedIds {
                let (hpDelta, happinessDelta) = CreatureEngine.missedAlarm()
                creature.hp += hpDelta
                creature.happiness += happinessDelta
                creature.streak = 0
                creature.totalMissed += 1
                creature.clampStats()
            }

            try? context.save()
        }
    }
}
