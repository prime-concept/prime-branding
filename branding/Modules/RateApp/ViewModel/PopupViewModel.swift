import Foundation

struct PopupViewModel {
    var title: String
    var message: String
    var isInputFieldExist: Bool
    var isRatingViewExist: Bool
    var buttonList: [PopupButtonViewModel]

    init(
        title: String = "",
        message: String = "",
        inputFieldExist: Bool = false,
        ratingViewExist: Bool = false,
        buttonList: [PopupButtonViewModel] = []
    ) {
        self.title = title
        self.message = message
        self.isInputFieldExist = inputFieldExist
        self.isRatingViewExist = ratingViewExist
        self.buttonList = buttonList
    }
}
