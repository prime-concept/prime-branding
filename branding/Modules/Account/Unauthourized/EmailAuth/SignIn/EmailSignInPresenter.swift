import Foundation

protocol EmailSignInPresenterProtocol {
    func didLoad()
    func signIn()
}

final class EmailSignInPresenter {
    weak var view: EmailSignInViewProtocol?

    private var authAPI: AuthAPI

    private var name: (value: String, row: Int)?
    private var email: (value: String, row: Int)?
    private var password: (value: String, row: Int)?

    init(view: EmailSignInViewProtocol, authAPI: AuthAPI) {
        self.view = view
        self.authAPI = authAPI
    }

    private func makeRequest() {
        guard let email = self.email,
            let name = self.name,
            let password = self.password
        else {
            return
        }
        self.view?.isButtonEnabled = false
        authAPI.signIn(
            name: name.value,
            email: email.value,
            password: password.value
        ).done { [weak self] user, token in
            AnalyticsEvents.Auth.emailSignInCompleted.send()
            LocalAuthService.shared.auth(token: token, user: user)
            self?.view?.dismiss()
            self?.view?.isButtonEnabled = true
        }.catch { [weak self] error in
            if let authError = error as? AuthError {
                self?.view?.show(error: authError.localizedDescription, for: password.row)
            } else {
                self?.view?.show(error: error.localizedDescription, for: password.row)
            }
            self?.view?.isButtonEnabled = true
        }
    }
}

extension EmailSignInPresenter: EmailSignInPresenterProtocol {
    func didLoad() {
        AnalyticsEvents.Auth.emailSignIn.send()
    }
	
    func signIn() {
        func isValidEmail(_ email: String) -> Bool {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

            let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            return emailPred.evaluate(with: email)
        }

        guard let editedModels = view?.getEditedRowViewModels() else {
            return
        }

        var errors: [String?] = editedModels.map { _ in
            nil
        }

        for index in 0..<editedModels.count {
            switch editedModels[index] {
            case .name(let value):
                if value.isEmpty {
                    errors[index] = LS.localize("EnterNameError")
                } else {
                    name = (value, index)
                }
            case .email(let value):
                if value.isEmpty {
                    errors[index] = LS.localize("EnterEmailError")
                } else {
                    if isValidEmail(value) {
                        email = (value, index)
                    } else {
                        errors[index] = LS.localize("NotValidEmail")
                    }
                }
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
