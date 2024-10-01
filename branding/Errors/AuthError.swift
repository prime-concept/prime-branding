import Foundation

enum AuthError: Error {
    case notValidData
    case emailNotValid
    case userExists
    case userNotExists

    var errorTag: String {
        switch self {
        case .notValidData:
            return "NOT_VALID_DATA"
        case .emailNotValid:
            return "EMAIL_NOT_VALID"
        case .userExists:
            return "USER_EXISTS"
        case .userNotExists:
            return "USER_NOT_EXISTS"
        }
    }

    var localizedDescription: String {
        switch self {
        case .notValidData:
            return ""
        case .emailNotValid:
            return LS.localize("NotValidEmail")
        case .userExists:
            return LS.localize("UserExistsError")
        case .userNotExists:
            return LS.localize("UserNotExistsError")
        }
    }

    init?(rawValue: String) {
        switch rawValue {
        case AuthError.notValidData.errorTag:
            self = .notValidData
        case AuthError.emailNotValid.errorTag:
            self = .emailNotValid
        case AuthError.userExists.errorTag:
            self = .userExists
        case AuthError.userNotExists.errorTag:
            self = .userNotExists
        default:
            return nil
        }
    }
}
