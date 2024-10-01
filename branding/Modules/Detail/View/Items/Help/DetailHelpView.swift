import UIKit

final class DetailHelpView: UIView, NamedViewProtocol {
    @IBOutlet private weak var textLabel: UILabel!

    var name: String {
        return "help"
    }

    var text: String? {
        didSet {
            textLabel.setText(text, lineSpacing: 2)
        }
    }
}
