import UIKit

enum QuestStatus {
    case done
    case available
    case notAvailable

    var image: UIImage? {
        switch self {
        case .done:
            return UIImage(named: "quest-status-done")
        case .available:
            return nil
        case .notAvailable:
            return UIImage(named: "quest-status-not-available")
        }
    }

    var title: String {
        switch self {
        case .done:
            return LS.localize("Completed")
        case .available:
            return LS.localize("Available")
        case .notAvailable:
            return LS.localize("NotAvailable")
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .done:
            return .redColor
        case .available:
            return .white
        case .notAvailable:
            return .lightGrayColor
        }
    }

    var textColor: UIColor {
        switch self {
        case .done:
            return .white
        case .available:
            return .redColor
        case .notAvailable:
            return .white
        }
    }

    init?(status: String) {
        switch status {
        case "available":
            self = .available
        case "passed":
            self = .done
        case "unavailable":
            self = .notAvailable
        default:
            return nil
        }
    }
}

class QuestTileView: ImageTileView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var leftTopLabel: PaddingLabel!
    @IBOutlet private weak var blurView: UIView!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private var pointsDescriptionLabel: UILabel!
    @IBOutlet private var placeDescriptionLabel: UILabel!
    @IBOutlet private var statusImageView: UIImageView!
    @IBOutlet private weak var statusView: UIView!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private var cupToBlurViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet private var cupToSafeAreaLeftConstraint: NSLayoutConstraint!

    private var isInit = false

    @IBAction func onShareButtonClick(_ sender: Any) {
        onShareTap?()
    }

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var pointsDescription: String? {
        didSet {
            pointsDescriptionLabel.text = pointsDescription
        }
    }

    var placeDescription: String? {
        didSet {
            placeDescriptionLabel.text = placeDescription
        }
    }

    var leftTopText: String? {
        didSet {
            blurView.isHidden = (leftTopText ?? "").isEmpty
            leftTopLabel.isHidden = (leftTopText ?? "").isEmpty
            leftTopLabel.text = leftTopText
            cupToSafeAreaLeftConstraint.priority = leftTopLabel.isHidden
                                                 ? .defaultHigh
                                                 : .defaultLow
            cupToBlurViewLeftConstraint.priority = leftTopLabel.isHidden
                                                    ? .defaultLow
                                                    : .defaultHigh
        }
    }

    var status: QuestStatus? {
        didSet {
            statusImageView.isHidden = status == nil
            statusImageView.image = status?.image
            statusLabel.text = status?.title
            statusLabel?.textColor = status?.textColor
            statusView.backgroundColor = status?.backgroundColor
        }
    }

    var onShareTap: (() -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()

        statusView.roundCorners(corners: [.topLeft, .bottomLeft], radius: 10)
        if !isInit {
            isInit = true

            shareButton.setImage(
                UIImage(named: "share")?.withRenderingMode(.alwaysTemplate),
                for: .normal
            )
        }
    }
}
