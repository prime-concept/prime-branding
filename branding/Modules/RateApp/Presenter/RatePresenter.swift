import UIKit

fileprivate extension Int {
    static let starRatingDivision: Int = 4
}

protocol RatePresenterProtocol: class {
    func select(rating: Int)
    func send(message: String)
    func cancel()
}

final class RatePresenter: RatePresenterProtocol {
    weak var view: RateViewProtocol?

    private let rateAppService: RateAppServiceProtocol
    private let localAuthService: LocalAuthService
    private let supportAPI: SupportAPI

    init(
        view: RateViewProtocol,
        rateAppService: RateAppServiceProtocol = RateAppService.shared,
        localAuthService: LocalAuthService = LocalAuthService.shared,
        supportAPI: SupportAPI
    ) {
        self.view = view
        self.rateAppService = rateAppService
        self.localAuthService = localAuthService
        self.supportAPI = supportAPI
    }

    private func updateViewModelForReview() {
        let model = PopupViewModel(
            message: LS.localize("TellUsAboutApp"),
            inputFieldExist: true,
            ratingViewExist: false
        )
        view?.updateViewModel(viewModel: model)
    }

    func select(rating: Int) {
        if rating < .starRatingDivision {
            updateViewModelForReview()
        } else {
            rateAppService.saveRateSendDate()
            view?.sendToAppStore()
        }
    }

    func send(message: String) {
        rateAppService.saveRateSendDate()

        let email = localAuthService.user?.email ?? "test@test.ru"
        supportAPI.send(text: message, email: email).done {
            print("rate app feedback sent")
        }.catch { error in
            print("error while sending app feedback: \(error)")
        }
    }

    func cancel() {
        rateAppService.saveRateSendDate()
    }
}
