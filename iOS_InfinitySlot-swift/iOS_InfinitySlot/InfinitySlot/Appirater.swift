import StoreKit
import UIKit

final class Appirater: NSObject, UIAlertViewDelegate, SKStoreProductViewControllerDelegate {
    private static let kAppiraterFirstUseDate = "kAppiraterFirstUseDate"
    private static let kAppiraterUseCount = "kAppiraterUseCount"
    private static let kAppiraterSignificantEventCount = "kAppiraterSignificantEventCount"
    private static let kAppiraterCurrentVersion = "kAppiraterCurrentVersion"
    private static let kAppiraterRatedCurrentVersion = "kAppiraterRatedCurrentVersion"
    private static let kAppiraterDeclinedToRate = "kAppiraterDeclinedToRate"
    private static let kAppiraterReminderRequestDate = "kAppiraterReminderRequestDate"

    private static let templateReviewURL = "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=APP_ID"
    private static let templateReviewURLiOS7 = "itms-apps://itunes.apple.com/app/idAPP_ID"
    private static let templateReviewURLiOS8 = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=APP_ID&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"

    private static var appId: String = ""
    private static var daysUntilPrompt: Double = 30
    private static var usesUntilPrompt: Int = 20
    private static var significantEventsUntilPrompt: Int = -1
    private static var timeBeforeReminding: Double = 1
    private static var debug = false
    private static weak var delegateRef: AppiraterDelegate?
    private static var usesAnimation = true
    private static var statusBarStyle: UIStatusBarStyle = .default
    private static var modalOpen = false
    private static var alwaysUseMainBundle = false

    private var alertTitle: String?
    private var alertMessage: String?
    private var alertCancelTitle: String?
    private var alertRateTitle: String?
    private var alertRateLaterTitle: String?
    private var ratingAlert: UIAlertView?
    var openInAppStore: Bool = true

    private static let sharedInstance: Appirater = {
        let appirater = Appirater()
        appirater.openInAppStore = UIDevice.current.systemVersion.compare("7.0", options: .numeric) != .orderedAscending
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        return appirater
    }()

    private override init() {
        super.init()
    }

    private static func bundle() -> Bundle {
        if alwaysUseMainBundle {
            return Bundle.main
        }
        if let appiraterBundleURL = Bundle.main.url(forResource: "Appirater", withExtension: "bundle"),
           let bundle = Bundle(url: appiraterBundleURL) {
            return bundle
        }
        return Bundle.main
    }

    private var resolvedAlertTitle: String {
        let localized = NSLocalizedString("Rate %@", tableName: "AppiraterLocalizable", bundle: Self.bundle(), value: "", comment: "")
        let appName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String
            ?? Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
            ?? Bundle.main.infoDictionary?["CFBundleName"] as? String
            ?? ""
        return alertTitle ?? String(format: localized, appName)
    }

    private var resolvedAlertMessage: String {
        let localized = NSLocalizedString("If you enjoy using %@, would you mind taking a moment to rate it? It won't take more than a minute. Thanks for your support!", tableName: "AppiraterLocalizable", bundle: Self.bundle(), value: "", comment: "")
        let appName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String
            ?? Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
            ?? Bundle.main.infoDictionary?["CFBundleName"] as? String
            ?? ""
        return alertMessage ?? String(format: localized, appName)
    }

    private var resolvedAlertCancelTitle: String {
        return alertCancelTitle ?? NSLocalizedString("No, Thanks", tableName: "AppiraterLocalizable", bundle: Self.bundle(), value: "", comment: "")
    }

    private var resolvedAlertRateTitle: String {
        let localized = NSLocalizedString("Rate %@", tableName: "AppiraterLocalizable", bundle: Self.bundle(), value: "", comment: "")
        let appName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String
            ?? Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
            ?? Bundle.main.infoDictionary?["CFBundleName"] as? String
            ?? ""
        return alertRateTitle ?? String(format: localized, appName)
    }

    private var resolvedAlertRateLaterTitle: String {
        return alertRateLaterTitle ?? NSLocalizedString("Remind me later", tableName: "AppiraterLocalizable", bundle: Self.bundle(), value: "", comment: "")
    }

