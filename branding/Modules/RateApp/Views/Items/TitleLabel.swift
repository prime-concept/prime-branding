import UIKit

final class TitleLabel: UIView {
    @IBOutlet weak var labelTitle: UILabel!

    var text: String? {
        didSet {
            labelTitle.text = text
        }
    }

    func setup(viewModel: PopupViewModel) {
        text = viewModel.title
    }
}
