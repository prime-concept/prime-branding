import Foundation

enum SettingsRowViewModel {
    case writeUs
    case userAgreement
    case pushNotifications
    case logOut
    case privacyPolicy
    case deleteUser

    var title: String {
        switch self {
        case .writeUs:
            return LS.localize("ContactUs")
        case .userAgreement:
            return LS.localize("UserAgreement")
        case .pushNotifications:
            return LS.localize("PushNotifications")
        case .logOut:
            return LS.localize("Logout")
        case .privacyPolicy:
            return LS.localize("Settings.PrivacyPolicy")
        case .deleteUser:
            return LS.localize("DeleteUser")
        }
    }
}
