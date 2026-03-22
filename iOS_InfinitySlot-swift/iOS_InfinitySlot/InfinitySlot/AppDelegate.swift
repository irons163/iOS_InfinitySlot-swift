import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Appirater.setAppId("770699556")
        Appirater.setDaysUntilPrompt(1)
        Appirater.setUsesUntilPrompt(5)
        Appirater.setSignificantEventsUntilPrompt(-1)
        Appirater.setTimeBeforeReminding(2)
        Appirater.setDebug(false)
        Appirater.appLaunched(true)

        if UIApplication.instancesRespond(to: #selector(UIApplication.registerUserNotificationSettings(_:))) {
            let settings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }

        if let localNotif = launchOptions?[.localNotification] as? UILocalNotification {
            _ = localNotif.userInfo?["coin"] as? String
            application.applicationIconBadgeNumber = localNotif.applicationIconBadgeNumber - 1
        }

        if AppDelegate.isFirstLaunch() {
            UIApplication.shared.cancelAllLocalNotifications()

            let userDefaults = UserDefaults.standard
            userDefaults.set(MyScene.moneyInit, forKey: MyScene.moneyField)
            userDefaults.synchronize()

            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd"
            let dateStr = formatter.string(from: date)
            UserDefaults.standard.set(dateStr, forKey: "date")
            UserDefaults.standard.synchronize()

            var components = Calendar(identifier: .gregorian).dateComponents([.year, .month, .day], from: date)
            components.hour = 0
            components.minute = 0
            let fireDate = Calendar(identifier: .gregorian).date(from: components)

            let localNotification = UILocalNotification()
            localNotification.timeZone = TimeZone.current
            localNotification.fireDate = fireDate
            localNotification.repeatInterval = .day
            localNotification.alertBody = "Make up money to 5000."
            localNotification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.shared.scheduleLocalNotification(localNotification)
        }

        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let dateStr = formatter.string(from: currentDate)

        if dateStr != UserDefaults.standard.string(forKey: "date") {
            UserDefaults.standard.set(dateStr, forKey: "date")
            UserDefaults.standard.synchronize()
            CommonUtil.shared.isDuringOneDay = true
            NSLog("get from launch")
        }

        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Appirater.appEnteredForeground(true)
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        _ = notification.userInfo?["coin"] as? String
        application.applicationIconBadgeNumber = notification.applicationIconBadgeNumber - 1

        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let dateStr = formatter.string(from: currentDate)

        if dateStr != UserDefaults.standard.string(forKey: "date") {
            UserDefaults.standard.set(dateStr, forKey: "date")
            UserDefaults.standard.synchronize()
            CommonUtil.shared.isDuringOneDay = true
            NSLog("get")
        }
    }

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        let settings = UIApplication.shared.currentUserNotificationSettings
        if settings?.types == .none {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
    }

    static func isFirstLaunch() -> Bool {
        if UserDefaults.standard.bool(forKey: "hasLaunchedOnce") {
            return false
        }
        UserDefaults.standard.set(true, forKey: "hasLaunchedOnce")
        UserDefaults.standard.synchronize()
        return true
    }
}
