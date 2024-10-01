import UIKit

final class DetailContactInfoView: UIView, NamedViewProtocol {
    @IBOutlet private weak var phoneNumberLabel: UILabel!
    @IBOutlet private weak var phoneView: UIView!

    var onWebSiteTap: (() -> Void)?
    var onPhoneTap: (() -> Void)?
    var onLayoutUpdate: (() -> Void)?

    var name: String {
        return "contactInfo"
    }

    private var phone: String? {
        didSet {
            phoneNumberLabel.text = phone
            onLayoutUpdate?()
        }
    }

    func setup(with phone: String) {
        phoneView.isHidden = phone.isEmpty
        self.phone = phone
    }

    @IBAction private func onWebSiteButtonTap(_ button: UIButton) {
        onWebSiteTap?()
    }

    @IBAction private func onPhoneButtonTap(_ button: UIButton) {
        onPhoneTap?()
    }
}
