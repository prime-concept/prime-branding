import Foundation

enum EmailLoginViewModel {
    case logo
    case name(String)
    case email(String)
    case password(String)
    case privacyPolicy
    case loginButtons
    case actionButton

    var title: String {
        switch self {
        case .name:
            return LS.localize("Name")
        case .email:
            return LS.localize("Email")
        case .password:
            return LS.localize("Password")
        case .logo, .privacyPolicy, .loginButtons, .actionButton:
            return ""
        }
    }

    var placeholder: String {
        return title
    }
}
