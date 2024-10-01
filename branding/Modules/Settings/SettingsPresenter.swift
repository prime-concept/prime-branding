import Foundation

protocol SettingsPresenterProtocol: class {
    func reloadData()
    func selected(row: SettingsRowViewModel)
}

extension String {
    static let mfEmail = ApplicationConfig.StringConstants.mailto
    static let mfEmailSubject = "Мобильное приложение \(ApplicationConfig.StringConstants.mainTitle)"
}

final class SettingsPresenter: SettingsPresenterProtocol {
    private var authAPI: AuthAPI
    weak var view: SettingsViewProtocol?
    var authState: AuthorizationState

    init(
        view: SettingsViewProtocol,
        authState: AuthorizationState,
        authAPI: AuthAPI
    ) {
        self.view = view
        self.authState = authState
        self.authAPI = authAPI
    }

    func reloadData() {
        var rows: [SettingsRowViewModel] = [
            .writeUs,
            .userAgreement
        ]

        if FeatureFlags.shouldShowPrivacyPolicy {
            rows.append(.privacyPolicy)
        }

        if case .authorized = authState {
//            rows.insert(
//                .pushNotifications,
//                at: 0
//            )
            rows.append(.deleteUser)
            rows.append(.logOut)
        }

        view?.display(rows: rows)
    }

    func selected(row: SettingsRowViewModel) {
        switch row {
        case .writeUs:
            AnalyticsEvents.Settings.contactPressed.send()
            try? view?.sendEmail(
                to: .mfEmail,
                subject: .mfEmailSubject
            )
        case .userAgreement:
            AnalyticsEvents.Settings.agreementPressed.send()
            view?.open(
                url: URL(string: ApplicationConfig.StringConstants.userAgreement)
            )
        case .logOut:
            logOut()
        case .pushNotifications:
            return
        case .privacyPolicy:
            view?.open(
                url: URL(string: ApplicationConfig.StringConstants.privacyPolicy)
            )
        case .deleteUser:
            view?.showDestructiveAlert { [weak self] in
                self?.deleteUser()
            }
        }
    }

    private func logOut() {
        RealmPersistenceService.shared.delete(
            type: Loyalty.self,
            predicate: NSPredicate(format: "id == %@", "")
        )

        LocalAuthService.shared.logout()
        view?.dismiss()
    }
    
    private func deleteUser() {
        authAPI.deleteUser().done { [weak self] _ in
            self?.logOut()
        }.catch { error in
            print(error.localizedDescription)
        }
    }
}
