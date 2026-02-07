# ねむモン (SleepMonster)

目覚ましアプリ × たまごっち育成。毎朝きちんと起きると「ネムリン」が成長し、寝坊すると弱っていく iOS アプリです。

## 機能

- **アラーム管理** — 曜日リピート・スヌーズ・複数アラーム対応
- **生き物育成** — 起床結果に応じて HP / しあわせ度が変動
- **進化システム** — 連続起床で タマゴ → ベビモン → ヤングモン → アダルトモン → マスターモン に進化（退化なし）
- **統計 / カレンダーヒートマップ** — 起床記録を可視化
- **ホーム画面ウィジェット** — ネムリンの状態をひと目で確認
- **通知チェーン** — iOS の 30 秒制限を複数通知で回避し、長時間アラーム音を実現

## 進化条件

| ステージ | 連続起床 | HP |
|----------|---------|-----|
| ベビモン | 3 日 | — |
| ヤングモン | 7 日 | 70+ |
| アダルトモン | 21 日 | 80+ |
| マスターモン | 60 日 | 90+ |

## 技術スタック

- **SwiftUI** (iOS 17+)
- **SwiftData** — データ永続化
- **UNUserNotificationCenter** — ローカル通知によるアラーム
- **WidgetKit** — ホーム画面ウィジェット
- **App Groups** — アプリ ↔ ウィジェット間のデータ共有

## アーキテクチャ

MVVM + Repository パターン

```
SleepMonster/
├── App/            # アプリエントリーポイント・AppDelegate
├── Models/         # SwiftData モデル (Creature, Alarm, WakeUpRecord)
├── ViewModels/     # CreatureViewModel, AlarmViewModel, StatsViewModel
├── Views/          # SwiftUI ビュー (Home, Alarm, Stats, Settings)
├── Services/       # CreatureEngine, NotificationService, AlarmSoundService
├── Repositories/   # CreatureRepository, AlarmRepository
└── Utilities/      # Constants, DateExtensions, WidgetUpdater
SleepMonsterWidget/ # ホーム画面ウィジェット
SleepMonsterTests/  # ユニットテスト (Swift Testing)
```

## セットアップ

1. macOS + Xcode 15 以上が必要
2. リポジトリをクローン
3. Xcode でプロジェクトを開く
4. App Groups の identifier を自分のチーム ID に合わせて変更
5. 実機またはシミュレータでビルド・実行

## ライセンス

MIT
