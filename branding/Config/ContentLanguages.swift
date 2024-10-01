import Foundation

enum ContentLanguage: String {
    case english = "en"
    case russian = "ru"
    case chinese = "zh"

    init(localeString: String) {
        guard ApplicationConfig.Modules.languages.contains(localeString) else {
            self = ContentLanguage(rawValue: ApplicationConfig.Modules.languages.first ?? "") ?? .english
            return
        }

        guard let language = ContentLanguage(rawValue: localeString) else {
            self = ContentLanguage(rawValue: ApplicationConfig.Modules.languages.first ?? "") ?? .english
            return
        }

        self = language
    }

    var localeString: String {
        return rawValue
    }

    var apiCode: String {
        switch self {
        case .russian:
            return "ru"
        case .chinese:
            return "ch"
        case .english:
            return "en"
        }
    }
}
