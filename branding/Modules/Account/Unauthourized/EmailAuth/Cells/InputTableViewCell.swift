import UIKit

final class InputTableViewCell: UITableViewCell, ViewReusable, NibLoadable {
    @IBOutlet private weak var itemTitleLabel: UILabel!
    @IBOutlet private weak var inputTextField: UITextField!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!

    private static let errorTintColor = UIColor(red: 0.84, green: 0.08, blue: 0.25, alpha: 1)
    private static let defaultTintColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)

    var onChange: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        inputTextField.delegate = self
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        inputTextField.isSecureTextEntry = false
        defaultAppearance()
    }

    func setup(
        with title: String,
        placeholder: String,
        isSecurityInput: Bool = false,
		value: String,
        error: String? = nil,
        onChange: ((String) -> Void)?
    ) {
        itemTitleLabel.text = title
		
        inputTextField.isSecureTextEntry = isSecurityInput
        inputTextField.placeholder = placeholder
        inputTextField.autocapitalizationType = isSecurityInput ? .none : .sentences
		inputTextField.text = value

        if let error = error {
            errorLabel.text = error
            errorAppearance()
        }

        self.onChange = onChange
    }

    func errorAppearance() {
        separatorView.backgroundColor = InputTableViewCell.errorTintColor
    }

    func defaultAppearance() {
        errorLabel.text = ""
        separatorView.backgroundColor = InputTableViewCell.defaultTintColor
    }
}

extension InputTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        onChange?(textField.text ?? "")
    }
}
