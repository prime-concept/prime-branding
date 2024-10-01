import UIKit

fileprivate extension CGFloat {
    static let searchIconSideSize: CGFloat = 14
    static let contentPadding: CGFloat = 10
}

class SearchTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    private func setUp() {
        layer.cornerRadius = 10
        layer.masksToBounds = true

        clearButtonMode = .whileEditing
        returnKeyType = .done
        delegate = self

        updateLeftView()
    }

    func updateLeftView() {
        leftView = UIImageView(
            image: #imageLiteral(resourceName: "search").withRenderingMode(.alwaysTemplate)
        )
        leftView?.tintColor = .middleGrayColor
        leftView?.contentMode = .scaleAspectFit
        leftViewMode = .always
    }

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(
            x: .contentPadding,
            y: (bounds.height - .searchIconSideSize) / 2,
            width: .searchIconSideSize,
            height: .searchIconSideSize
        )
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let leftPadding = .searchIconSideSize + .contentPadding + 8
        let rightPadding: CGFloat = .contentPadding

        return CGRect(
            x: leftPadding,
            y: 0,
            width: bounds.width - leftPadding - rightPadding,
            height: bounds.height
        )
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}

extension SearchTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        return true
    }
}
