import Foundation

@objc protocol AppiraterDelegate: AnyObject {
    @objc optional func appiraterDidDisplayAlert(_ appirater: Appirater)
    @objc optional func appiraterDidDeclineToRate(_ appirater: Appirater)
    @objc optional func appiraterDidOptToRate(_ appirater: Appirater)
    @objc optional func appiraterDidOptToRemindLater(_ appirater: Appirater)
    @objc optional func appiraterWillPresentModalView(_ appirater: Appirater, animated: Bool)
    @objc optional func appiraterDidDismissModalView(_ appirater: Appirater, animated: Bool)
}
