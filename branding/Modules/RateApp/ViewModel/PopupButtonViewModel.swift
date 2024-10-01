import Foundation

enum RateButtonType {
    case cancel
    case destructive
    case defaultButton
}

struct PopupButtonViewModel {
    var title: String
    var type: RateButtonType
    var action: () -> Void
}
