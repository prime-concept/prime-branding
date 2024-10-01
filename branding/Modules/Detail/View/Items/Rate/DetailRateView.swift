import Foundation

final class DetailRateView: UIView, NamedViewProtocol {
    @IBOutlet private weak var titleLabel: UILabel!

    private static let selectedStarColor = UIColor(red: 0.84, green: 0.08, blue: 0.25, alpha: 1)
    private static let defaultStarColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1)

    private lazy var ratingStarsView: PopupRatingStarsView = {
        let view: PopupRatingStarsView = .fromNib()
        view.isUserInteractionEnabled = true
        view.onStarSelect = { [weak self] rating in
            self?.titleLabel.text = LS.localize("YourRate")
            self?.onRatingSelect?(rating)
        }
        view.setup(
            with: DetailRateView.selectedStarColor,
            defaultColor: DetailRateView.defaultStarColor
        )
        return view
    }()

    var onRatingSelect: ((Int) -> Void)?

    var name: String {
        return "rate"
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupSubviews()
        titleLabel.text = LS.localize("RateQuestion")
    }

    private func setupSubviews() {
        addSubview(ratingStarsView)

        ratingStarsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                ratingStarsView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
                ratingStarsView.leftAnchor.constraint(equalTo: leftAnchor),
                ratingStarsView.rightAnchor.constraint(equalTo: rightAnchor),
                ratingStarsView.centerXAnchor.constraint(equalTo: centerXAnchor),
                ratingStarsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
            ]
        )
    }

    func updateRating(value: Int?) {
        titleLabel.text = LS.localize(value == nil ? "RateQuestion" : "RatedQuestion")
        ratingStarsView.updateValue(value: value ?? 0)
    }
}
