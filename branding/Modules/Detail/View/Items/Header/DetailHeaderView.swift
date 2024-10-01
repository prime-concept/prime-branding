import UIKit

final class DetailHeaderView: UIView {
    @IBOutlet private weak var imageCarouselView: ImageCarouselView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var badgeLabel: PaddingLabel!
    @IBOutlet private weak var smallLabel: PaddingLabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet private weak var bottomStackViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bottomTitleConstraint: NSLayoutConstraint!
    @IBOutlet private weak var panoramaButton: UIButton!
    @IBOutlet private weak var contestIconImageView: UIImageView!
    @IBOutlet private weak var distanceIconImageView: UIImageView!
    @IBOutlet private weak var distanceLabel: UILabel!

    @IBOutlet private var stackViewToPanoramaConstraint: NSLayoutConstraint!
    @IBOutlet private var stackViewToFavoriteConstraint: NSLayoutConstraint!
    @IBOutlet private weak var routeInfoLabel: UILabel!
    @IBOutlet private weak var bottomGradientView: UIView!

    private static let ageLabelBackgroundColor = UIColor(
        red: 0.65,
        green: 0.65,
        blue: 0.65,
        alpha: 1
    )

    private var hasBottomInfo = false

    private var shouldShowContestIcon: Bool = false {
        didSet {
            contestIconImageView.isHidden = !shouldShowContestIcon
        }
    }

    private var shouldShowPanoramaIcon: Bool = false {
        didSet {
            stackViewToPanoramaConstraint.isActive = shouldShowPanoramaIcon
            stackViewToFavoriteConstraint.isActive = !shouldShowPanoramaIcon
            panoramaButton.isEnabled = shouldShowPanoramaIcon
            panoramaButton.isHidden = !shouldShowPanoramaIcon
        }
    }

    private var isFavoriteButtonHidden: Bool = true {
        didSet {
            favoriteButton.isHidden = isFavoriteButtonHidden
            favoriteButton.isEnabled = !isFavoriteButtonHidden
        }
    }

    private var isFavoriteButtonSelected: Bool = false {
        didSet {
            favoriteButton.isSelected = isFavoriteButtonSelected
        }
    }

    var badgeTitle: String? {
        didSet {
            badgeLabel.isHidden = (badgeTitle ?? "").isEmpty
            badgeLabel.text = badgeTitle
        }
    }

    var subtitle: String? {
        didSet {
            subtitleLabel.isHidden = (subtitle ?? "").isEmpty
            hasBottomInfo = !(subtitle ?? "").isEmpty
            subtitleLabel.text = subtitle
        }
    }

    var smallText: String? {
        didSet {
            smallLabel.isHidden = (smallText ?? "").isEmpty
            hasBottomInfo = !(smallText ?? "").isEmpty
            smallLabel.text = smallText
        }
    }

    var distance: String? {
        didSet {
            distanceLabel.isHidden = (distance ?? "").isEmpty
            distanceIconImageView.isHidden = (distance ?? "").isEmpty
            hasBottomInfo = !(distance ?? "").isEmpty
            distanceLabel.text = distance
        }
    }

    var routeInfo: String? {
        didSet {
            routeInfoLabel.isHidden = (routeInfo ?? "").isEmpty
            routeInfoLabel.text = routeInfo
        }
    }

    var onAdd: (() -> Void)?

    var onClose: (() -> Void)?

    var onPanorama: (() -> Void)?

    func set(viewModel: DetailHeaderViewModel) {
        titleLabel.text = viewModel.title
        imageCarouselView.isUserInteractionEnabled = viewModel.gradientImages.count > 1
        imageCarouselView.set(gradientImages: viewModel.gradientImages)
        isFavoriteButtonHidden = !viewModel.state.isFavoriteAvailable
        isFavoriteButtonSelected = viewModel.state.isFavorite
		
        badgeTitle = viewModel.badge
        smallText = viewModel.age
        subtitle = viewModel.typeAndDates
        distance = viewModel.distanceInfo
        shouldShowContestIcon = viewModel.shouldShowCompetitionIcon
        shouldShowPanoramaIcon = viewModel.shouldShowPanoramaIcon
        bottomStackViewConstraint.constant = hasBottomInfo ? 15 : 10
        bottomTitleConstraint.constant = hasBottomInfo ? 10 : 0
        routeInfo = viewModel.getRouteInfo()
        bottomGradientView.isHidden = !viewModel.shouldShowBottomGradient
    }

    @IBAction func onCloseButtonClick(_ sender: Any) {
        onClose?()
    }

    @IBAction func onAddButtonTouch(_ button: UIButton) {
        button.isSelected.toggle()
        onAdd?()
    }

    @IBAction func onPanoramaButtonTouch(_ sender: Any) {
        onPanorama?()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupConstraints()
        setupGradient()

        smallLabel.layer.cornerRadius = 3
        smallLabel.layer.backgroundColor = DetailHeaderView.ageLabelBackgroundColor.cgColor

        badgeTitle = nil
        subtitle = nil
        smallText = nil
        distance = nil
        shouldShowContestIcon = false
        stackViewToFavoriteConstraint.isActive = false

        favoriteButton.setImage(
            UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        favoriteButton.setImage(
            UIImage(named: "saved")?.withRenderingMode(.alwaysTemplate),
            for: .selected
        )
        favoriteButton.tintColor = .white
    }

    func prepareForTransition() {
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.setNeedsLayout()
                self?.closeButton.isHidden = true
            },
            completion: nil
        )
    }

    private func setupConstraints() {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        closeButton.topAnchor.constraint(
            equalTo: self.topAnchor,
            constant: 6 + statusBarHeight
        ).isActive = true

		closeButton.imageView?.make(.size, .equal, [10, 10])
		closeButton.imageView?.make(.center, .equalToSuperview)
    }

    private func setupGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
          UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor,
          UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        ]

        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.transform = CATransform3DMakeAffineTransform(
            CGAffineTransform(a: 0, b: -1, c: 1, d: 0, tx: 0.05, ty: 1)
        )

        gradientLayer.frame = bottomGradientView.bounds.insetBy(
            dx: -0.5 * bottomGradientView.bounds.size.width,
            dy: -0.5 * bottomGradientView.bounds.size.height
        )

        bottomGradientView.layer.addSublayer(gradientLayer)
    }
}
