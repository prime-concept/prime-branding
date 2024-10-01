import UIKit

final class PopupMessageLabel: UIView {
    @IBOutlet weak var labelMessage: UILabel!

    var text: String? {
        didSet {
            labelMessage.text = text
        }
    }

    func setup(viewModel: PopupViewModel) {
        text = viewModel.message
    }
}
