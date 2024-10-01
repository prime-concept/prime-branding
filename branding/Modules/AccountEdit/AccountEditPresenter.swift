import Foundation

protocol AccountEditPresenterProtocol: class {
    var accountEditMode: AccountEditMode { get set }
    var shouldShowLoyaltyInfo: Bool { get }
    func reloadData()
    func save()
    func checkFilling()
}

final class AccountEditPresenter: AccountEditPresenterProtocol {
    weak var view: AccountEditViewProtocol?

    var accountEditMode: AccountEditMode
    var authAPI: AuthAPI
    var user: User
    var profileModel: ProfileInfoViewModel {
        return ProfileInfoViewModel(user: user)
    }
    var shouldShowLoyaltyInfo: Bool {
        return accountEditMode == .registration || LocalAuthService.shared.user?.isPrimeLoyalty ?? false
    }

    init(
        view: AccountEditViewProtocol,
        profile: User,
        authAPI: AuthAPI,
        accountEditMode: AccountEditMode
    ) {
        self.view = view
        self.user = profile
        self.authAPI = authAPI
        self.accountEditMode = accountEditMode
    }

    func reloadData() {
        view?.display(
            rows: [
                .name(profileModel.fullName),
                .email(profileModel.email),
                .phoneNumber(profileModel.phoneNumber)
            ]
        )
    }

    func save() {
        guard accountEditMode == .editing else {
            return
        }
        applyChanges()
        updateUser()
    }

    func checkFilling() {
        applyChanges()
        if user.isFill {
            updateUser { [weak self] in
                self?.view?.dismiss()
            }
        }
    }

    private func updateUser(completion: (() -> Void)? = nil) {
        authAPI.updateUser(updatedUser: user).done { updatedUser in
            LocalAuthService.shared.update(user: updatedUser)
            completion?()
        }.catch { _ in
            //TODO: Display error here when design is ready
        }
    }

    private func applyChanges() {
        guard let editedModels = view?.getEditedRowViewModels() else {
            return
        }
        for model in editedModels {
            switch model {
            case .email(let value):
                user.email = value
            case .name(let value):
                if value != profileModel.fullName {
                    AnalyticsEvents.Profile.nameChanged.send()
                }
                user.name = value
            case .phoneNumber(let value):
                AnalyticsEvents.Profile.phoneChanged.send()
                user.phoneNumber = value
            default:
                continue
            }
        }
    }
}
