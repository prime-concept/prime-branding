import Foundation

final class DetailPlaceTileView: ImageTileView, ViewReusable, NibLoadable {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var metroLabel: UILabel!
    @IBOutlet private weak var roundedMarker: UIView!
    @IBOutlet private weak var distanceLabel: UILabel!
    @IBOutlet private weak var loyaltyLabel: UILabel!
    @IBOutlet private weak var blurView: BlurView!
    @IBOutlet private weak var addressBottomConstraintToSafeArea: NSLayoutConstraint!
    @IBOutlet private weak var addressBottomConstraintToMetroLabel: NSLayoutConstraint!

    private static let cornerRadius = CGFloat(10)
    private static let rounderMarkerCornerRadius = CGFloat(4)

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var address: String? {
        didSet {
            addressLabel.text = address
        }
    }

    var metro: String? {
        didSet {
            metroLabel.text = metro
            // Change constraint priority to press address label to superview bottom if metro is empty
            addressBottomConstraintToSafeArea.priority = (metro ?? "").isEmpty
                ? .defaultHigh
                : .defaultLow
            addressBottomConstraintToMetroLabel.priority = (metro ?? "").isEmpty
                ? .defaultLow
                : .defaultHigh
        }
    }

    var distance: String? {
        didSet {
            distanceLabel.isHidden = (distance ?? "").isEmpty
            blurView.isHidden = (distance ?? "").isEmpty
            distanceLabel.text = distance
        }
    }

    var shouldShowLoyalty: Bool = false {
        didSet {
            loyaltyLabel.isHidden = !shouldShowLoyalty
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        //wait for api, when metro color will be sent
        roundedMarker.isHidden = true

        loyaltyLabel.text = LS.localize("LoyaltyProgram")

        setupRoundedMarker()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        loyaltyLabel.roundCorners(corners: [.topLeft, .bottomLeft], radius: 8)
    }

    private func setupRoundedMarker() {
        roundedMarker.layer.cornerRadius = DetailPlaceTileView.rounderMarkerCornerRadius
    }
}
