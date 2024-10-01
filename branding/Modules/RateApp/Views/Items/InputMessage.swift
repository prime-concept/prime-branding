import UIKit

final class InputMessage: UIView {
    @IBOutlet weak var textViewMessage: UITextView!

    var onChange: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        textViewMessage.delegate = self

        textViewMessage.layer.cornerRadius = 10
        textViewMessage.clipsToBounds = true
    }
}

extension InputMessage: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        onChange?(textView.text ?? "")
    }
}
