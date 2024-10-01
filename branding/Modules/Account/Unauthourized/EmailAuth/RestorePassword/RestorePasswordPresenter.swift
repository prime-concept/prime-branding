import Foundation

extension Notification.Name {
    static let onOpenRestorePasswordLink = Notification.Name("onOpenRestorePasswordLink")
}

protocol RestorePasswordPresenterProtocol {
    func restore()
}

final class RestorePasswordPresenter {
    weak var view: RestorePasswordViewProtocol?

    private var authAPI: AuthAPI

    private var email: (value: String, row: Int)?

    init(
        view: RestorePasswordViewProtocol,
        authAPI: AuthAPI
    ) {
        self.view = view
        self.authAPI = authAPI

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onOpenRestorePasswordLink),
            name: .onOpenRestorePasswordLink,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func onOpenRestorePasswordLink() {
        view?.removeCustomAlert()
    }

    private func makeRequest() {
        guard let email = self.email else {
            return
        }

        authAPI.restorePassword(email: email.value).done { [weak self] _ in
            self?.view?.showCustomAlert()
        }.catch { [weak self] error in
            if let authError = error as? AuthError {
                self?.view?.show(error: authError.localizedDescription, for: email.row)
            } else {
                self?.view?.show(error: error.localizedDescription, for: email.row)
            }
        }
    }
}

extension RestorePasswordPresenter: RestorePasswordPresenterProtocol {
    func restore() {
        guard let editedModels = view?.getEditedRowViewModels() else {
            return
        }

        var errors: [String?] = editedModels.map { _ in
            nil
        }

        for index in 0..<editedModels.count {
            switch editedModels[index] {
            case .email(let value):
                if value.isEmpty {
                    errors[index] = LS.localize("EnterEmailError")
                } else {
                    email = (value, index)
                }
            default:
                continue
            }
        }

        if (errors.filter { $0 != nil }.isEmpty) {
            makeRequest()
        } else {
            view?.set(validationErrors: errors)
        }
    }
}
