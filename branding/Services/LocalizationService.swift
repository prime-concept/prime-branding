import Foundation
import PromiseKit

protocol LocalizationServiceProtocol {
    func localizeString(_ key: String) -> String
    func localizeRemoteString(withKey key: String) -> Promise<String>
}

/// Convenient in-place call structure for `LocalizationService`
struct LS {
    static let internalLocalizer = LocalizationService.shared

    static func localize(_ key: String) -> String {
        return internalLocalizer.localizeString(key)
    }

    static func localizeRemote(withKey key: String) -> Promise<String> {
        return internalLocalizer.localizeRemoteString(withKey: key)
    }
}

final class LocalizationService {
    static let shared = LocalizationService()

    private let persistenceService: RealmPersistenceService
    private let localizationAPI: LocalizationAPI

    private var strings = [String: String]()
    private var language = ApplicationConfig.contentLanguage

    private let dispatchGroup = DispatchGroup()
    private let waitQueue: DispatchQueue = .global(qos: .utility)

    private init(
        persistenceService: RealmPersistenceService = RealmPersistenceService.shared,
        localizationAPI: LocalizationAPI = LocalizationAPI()
    ) {
        self.persistenceService = persistenceService
        self.localizationAPI = localizationAPI
    }

    private func loadPersistent() {
        let localizedStrings = persistenceService.read(
            type: LocalizedString.self,
            predicate: NSPredicate(format: "language=%@", language.localeString)
        )

        let updatedStrings = localizedStrings.reduce(strings) { dict, string in
            dict.merging(
                [string.key: string.value],
                uniquingKeysWith: { _, updatedLocalization in
                    updatedLocalization
                }
            )
        }

        strings = updatedStrings
    }

    private func savePersistent() {
        let localizationStrings = strings.map { key, value in
            LocalizedString(
                key: key,
                value: value,
                language: language.localeString
            )
        }
        persistenceService.write(objects: localizationStrings)
    }

    private func value(for key: String) -> String {
        if let value = strings[key] {
            return value
        } else {
            // swiftlint:disable:next nslocalizedstring_key
            return NSLocalizedString(key, comment: "")
        }
    }
}

extension LocalizationService: LocalizationServiceProtocol {
    func setup() {
        waitQueue.async { [weak self] in
            //block the queue until service is initialized
            self?.dispatchGroup.enter()
        }

        loadPersistent()

        localizationAPI
            .retriveLocalizations(
                language: language.apiCode
            )
            .done(on: waitQueue) { strings in
                self.strings = strings
                self.savePersistent()
                self.dispatchGroup.leave()
            }
            .catch(on: waitQueue) { _ in
                self.dispatchGroup.leave()
            }
    }

    func localizeString(_ key: String) -> String {
        return value(for: key)
    }

    func localizeRemoteString(withKey key: String) -> Promise<String> {
        return Promise { seal in
            dispatchGroup.notify(queue: waitQueue) {
                seal.fulfill(self.value(for: key))
            }
        }
    }

    func localizeString(withKey key: String, intoTextOf label: UILabel) {
        localizeRemoteString(withKey: key)
            .done(on: .main) { value in
                label.text = value
            }
            .catch { error in
                assertionFailure("Localization failed with error: \(error.localizedDescription)")
            }
    }
}
