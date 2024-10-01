import UIKit

final class AccountEditTableCell: UITableViewCell, ViewReusable, NibLoadable {
    private var keyboardType: UIKeyboardType = .default
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!

    var onChange: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        inputTextField.delegate = self
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        inputTextField.keyboardType = .default
    }

    func setUp(
        with title: String,
        placeholder: String,
        value: String? = nil,
        keyboardType: UIKeyboardType = .default,
        onChange: @escaping (String) -> Void
    ) {
        itemTitleLabel.text = title
        inputTextField.text = value
        inputTextField.placeholder = placeholder

        self.keyboardType = keyboardType
        self.onChange = onChange
    }

    func change(keyboardType: UIKeyboardType) {
        inputTextField.keyboardType = keyboardType
    }
}

extension AccountEditTableCell: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard keyboardType == .numberPad, !string.isEmpty else {
            return true
        }

        let phoneNumberSet = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "+"))
        guard string.rangeOfCharacter(from: phoneNumberSet) != nil else {
            return false
        }

        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        onChange?(textField.text ?? "")
    }
}
