# やまねむ (SleepMonster)

目覚ましアプリ × ヤマネ育成。毎朝きちんと起きると「ヤマネ」にアクセサリーがもらえて、寝坊すると弱っていく iOS アプリです。

## 機能

- **アラーム管理** — 曜日リピート・スヌーズ・複数アラーム対応
- **ヤマネ育成** — 起床結果に応じて HP / しあわせ度が変動
- **アクセサリーコレクション** — 連続起床のマイルストーンでアクセサリーを獲得。子ヤマネの姿のまま着せ替えを楽しむ
- **統計 / カレンダーヒートマップ** — 起床記録を可視化
- **ホーム画面ウィジェット** — ヤマネの状態をひと目で確認
- **通知チェーン** — iOS の 30 秒制限を複数通知で回避し、長時間アラーム音を実現

## アクセサリー入手条件

| 連続起床 | ご褒美 |
|---------|--------|
| 3 日 | ナイトキャップ |
| 5 日 | ミニまくら |
| 7 日 | もこもこマフラー、雲の上（背景） |
| 10 日 | 星のステッキ |
| 14 日 | 星のペンダント |
| 21 日 | 花冠、お花畑（背景） |
| 30 日 | 天使の羽 |
| 45 日 | 月のマント、星空（背景） |
| 60 日 | 王冠、虹の橋（背景） |

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
├── Models/         # SwiftData モデル (Creature, Alarm, WakeUpRecord, Accessory)
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
