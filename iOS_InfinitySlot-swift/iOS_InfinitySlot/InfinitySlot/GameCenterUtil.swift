import GameKit
import UIKit

final class GameCenterUtil: NSObject, GKGameCenterControllerDelegate {
    static let shared = GameCenterUtil()

    private var gameCenterAvailable = false

    private override init() {
        super.init()
        gameCenterAvailable = isGameCenterAvailable()
        if gameCenterAvailable {
            NotificationCenter.default.addObserver(self, selector: #selector(authenticationChanged), name: .GKPlayerAuthenticationDidChangeNotificationName, object: nil)
        }
    }

    func isGameCenterAvailable() -> Bool {
        let gcClass = NSClassFromString("GKLocalPlayer") != nil
        let reqSysVer = "4.1"
        let currSysVer = UIDevice.current.systemVersion
        let osVersionSupported = currSysVer.compare(reqSysVer, options: .numeric) != .orderedAscending
        return gcClass && osVersionSupported
    }

    func authenticateLocalUser(_ viewController: UIViewController) {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { controller, error in
            if let error = error {
                NSLog("%@", error.localizedDescription)
            }
            if let controller = controller {
                viewController.present(controller, animated: true, completion: nil)
            } else {
                if GKLocalPlayer.local.isAuthenticated {
                    GKLocalPlayer.local.loadDefaultLeaderboardIdentifier { _, error in
                        if let error = error {
                            NSLog("%@", error.localizedDescription)
                        } else {
                            NSLog("%@", "authenticated no error")
                        }
                    }
                } else {
                    NSLog("%@", "authenticated not")
                }
            }
        }
    }

    @objc private func authenticationChanged() {
        if GKLocalPlayer.local.isAuthenticated {
            NSLog("Authentication changed: player authenticated.")
        } else {
            NSLog("Authentication changed: player not authenticated")
        }
    }

    func reportScore(_ score: Int64, forCategory category: String) {
        let scoreReporter = GKScore(leaderboardIdentifier: category)
        scoreReporter.value = score
        GKScore.report([scoreReporter]) { error in
            if let _ = error {
                let saveScoreData = try? NSKeyedArchiver.archivedData(withRootObject: scoreReporter, requiringSecureCoding: false)
                if let saveScoreData = saveScoreData {
                    self.storeScoreForLater(saveScoreData)
                }
            } else {
                NSLog("提交成功")
            }
        }
    }

    private func storeScoreForLater(_ scoreData: Data) {
        var savedScoresArray = UserDefaults.standard.array(forKey: "savedScores") as? [Data] ?? []
        savedScoresArray.append(scoreData)
        UserDefaults.standard.set(savedScoresArray, forKey: "savedScores")
    }

    func submitAllSavedScores() {
        let savedScoreArray = UserDefaults.standard.array(forKey: "savedScores") as? [Data] ?? []
        UserDefaults.standard.removeObject(forKey: "savedScores")

        for scoreData in savedScoreArray {
            if let scoreReporter = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(scoreData) as? GKScore {
                GKScore.report([scoreReporter]) { error in
                    if let _ = error {
                        let saveScoreData = try? NSKeyedArchiver.archivedData(withRootObject: scoreReporter, requiringSecureCoding: false)
                        if let saveScoreData = saveScoreData {
                            self.storeScoreForLater(saveScoreData)
                        }
                    } else {
                        NSLog("提交成功")
                    }
                }
            }
        }
    }

    func showGameCenter(_ viewController: UIViewController) {
        let gameView = GKGameCenterViewController()
        gameView.gameCenterDelegate = self
        gameView.leaderboardIdentifier = "com.xxxx.test"
        gameView.leaderboardTimeScope = .allTime
        viewController.present(gameView, animated: true, completion: nil)
    }

    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
