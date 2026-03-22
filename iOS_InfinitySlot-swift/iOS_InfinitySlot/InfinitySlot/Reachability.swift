import Foundation
import SystemConfiguration

enum NetworkStatus: Int {
    case notReachable = 0
    case reachableViaWiFi
    case reachableViaWWAN
}

final class Reachability {
    private var reachabilityRef: SCNetworkReachability?
    private var alwaysReturnLocalWiFiStatus = false

    private init(ref: SCNetworkReachability?) {
        self.reachabilityRef = ref
    }

    static func reachabilityWithHostName(_ hostName: String) -> Reachability? {
        let ref = SCNetworkReachabilityCreateWithName(nil, hostName)
        return Reachability(ref: ref)
    }

    static func reachabilityWithAddress(_ hostAddress: UnsafePointer<sockaddr_in>) -> Reachability? {
        let ref = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, UnsafePointer<sockaddr>(OpaquePointer(hostAddress)))
        return Reachability(ref: ref)
    }

    static func reachabilityForInternetConnection() -> Reachability? {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        return withUnsafePointer(to: &zeroAddress) { address in
            Reachability.reachabilityWithAddress(address)
        }
    }

    static func reachabilityForLocalWiFi() -> Reachability? {
        var localWifiAddress = sockaddr_in()
        localWifiAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        localWifiAddress.sin_family = sa_family_t(AF_INET)
        localWifiAddress.sin_addr.s_addr = in_addr_t(0xA9FE0000) // 169.254.0.0

        let reachability = withUnsafePointer(to: &localWifiAddress) { address in
            Reachability.reachabilityWithAddress(address)
        }
        reachability?.alwaysReturnLocalWiFiStatus = true
        return reachability
    }

    func startNotifier() -> Bool {
        guard let ref = reachabilityRef else { return false }
        var context = SCNetworkReachabilityContext(version: 0, info: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()), retain: nil, release: nil, copyDescription: nil)
        if SCNetworkReachabilitySetCallback(ref, ReachabilityCallback, &context) {
            if SCNetworkReachabilityScheduleWithRunLoop(ref, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue) {
                return true
            }
        }
        return false
    }

    func stopNotifier() {
        guard let ref = reachabilityRef else { return }
        SCNetworkReachabilityUnscheduleFromRunLoop(ref, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
    }

    deinit {
        stopNotifier()
    }

    func currentReachabilityStatus() -> NetworkStatus {
        guard let ref = reachabilityRef else { return .notReachable }
        var flags = SCNetworkReachabilityFlags()
        if SCNetworkReachabilityGetFlags(ref, &flags) {
            if alwaysReturnLocalWiFiStatus {
                return localWiFiStatusForFlags(flags)
            }
            return networkStatusForFlags(flags)
        }
        return .notReachable
    }

    func connectionRequired() -> Bool {
        guard let ref = reachabilityRef else { return false }
        var flags = SCNetworkReachabilityFlags()
        if SCNetworkReachabilityGetFlags(ref, &flags) {
            return flags.contains(.connectionRequired)
        }
        return false
    }

    private func localWiFiStatusForFlags(_ flags: SCNetworkReachabilityFlags) -> NetworkStatus {
        if flags.contains(.reachable) && flags.contains(.isDirect) {
            return .reachableViaWiFi
        }
        return .notReachable
    }

    private func networkStatusForFlags(_ flags: SCNetworkReachabilityFlags) -> NetworkStatus {
        if !flags.contains(.reachable) {
            return .notReachable
        }

        var returnValue: NetworkStatus = .notReachable
        if !flags.contains(.connectionRequired) {
            returnValue = .reachableViaWiFi
        }

        if flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic) {
            if !flags.contains(.interventionRequired) {
                returnValue = .reachableViaWiFi
            }
        }

        if flags.contains(.isWWAN) {
            returnValue = .reachableViaWWAN
        }

        return returnValue
    }
}

private func ReachabilityCallback(_ target: SCNetworkReachability, _ flags: SCNetworkReachabilityFlags, _ info: UnsafeMutableRawPointer?) {
    guard let info = info else { return }
    let reachability = Unmanaged<Reachability>.fromOpaque(info).takeUnretainedValue()
    NotificationCenter.default.post(name: Notification.Name("kNetworkReachabilityChangedNotification"), object: reachability)
}
