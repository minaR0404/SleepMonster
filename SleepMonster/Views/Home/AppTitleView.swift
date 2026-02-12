import SwiftUI

struct AppTitleView: View {
    var body: some View {
        HStack(spacing: 6) {
            // 三日月アイコン
            Image(systemName: "moon.fill")
                .font(.system(size: 10))
                .foregroundStyle(.yellow.opacity(0.8))
                .rotationEffect(.degrees(-30))

            // メインタイトル
            Text("やまねむ")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            // 睡眠を表すzzz
            Text("z z")
                .font(.system(size: 8, weight: .medium, design: .rounded))
                .foregroundStyle(.purple.opacity(0.5))
                .offset(y: -6)
        }
    }
}

#Preview {
    NavigationStack {
        Text("Content")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    AppTitleView()
                }
            }
    }
}
