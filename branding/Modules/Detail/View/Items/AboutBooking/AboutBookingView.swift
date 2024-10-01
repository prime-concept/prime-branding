import Foundation

final class AboutBookingView: UIView, NamedViewProtocol {
    @IBOutlet private weak var titleLabel: UILabel!

    var name: String {
        return "aboutBooking"
    }

    func setup(viewModel: DetailAboutBookingViewModel) {
        titleLabel.text = viewModel.value
    }
}
