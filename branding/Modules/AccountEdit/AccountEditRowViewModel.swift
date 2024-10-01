import Foundation

enum AccountEditRowViewModel {
    case name(String)
    case familyName(String)
    case email(String)
    case phoneNumber(String)

    var title: String {
        switch self {
        case .name:
            return LS.localize("NameAndSurname")
        case .familyName:
            return "Фамилия"
        case .email:
            return LS.localize("Email")
        case .phoneNumber:
            return LS.localize("Phone")
        }
    }

    var placeholder: String {
        return title
    }
}
