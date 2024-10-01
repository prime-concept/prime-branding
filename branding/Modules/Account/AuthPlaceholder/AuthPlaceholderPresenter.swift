import Foundation

protocol AuthPlaceholderPresenterProtocol {
    func reloadData()
    func finish()
}

final class AuthPlaceholderPresenter: AuthPlaceholderPresenterProtocol {
    weak var view: AuthPlaceholderViewProtocol?

    private var type: AuthPlaceholderType
    private var completion: (() -> Void)?

    init(
        view: AuthPlaceholderViewProtocol,
        type: AuthPlaceholderType,
        completion: (() -> Void)?
    ) {
        self.view = view
        self.type = type
        self.completion = completion
    }

    func reloadData() {
        view?.show(for: type)
    }

    func finish() {
        completion?()
    }
}
