import Foundation

protocol SetNewPasswordPresenterProtocol {
    func refresh()
}

final class SetNewPasswordPresenter {
    weak var view: SetNewPasswordViewProtocol?

    private var authAPI: AuthAPI
    private var isValid = true
    private var key: String
    private var password: (value: String, row: Int)?

    init(
        view: SetNewPasswordViewProtocol,
        authAPI: AuthAPI,
        key: String
    ) {
        self.view = view
        self.authAPI = authAPI
        self.key = key
    }

    private func makeRequest() {
        guard let password = self.password else {
            return
        }

        authAPI.restore(password: password.value, with: key).done { [weak self] _ in
            self?.view?.dismiss()
        }.catch { [weak self] error in
            if let authError = error as? AuthError {
                switch authError {
                case .userNotExists:
                    self?.view?.show(error: LS.localize("LinkIsOutOfDate"), for: password.row)
                default:
                    self?.view?.show(error: authError.localizedDescription, for: password.row)
                }
            } else {
                self?.view?.show(error: error.localizedDescription, for: password.row)
            }
        }
    }
}

extension SetNewPasswordPresenter: SetNewPasswordPresenterProtocol {
    func refresh() {
        guard let editedModels = view?.getEditedRowViewModels() else {
            return
        }

        var errors: [String?] = editedModels.map { _ in
            nil
        }

        for index in 0..<editedModels.count {
            switch editedModels[index] {
            case .password(let value):
                if value.isEmpty {
                    errors[index] = LS.localize("EnterPasswordError")
                } else if value.count < 6 {
                    errors[index] = LS.localize("PasswordLengthError")
                } else {
                    password = (value, index)
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
