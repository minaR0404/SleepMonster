import AVFoundation

final class AlarmSoundService {
    static let shared = AlarmSoundService()

    private var audioPlayer: AVAudioPlayer?

    private init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
        } catch {
            print("AudioSession設定エラー: \(error)")
        }
    }

    /// フォアグラウンドでのアラーム音再生（ループ）
    func playAlarmSound(named soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "caf") else {
            print("サウンドファイルが見つかりません: \(soundName)")
            return
        }

        do {
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // 無限ループ
            audioPlayer?.play()
        } catch {
            print("サウンド再生エラー: \(error)")
        }
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }

    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
}
