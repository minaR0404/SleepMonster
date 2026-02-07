import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("ホーム", systemImage: "house.fill")
                }
                .tag(0)

            AlarmListView()
                .tabItem {
                    Label("アラーム", systemImage: "alarm.fill")
                }
                .tag(1)

            StatsView()
                .tabItem {
                    Label("統計", systemImage: "chart.bar.fill")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(.purple)
    }
}

#Preview {
    ContentView()
}
