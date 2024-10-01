import StoreKit
import UIKit

protocol RateViewProtocol: class {
    var presenter: RatePresenterProtocol? { get set }

    func updateViewModel(viewModel: PopupViewModel)
    func sendToAppStore()
}

final class RateViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!

    var presenter: RatePresenterProtocol?

    private var popupViewModel: PopupViewModel
    private var viewList: [UIView] = []
    private var inputMessage: String = ""

    init(popupViewModel: PopupViewModel) {
        self.popupViewModel = popupViewModel
        super.init(nibName: nil, bundle: nil)

        setupSubviews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        for view in viewList {
            stackView.addArrangedSubview(view)
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateViewForReview() {
        resetViewList()

        setupSubviews()

        let sendReviewButton: PopupButtonView = .fromNib()
        sendReviewButton.setup(buttonType: .defaultButton)
        sendReviewButton.onClick = { [weak self] in
            self?.presenter?.send(message: self?.inputMessage ?? "")
            self?.dismiss(animated: true, completion: nil)
        }
        viewList.append(sendReviewButton)

        let cancelButton: PopupButtonView = .fromNib()
        cancelButton.setup(buttonType: .cancel)
        cancelButton.onClick = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        viewList.append(cancelButton)

        for view in viewList {
            stackView.addArrangedSubview(view)
        }

        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }

    private func resetViewList() {
        viewList.removeAll()

        for view in stackView.subviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    func setupSubviews() {
        if !popupViewModel.title.isEmpty {
            let view: TitleLabel = .fromNib()
            view.setup(viewModel: popupViewModel)
            viewList.append(view)
        }

        if !popupViewModel.message.isEmpty {
            let view: PopupMessageLabel = .fromNib()
            view.setup(viewModel: popupViewModel)
            viewList.append(view)
        }

        if popupViewModel.isInputFieldExist {
            let view: InputMessage = .fromNib()
            viewList.append(view)

            view.onChange = { [weak self] message in
                self?.inputMessage = message
            }
        }

        if popupViewModel.isRatingViewExist {
            let view: PopupRatingStarsView = .fromNib()
            viewList.append(view)

            view.onStarSelect = { [weak self] rating in
                self?.presenter?.select(rating: rating)
            }
        }

        let button = UIButton(type: .custom)
        button.setTitle(NSLocalizedString("Later", comment: ""), for: .normal)
        button.tintColor = UIColor.gray
        button.setTitleColor(UIColor.gray, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        viewList.append(button)
    }

    @objc
    func cancelPressed() {
        presenter?.cancel()
        dismiss(animated: true, completion: nil)
    }
}

extension RateViewController: RateViewProtocol {
    func updateViewModel(viewModel: PopupViewModel) {
        popupViewModel = viewModel
        updateViewForReview()
    }

    func sendToAppStore() {
        dismiss(
            animated: true,
            completion: {
                if #available(iOS 10.3, *) {
                    SKStoreReviewController.requestReview()
                } else {
                    if let url = ApplicationConfig.StringConstants.rateUrl {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
        )
    }
}