    static func setAppId(_ appId: String) { self.appId = appId }
    static func setDaysUntilPrompt(_ value: Double) { daysUntilPrompt = value }
    static func setUsesUntilPrompt(_ value: Int) { usesUntilPrompt = value }
    static func setSignificantEventsUntilPrompt(_ value: Int) { significantEventsUntilPrompt = value }
    static func setTimeBeforeReminding(_ value: Double) { timeBeforeReminding = value }
    static func setCustomAlertTitle(_ title: String) { sharedInstance.alertTitle = title }
    static func setCustomAlertMessage(_ message: String) { sharedInstance.alertMessage = message }
    static func setCustomAlertCancelButtonTitle(_ title: String) { sharedInstance.alertCancelTitle = title }
    static func setCustomAlertRateButtonTitle(_ title: String) { sharedInstance.alertRateTitle = title }
    static func setCustomAlertRateLaterButtonTitle(_ title: String) { sharedInstance.alertRateLaterTitle = title }
    static func setDebug(_ value: Bool) { debug = value }
    static func setDelegate(_ delegate: AppiraterDelegate?) { delegateRef = delegate }
    static func setUsesAnimation(_ animation: Bool) { usesAnimation = animation }
    static func setOpenInAppStore(_ openInAppStore: Bool) { sharedInstance.openInAppStore = openInAppStore }
    static func setAlwaysUseMainBundle(_ useMainBundle: Bool) { alwaysUseMainBundle = useMainBundle }

    static func appLaunched(_ canPromptForRating: Bool) {
        DispatchQueue.global(qos: .utility).async {
            sharedInstance.incrementAndRate(canPromptForRating)
        }
    }

    static func appEnteredForeground(_ canPromptForRating: Bool) {
        DispatchQueue.global(qos: .utility).async {
            sharedInstance.incrementAndRate(canPromptForRating)
        }
    }

    static func userDidSignificantEvent(_ canPromptForRating: Bool) {
        DispatchQueue.global(qos: .utility).async {
            sharedInstance.incrementSignificantEventAndRate(canPromptForRating)
        }
    }

    static func tryToShowPrompt() {
        sharedInstance.showPromptWithChecks(true, displayRateLaterButton: true)
    }

    static func forceShowPrompt(_ displayRateLaterButton: Bool) {
        sharedInstance.showPromptWithChecks(false, displayRateLaterButton: displayRateLaterButton)
    }

