import GoogleMobileAds
import SpriteKit
import UIKit

// Lightweight stubs to allow compiling without iAd linked.
protocol ADBannerViewDelegate: AnyObject {}

final class ADBannerView: UIView {
    weak var delegate: ADBannerViewDelegate?
    var bannerLoaded: Bool { false }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

@MainActor
final class ViewController: UIViewController, ADBannerViewDelegate, FullScreenContentDelegate, BviewControllerDelegate {
    private var adBannerView: ADBannerView?
    private var interstitialAd: InterstitialAd?
    private var scene: MyScene?
    private var skView: SKView?

    override func viewDidLoad() {
        super.viewDidLoad()

        let banner = ADBannerView(frame: CGRect(x: 0, y: view.bounds.size.height - 50, width: 200, height: 30))
        banner.delegate = self
        banner.alpha = 1.0
        view.addSubview(banner)
        adBannerView = banner

        loadInterstitial()

        let areAdsRemoved = UserDefaults.standard.bool(forKey: "areAdsRemoved")
        UserDefaults.standard.synchronize()

        CommonUtil.shared.isPurchased = UserDefaults.standard.bool(forKey: "isPurchased")
        UserDefaults.standard.synchronize()

        if !CommonUtil.shared.isFreeVersion {
            CommonUtil.shared.isPurchased = true
        }

        if areAdsRemoved {
            view.backgroundColor = .blue
        }

        let skView: SKView
        if let existingView = view as? SKView {
            skView = existingView
        } else {
            let newView = SKView(frame: view.bounds)
            newView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(newView)
            skView = newView
        }
        self.skView = skView

        let gameCenterUtil = GameCenterUtil.shared
        _ = gameCenterUtil.isGameCenterAvailable()
        gameCenterUtil.authenticateLocalUser(self)
        gameCenterUtil.submitAllSavedScores()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let skView else { return }
        if scene != nil && scene?.size == skView.bounds.size { return }

        let scene = MyScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill

        scene.onGameOver = { [weak self] gameLevel, gameTime in
            DispatchQueue.main.async {
                self?.gameOverWithLose(gameLevel, gameTime: gameTime)
            }
        }
        scene.showAdmob = { [weak self] in
            self?.showAdmob()
        }
        scene.showBuyViewController = { [weak self] in
            self?.showBuyViewController()
        }
        scene.showRankView = { [weak self] in
            self?.showRankView()
        }
        scene.showHintView = { [weak self] in
            self?.showHintView()
        }

        skView.presentScene(scene)
        self.scene = scene
    }

    private func showRankView() {
        let gameCenterUtil = GameCenterUtil.shared
        _ = gameCenterUtil.isGameCenterAvailable()
        gameCenterUtil.showGameCenter(self)
        gameCenterUtil.submitAllSavedScores()
    }

    private func gameOverWithLose(_ gameLevel: Int, gameTime: Int) {
        guard let gameOverDialogViewController = storyboard?.instantiateViewController(withIdentifier: "GameOverViewController") as? GameOverViewController else {
            return
        }
        gameOverDialogViewController.delegate = self
        gameOverDialogViewController.gameLevel = gameLevel
        gameOverDialogViewController.gameTime = gameTime

        navigationController?.providesPresentationContextTransitionStyle = true
        navigationController?.definesPresentationContext = true
        gameOverDialogViewController.modalPresentationStyle = .overCurrentContext

        navigationController?.present(gameOverDialogViewController, animated: true, completion: nil)
    }

    private func showBuyViewController() {
        guard let buyViewController = storyboard?.instantiateViewController(withIdentifier: "BuyViewController") as? BuyViewController else {
            return
        }
        buyViewController.viewController = self
        navigationController?.modalPresentationStyle = .currentContext
        navigationController?.present(buyViewController, animated: true, completion: nil)
    }

    private func showHintView() {
        let hintViewController = HintViewController()
        hintViewController.modalPresentationStyle = .currentContext
        present(hintViewController, animated: true, completion: nil)
    }

    private func showAdmob() {
        if let interstitialAd = interstitialAd {
            interstitialAd.present(from: self)
            return
        }
        loadInterstitial()
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        }
        return .all
    }

    private func loadInterstitial() {
        let request = Request()
        InterstitialAd.load(with: "ca-app-pub-2566742856382887/7028666298", request: request) { [weak self] interstitialAd, error in
            if let error = error {
                NSLog("Failed to load interstitial ad: %@", error.localizedDescription)
                return
            }
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.interstitialAd = interstitialAd
                self.interstitialAd?.fullScreenContentDelegate = self
            }
        }
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        interstitialAd = nil
        loadInterstitial()
    }

    func removeAd() {
        adBannerView?.alpha = 0
    }

    func addMoney(_ money: Int) {
        scene?.addMoney(money)
    }

    func bannerViewDidLoadAd(_ banner: ADBannerView!) {
        layoutAnimated(true)
    }

    func bannerView(_ banner: ADBannerView!, didFailToReceiveAdWithError error: Error!) {
        layoutAnimated(true)
    }

    private func layoutAnimated(_ animated: Bool) {
        guard let adBannerView = adBannerView else { return }
        var contentFrame = view.bounds
        var bannerFrame = adBannerView.frame
        if adBannerView.bannerLoaded {
            contentFrame.size.height = 0
            bannerFrame.origin.y = view.bounds.size.height - 50
        } else {
            bannerFrame.origin.y = contentFrame.size.height
        }

        UIView.animate(withDuration: animated ? 0.25 : 0.0) {
            adBannerView.frame = contentFrame
            adBannerView.layoutIfNeeded()
            adBannerView.frame = bannerFrame
        }
    }

    func bviewcontrollerDidTapButton() {
        // No-op: original Objective-C did not implement delegate behavior.
    }

    func bviewcontrollerDidTapBackToMenuButton() {
        // No-op: original Objective-C did not implement delegate behavior.
    }
}
