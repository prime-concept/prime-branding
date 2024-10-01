import UIKit

final class PrivacyPolicyTableViewCell: UITableViewCell, ViewReusable, NibLoadable {
    @IBOutlet private weak var textViewInfo: UITextView! {
        didSet {
            textViewInfo.delegate = self
            textViewInfo.attributedText = info
        }
    }

    private var info = NSAttributedString(string: "")

    var onUrlOpen: ((URL) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    private func commonInit() {
        let rangeTuple = underlineRange()
        let attributedString = NSMutableAttributedString(
            string: LS.localize("PrivacyPolicy")
        )
        attributedString.addAttribute(
            .link,
            value: ApplicationConfig.StringConstants.userAgreement,
            range: rangeTuple.oferta
        )
        attributedString.addAttribute(
            .foregroundColor,
            value: ApplicationConfig.Appearance.firstTintColor,
            range: rangeTuple.oferta
        )
        attributedString.addAttribute(
            .link,
            value: ApplicationConfig.StringConstants.privacyPolicy,
            range: rangeTuple.privacy
        )
        attributedString.addAttribute(
            .foregroundColor,
            value: ApplicationConfig.Appearance.firstTintColor,
            range: rangeTuple.privacy
        )

        self.info = attributedString
    }

    private func underlineRange() -> (oferta: NSRange, privacy: NSRange) {
        switch ApplicationConfig.contentLanguage {
        case .russian:
            return (NSRange(location: 51, length: 27), NSRange(location: 81, length: 27))
        case .chinese:
            return (NSRange(location: 12, length: 4), NSRange(location: 17, length: 4))
        default:
            return (NSRange(location: 44, length: 18), NSRange(location: 66, length: 23))
        }
    }
}

extension PrivacyPolicyTableViewCell: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange
    ) -> Bool {
        onUrlOpen?(URL)
        return false
    }
}
