import AVFoundation
import Foundation

final class MyUtils {
    private static var backgroundMusicPlayer: AVAudioPlayer?

    static func playBackgroundMusic(_ filename: String) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            NSLog("Could not find file:%@", filename)
            return
        }

        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
        } catch {
            NSLog("Could not create audio player:%@", error.localizedDescription)
            return
        }

        try? AVAudioSession.sharedInstance().setCategory(.playback)

        backgroundMusicPlayer?.numberOfLoops = -1
        backgroundMusicPlayer?.prepareToPlay()
        backgroundMusicPlayer?.play()
    }

    static func backgroundMusicPlayerStop() {
        backgroundMusicPlayer?.stop()
    }

    static func backgroundMusicPlayerPause() {
        backgroundMusicPlayer?.pause()
    }

    static func backgroundMusicPlayerPlay() {
        backgroundMusicPlayer?.play()
    }
}
