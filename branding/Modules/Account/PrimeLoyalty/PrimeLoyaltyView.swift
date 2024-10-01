import UIKit

final class PrimeLoyaltyView: UIView, LoyaltyViewProtocol {
    @IBOutlet private weak var primeLogoImageView: UIImageView!
    @IBOutlet private weak var subtitleLabel: UILabel!

    private static let primeLogoTintColor = UIColor(red: 0.61, green: 0.49, blue: 0.29, alpha: 1)

    private lazy var lineView: LoyaltyLineView = {
        let view = LoyaltyLineView()
        view.backgroundColor = .clear
        return view
    }()

    var card: String?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupAppearance()
        additionalSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupAppearance()
        additionalSetup()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        subtitleLabel.text = LS.localize("PrimeLoyaltyCardSubtitle")
        primeLogoImageView.image = UIImage(named: "prime_logo")?.withRenderingMode(.alwaysTemplate)
        primeLogoImageView.tintColor = PrimeLoyaltyView.primeLogoTintColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateShadowPosition()

        lineView.startPoint = CGPoint(x: frame.width / 2, y: 0)
        lineView.endPoint = CGPoint(x: frame.width, y: frame.height)
    }

    private func additionalSetup() {
        lineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lineView)
        lineView.attachEdges(to: self)
    }

    func setup(with card: String?) {
    }
}
