import SwiftUI
import SwiftData

struct SettingsView: View {
    @StateObject private var notificationService = NotificationService.shared

    var body: some View {
        NavigationStack {
            Form {
                // 通知セクション
                Section("通知") {
                    HStack {
                        Text("通知許可")
                        Spacer()
                        Text(notificationService.isAuthorized ? "許可済み" : "未許可")
                            .foregroundStyle(notificationService.isAuthorized ? .green : .red)
                    }

                    if !notificationService.isAuthorized {
                        Button("設定で許可する") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                }

                // アプリ情報
                Section("アプリ情報") {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("アプリ名")
                        Spacer()
                        Text("やまねむ")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("設定")
        }
    }
}

#Preview {
    SettingsView()
}
