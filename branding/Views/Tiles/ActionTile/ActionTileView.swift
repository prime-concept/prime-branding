import UIKit
import SnapKit

class ActionTileView: ImageTileView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var leftTopLabel: PaddingLabel!
    @IBOutlet private weak var blurView: UIView!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var loyaltyLabel: UILabel!
    @IBOutlet private weak var addButton: AddButton!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var metroAndDistrictLabel: UILabel!
    @IBOutlet private weak var metroImageView: UIImageView!
    @IBOutlet private weak var backgroundMetroImageView: UIView!
    
    private lazy var tagsView = RoundTagsStackView()
    private var diagonalRecommendedBadgeView: DiagonalRecommendedBadgeView?
    private var isInit = false

    @IBAction func onAddButtonClick(_ sender: Any) {
        onAddClick?()
    }

    @IBAction func onShareButtonClick(_ sender: Any) {
        onShareClick?()
    }

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var subtitle: String? {
        didSet {
            subtitleLabel.text = subtitle
        }
    }

    var metro: String? {
        didSet {
            backgroundMetroImageView.isHidden = (metro ?? "").isEmpty
            metroImageView.isHidden = (metro ?? "").isEmpty
        }
    }
    var shouldShowLoyalty: Bool = false {
        didSet {
            loyaltyLabel.isHidden = !shouldShowLoyalty
        }
    }

    var leftTopText: String? {
        didSet {
            blurView.isHidden = (leftTopText ?? "").isEmpty
            leftTopLabel.isHidden = (leftTopText ?? "").isEmpty
            leftTopLabel.text = leftTopText
        }
    }

    var metroAndDistrictText: String? {
        didSet {
            metroAndDistrictLabel.isHidden = (metroAndDistrictText ?? "").isEmpty
            metroAndDistrictLabel.text = metroAndDistrictText
        }
    }
    
    var tagsList: [String] = [] {
        didSet {
            tagsView.setup(with: tagsList)
        }
    }

    var shouldShowRecommendedBadge: Bool = false {
        didSet {
            diagonalRecommendedBadgeView?.isHidden = !shouldShowRecommendedBadge
        }
    }

    var isFavoriteButtonHidden: Bool = true {
        didSet {
            addButton.isHidden = isFavoriteButtonHidden
        }
    }

    var isShareButtonHidden: Bool = true {
        didSet {
            shareButton.isHidden = isShareButtonHidden
        }
    }

    var isFavoriteButtonSelected: Bool = false {
        didSet {
            addButton.isSelected = isFavoriteButtonSelected
        }
    }

    var onAddClick: (() -> Void)?
    var onShareClick: (() -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()

        if !isInit {
            isInit = true

            initDiagonalBadge()

            shareButton.setImage(
                UIImage(named: "share")?.withRenderingMode(.alwaysTemplate),
                for: .normal
            )

            loyaltyLabel.text = LS.localize("LoyaltyProgram")
            loyaltyLabel.roundCorners(corners: [.topLeft, .bottomLeft], radius: 10)
        }
        self.addSubview(self.tagsView)
        self.tagsView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(8)
        }
    }

    private func initDiagonalBadge() {
        let badgeView = DiagonalRecommendedBadgeView()
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        badgeView.isHidden = !shouldShowRecommendedBadge

        self.addSubview(badgeView)
        badgeView.heightAnchor.constraint(
            equalToConstant: 62
        ).isActive = true
        badgeView.widthAnchor.constraint(
            equalToConstant: 62
        ).isActive = true
        badgeView.topAnchor.constraint(
            equalTo: self.topAnchor
        ).isActive = true
        badgeView.rightAnchor.constraint(
            equalTo: self.rightAnchor
        ).isActive = true

        self.diagonalRecommendedBadgeView = badgeView
    }

    func makeCopy() -> ActionTileView {
        let view: ActionTileView = .fromNib()
        view.title = title
        view.subtitle = subtitle
        view.leftTopText = leftTopText
        view.shouldShowLoyalty = shouldShowLoyalty
        view.shouldShowRecommendedBadge = shouldShowRecommendedBadge
        view.backgroundImageView.image = backgroundImageView.image

        return view
    }
}
