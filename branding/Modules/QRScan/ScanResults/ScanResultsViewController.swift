import UIKit

enum ScanResultsMode: Equatable {
    static func == (lhs: ScanResultsMode, rhs: ScanResultsMode) -> Bool {
        switch (lhs, rhs) {
        case (.data(let left), .data(let right)):
            return left == right
        case (.processing, .processing):
            return true
        default:
            return false
        }
    }

    case data(ScanResult)
    case processing

    var image: UIImage? {
        switch self {
        case .data(let result) where result.type == .success:
            return UIImage(named: "qr-upload-success")
        case .processing:
            return UIImage(named: "qr-upload-processing")
        default:
            return UIImage(named: "qr-upload-failed")
        }
    }
}

final class ScanResultsViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    @IBOutlet private weak var spinnerView: FirstTintSpinnerView!

    // MARK: - Private properties
    private var mode: ScanResultsMode
    private var onClose: (() -> Void)?

    // MARK: - Initialization
    init(mode: ScanResultsMode, onClose: (() -> Void)?) {
        self.mode = mode
        self.onClose = onClose
        super.init(nibName: "ScanResultsViewController", bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setup()
        navigationItem.backBarButtonItem = nil
        navigationItem.hidesBackButton = true
    }

    // MARK: - Private methods
    private func setupNavigationBar() {
        navigationItem.title = LS.localize("ScanResults")
    }

    private func setup() {
        imageView.image = mode.image

        switch mode {
        case .processing:
            spinnerView.isHidden = false
            leftButton.isHidden = true
            rightButton.isHidden = true

            titleLabel.text = LS.localize("ScanResultProcessingTitle")
            subtitleLabel.text = LS.localize("ScanResultProcessingDescription")

        case .data(let result):
            titleLabel.text = result.title
            subtitleLabel.text = result.description

            switch result.type {
            case .success:
                rightButton.isHidden = true
                leftButton.setTitle(LS.localize("ScanResultOpenMenu"), for: .normal)
            default:
                rightButton.setTitle(LS.localize("ScanResultTryAgain"), for: .normal)
                leftButton.setTitle(LS.localize("Cancel"), for: .normal)
            }
        }

        if mode == .processing {
            spinnerView.isHidden = false
        }
    }

    @IBAction func onRightAction(_ button: UIButton) {
        switch mode {
        case .data(let result):
            switch result.type {
            case .success:
                break
            default:
                dismiss(animated: true)
            }
        default:
            break
        }
    }

    @IBAction func onLeftAction(_ button: UIButton) {
        switch mode {
        case .data(let result):
            switch result.type {
            case .success:
                dismiss(animated: true)
                TabBarRouter(tab: 0).route()
            default:
                dismiss(animated: true)
            }
        default:
            break
        }
    }
}