    static func rateApp() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: kAppiraterRatedCurrentVersion)
        userDefaults.synchronize()

        if !sharedInstance.openInAppStore, NSClassFromString("SKStoreProductViewController") != nil {
            let storeViewController = SKStoreProductViewController()
            let appIdNumber = NSNumber(value: Int(appId) ?? 0)
            storeViewController.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: appIdNumber], completionBlock: nil)
            storeViewController.delegate = sharedInstance

            delegateRef?.appiraterWillPresentModalView?(sharedInstance, animated: usesAnimation)
            if let root = getRootViewController() {
                root.present(storeViewController, animated: usesAnimation) {
                    modalOpen = true
                    statusBarStyle = UIApplication.shared.statusBarStyle
                    UIApplication.shared.setStatusBarStyle(.lightContent, animated: usesAnimation)
                }
            }
        } else {
            let version = UIDevice.current.systemVersion
            var reviewURL = templateReviewURL.replacingOccurrences(of: "APP_ID", with: appId)
            if version.compare("7.0", options: .numeric) != .orderedAscending && version.compare("8.0", options: .numeric) == .orderedAscending {
                reviewURL = templateReviewURLiOS7.replacingOccurrences(of: "APP_ID", with: appId)
            } else if version.compare("8.0", options: .numeric) != .orderedAscending {
                reviewURL = templateReviewURLiOS8.replacingOccurrences(of: "APP_ID", with: appId)
            }
            if let url = URL(string: reviewURL) {
                UIApplication.shared.openURL(url)
            }
        }
    }

    static func closeModal() {
        if modalOpen {
            UIApplication.shared.setStatusBarStyle(statusBarStyle, animated: usesAnimation)
            let usedAnimation = usesAnimation
            modalOpen = false
            if let presenting = UIApplication.shared.keyWindow?.rootViewController {
                let top = topMostViewController(presenting)
                top.dismiss(animated: usesAnimation) {
                    delegateRef?.appiraterDidDismissModalView?(sharedInstance, animated: usedAnimation)
                }
            }
        }
    }

    private static func getRootViewController() -> UIViewController? {
        var window = UIApplication.shared.keyWindow
        if let win = window, win.windowLevel != .normal {
            for w in UIApplication.shared.windows where w.windowLevel == .normal {
                window = w
                break
            }
        }
        if let window = window {
            return iterateSubViewsForViewController(window)
        }
        return nil
    }

    private static func iterateSubViewsForViewController(_ parentView: UIView) -> UIViewController? {
        for subView in parentView.subviews {
            if let responder = subView.next as? UIViewController {
                return topMostViewController(responder)
            }
            if let found = iterateSubViewsForViewController(subView) {
                return found
            }
        }
        return nil
    }

    private static func topMostViewController(_ controller: UIViewController) -> UIViewController {
        var current = controller
        while let presented = current.presentedViewController {
            current = presented
        }
        return current
    }

    @objc private static func appWillResignActive() {
        if debug { NSLog("APPIRATER appWillResignActive") }
        sharedInstance.hideRatingAlert()
    }

    private func connectedToNetwork() -> Bool {
        return CommonUtil.isConnected()
    }

    private func showPromptWithChecks(_ withChecks: Bool, displayRateLaterButton: Bool) {
        if !withChecks || ratingAlertIsAppropriate() {
            showRatingAlert(displayRateLaterButton)
        }
    }

    private func showRatingAlert(_ displayRateLaterButton: Bool) {
        let alertView: UIAlertView
        if displayRateLaterButton {
            alertView = UIAlertView(
                title: resolvedAlertTitle,
                message: resolvedAlertMessage,
                delegate: self,
                cancelButtonTitle: resolvedAlertCancelTitle,
                otherButtonTitles: resolvedAlertRateTitle, resolvedAlertRateLaterTitle
            )
        } else {
            alertView = UIAlertView(
                title: resolvedAlertTitle,
                message: resolvedAlertMessage,
                delegate: self,
                cancelButtonTitle: resolvedAlertCancelTitle,
                otherButtonTitles: resolvedAlertRateTitle
            )
        }
        ratingAlert = alertView
        alertView.show()
        Appirater.delegateRef?.appiraterDidDisplayAlert?(self)
    }

    private func hideRatingAlert() {
        if ratingAlert?.isVisible == true {
            if Appirater.debug { NSLog("APPIRATER Hiding Alert") }
            ratingAlert?.dismiss(withClickedButtonIndex: -1, animated: false)
        }
    }

    private func ratingAlertIsAppropriate() -> Bool {
        return connectedToNetwork() &&
            !userHasDeclinedToRate() &&
            (ratingAlert?.isVisible == false || ratingAlert == nil) &&
            !userHasRatedCurrentVersion()
    }

    private func ratingConditionsHaveBeenMet() -> Bool {
        if Appirater.debug { return true }

        let userDefaults = UserDefaults.standard
        let dateOfFirstLaunch = Date(timeIntervalSince1970: userDefaults.double(forKey: Appirater.kAppiraterFirstUseDate))
        let timeSinceFirstLaunch = Date().timeIntervalSince(dateOfFirstLaunch)
        let timeUntilRate = 60 * 60 * 24 * Appirater.daysUntilPrompt
        if timeSinceFirstLaunch < timeUntilRate { return false }

        let useCount = userDefaults.integer(forKey: Appirater.kAppiraterUseCount)
        if useCount < Appirater.usesUntilPrompt { return false }

        let sigEventCount = userDefaults.integer(forKey: Appirater.kAppiraterSignificantEventCount)
        if sigEventCount < Appirater.significantEventsUntilPrompt { return false }

        let reminderRequestDate = Date(timeIntervalSince1970: userDefaults.double(forKey: Appirater.kAppiraterReminderRequestDate))
        let timeSinceReminderRequest = Date().timeIntervalSince(reminderRequestDate)
        let timeUntilReminder = 60 * 60 * 24 * Appirater.timeBeforeReminding
        if timeSinceReminderRequest < timeUntilReminder { return false }

        return true
    }

    private func incrementUseCount() {
        let version = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? ""
        let userDefaults = UserDefaults.standard
        var trackingVersion = userDefaults.string(forKey: Appirater.kAppiraterCurrentVersion)
        if trackingVersion == nil {
            trackingVersion = version
            userDefaults.set(version, forKey: Appirater.kAppiraterCurrentVersion)
        }

        if Appirater.debug { NSLog("APPIRATER Tracking version: %@", trackingVersion ?? "") }

        if trackingVersion == version {
            var timeInterval = userDefaults.double(forKey: Appirater.kAppiraterFirstUseDate)
            if timeInterval == 0 {
                timeInterval = Date().timeIntervalSince1970
                userDefaults.set(timeInterval, forKey: Appirater.kAppiraterFirstUseDate)
            }
            var useCount = userDefaults.integer(forKey: Appirater.kAppiraterUseCount)
            useCount += 1
            userDefaults.set(useCount, forKey: Appirater.kAppiraterUseCount)
            if Appirater.debug { NSLog("APPIRATER Use count: %@", "\(useCount)") }
        } else {
            userDefaults.set(version, forKey: Appirater.kAppiraterCurrentVersion)
            userDefaults.set(Date().timeIntervalSince1970, forKey: Appirater.kAppiraterFirstUseDate)
            userDefaults.set(1, forKey: Appirater.kAppiraterUseCount)
            userDefaults.set(0, forKey: Appirater.kAppiraterSignificantEventCount)
            userDefaults.set(false, forKey: Appirater.kAppiraterRatedCurrentVersion)
            userDefaults.set(false, forKey: Appirater.kAppiraterDeclinedToRate)
            userDefaults.set(0, forKey: Appirater.kAppiraterReminderRequestDate)
        }
        userDefaults.synchronize()
    }

    private func incrementSignificantEventCount() {
        let version = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? ""
        let userDefaults = UserDefaults.standard
        var trackingVersion = userDefaults.string(forKey: Appirater.kAppiraterCurrentVersion)
        if trackingVersion == nil {
            trackingVersion = version
            userDefaults.set(version, forKey: Appirater.kAppiraterCurrentVersion)
        }

        if Appirater.debug { NSLog("APPIRATER Tracking version: %@", trackingVersion ?? "") }

        if trackingVersion == version {
            var timeInterval = userDefaults.double(forKey: Appirater.kAppiraterFirstUseDate)
            if timeInterval == 0 {
                timeInterval = Date().timeIntervalSince1970
                userDefaults.set(timeInterval, forKey: Appirater.kAppiraterFirstUseDate)
            }
            var sigEventCount = userDefaults.integer(forKey: Appirater.kAppiraterSignificantEventCount)
            sigEventCount += 1
            userDefaults.set(sigEventCount, forKey: Appirater.kAppiraterSignificantEventCount)
            if Appirater.debug { NSLog("APPIRATER Significant event count: %@", "\(sigEventCount)") }
        } else {
            userDefaults.set(version, forKey: Appirater.kAppiraterCurrentVersion)
            userDefaults.set(0, forKey: Appirater.kAppiraterFirstUseDate)
            userDefaults.set(0, forKey: Appirater.kAppiraterUseCount)
            userDefaults.set(1, forKey: Appirater.kAppiraterSignificantEventCount)
            userDefaults.set(false, forKey: Appirater.kAppiraterRatedCurrentVersion)
            userDefaults.set(false, forKey: Appirater.kAppiraterDeclinedToRate)
            userDefaults.set(0, forKey: Appirater.kAppiraterReminderRequestDate)
        }
        userDefaults.synchronize()
    }

    private func incrementAndRate(_ canPromptForRating: Bool) {
        incrementUseCount()
        if canPromptForRating && ratingConditionsHaveBeenMet() && ratingAlertIsAppropriate() {
            DispatchQueue.main.async {
                self.showRatingAlert(true)
            }
        }
    }

    private func incrementSignificantEventAndRate(_ canPromptForRating: Bool) {
        incrementSignificantEventCount()
        if canPromptForRating && ratingConditionsHaveBeenMet() && ratingAlertIsAppropriate() {
            DispatchQueue.main.async {
                self.showRatingAlert(true)
            }
        }
    }

    func userHasDeclinedToRate() -> Bool {
        return UserDefaults.standard.bool(forKey: Appirater.kAppiraterDeclinedToRate)
    }

    func userHasRatedCurrentVersion() -> Bool {
        return UserDefaults.standard.bool(forKey: Appirater.kAppiraterRatedCurrentVersion)
    }

    func alertView(_ alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        let userDefaults = UserDefaults.standard
        switch buttonIndex {
        case 0:
            userDefaults.set(true, forKey: Appirater.kAppiraterDeclinedToRate)
            userDefaults.synchronize()
            Appirater.delegateRef?.appiraterDidDeclineToRate?(self)
        case 1:
            Appirater.rateApp()
            Appirater.delegateRef?.appiraterDidOptToRate?(self)
        case 2:
            userDefaults.set(Date().timeIntervalSince1970, forKey: Appirater.kAppiraterReminderRequestDate)
            userDefaults.synchronize()
            Appirater.delegateRef?.appiraterDidOptToRemindLater?(self)
        default:
            break
        }
    }

    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        Appirater.closeModal()
    }
}
