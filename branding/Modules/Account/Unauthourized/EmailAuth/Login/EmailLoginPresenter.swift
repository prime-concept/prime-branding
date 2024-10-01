import Foundation

protocol EmailLoginPresenterProtocol {
    func didLoad()
    func login()
    func forgetPassword()
}

final class EmailLoginPresenter {
    weak var view: EmailLoginViewProtocol?

    private var authAPI: AuthAPI
    private var authCompletion: () -> Void

    private var email: (value: String, row: Int)?
    private var password: (value: String, row: Int)?

    init(
        view: EmailLoginViewProtocol,
        authAPI: AuthAPI,
        authCompletion: @escaping () -> Void
    ) {
        self.view = view
        self.authAPI = authAPI
        self.authCompletion = authCompletion
    }

    private func makeRequest() {
        guard let email = self.email,
            let password = self.password
        else {
            return
        }

        authAPI.auth(
            with: email.value,
            password: password.value
        ).done { [weak self] user, token in
            AnalyticsEvents.Auth.emailLogInCompleted.send()
            LocalAuthService.shared.auth(token: token, user: user)
            self?.view?.dismiss()
            self?.authCompletion()
        }.catch { [weak self] error in
            if let authError = error as? AuthError {
                self?.view?.show(error: authError.localizedDescription, for: password.row)
            } else {
                self?.view?.show(error: error.localizedDescription, for: password.row)
            }
        }
    }
}

extension EmailLoginPresenter: EmailLoginPresenterProtocol {
    func didLoad() {
        AnalyticsEvents.Auth.emailLogIn.send()
    }

    func login() {
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
					self.email = (value, index)
                }
            case .password(let value):
                if value.isEmpty {
                    errors[index] = LS.localize("EnterPasswordError")
                } else if value.count < 6 {
                    errors[index] = LS.localize("PasswordLengthError")
                } else {
					self.password = (value, index)
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

    func forgetPassword() {
        guard let view = self.view else {
            return
        }

        let restorePasswordAssembly = RestorePasswordAssembly()
        let router = PushRouter(
            source: view,
            destination: restorePasswordAssembly.buildModule()
        )
        router.route()
    }
}
