import Foundation

final class CommonUtil {
    static let shared = CommonUtil()

    var screenWidth: Int = 0
    var screenHeight: Int = 0
    var statusBarHeight: Int = 0
    var adBarHeight: Int = 0
    var labaStickWidth: Int = 0
    var labaStickHeight: Int = 0
    var labaStickBlockHeight: Int = 0
    var labaViewMarginWidth: Int = 0
    var labaViewWidth: Int = 0
    var labaViewHeight: Int = 0
    var labaOffsetX: Int = 0
    var isPurchased: Bool = false
    var isFreeVersion: Bool = false
    var isDuringOneDay: Bool = false

    private init() { }

    static func isConnected() -> Bool {
        guard let reachability = Reachability.reachabilityForInternetConnection() else {
            return false
        }
        return reachability.currentReachabilityStatus() != .notReachable
    }
}
