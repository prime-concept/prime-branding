import Nuke
import UIKit

struct QuestViewModel {
    var title: String
    var reward: Int
    var question: String
    var answers: [String]
    var imageURL: URL?

    init(quest: Quest) {
        title = quest.title
        reward = quest.reward
        question = quest.question
        answers = quest.answers
        imageURL = URL(string: quest.images.first?.image ?? "")
    }
}

protocol QuestViewProtocol: class, ModalRouterSourceProtocol, CustomErrorShowable {
    var presenter: QuestPresenterProtocol? { get set }

    func set(viewModel: QuestViewModel)
    func dismiss()
}

final class QuestViewController: UIViewController {
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var shadowImageView: UIImageView!
    @IBOutlet private weak var choicesStackView: UIStackView!
    @IBOutlet private weak var submitButton: QuestSubmitButton!
    @IBOutlet private weak var questTitleLabel: UILabel!
    @IBOutlet private weak var pointsLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var headerImageView: UIImageView!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!

    private static let dismissOffsetThreshold: CGFloat = -80

    private lazy var imageGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        ]
        layer.locations = [0.17, 1]
        layer.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer.endPoint = CGPoint(x: 0.75, y: 0.5)
        layer.transform = CATransform3DMakeAffineTransform(
            CGAffineTransform(a: 0, b: -1, c: 1, d: -0.03, tx: -0.01, ty: 1.01)
        )
        return layer
    }()

    private lazy var statusBarOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.0
        return view
    }()

    private lazy var options = ImageLoadingOptions.cacheOptions

    private var currentChoices: [QuestChoiceControl] = []

    private var shouldUseLightStatusBar = true {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return shouldUseLightStatusBar ? .lightContent : .default
    }

    var presenter: QuestPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        scrollView.delegate = self

        headerView.layer.insertSublayer(imageGradientLayer, above: headerImageView.layer)
        view.addSubview(statusBarOverlayView)

        shadowImageView.image = UIImage(named: "quest-shadow")?.resizableImage(
            withCapInsets: UIEdgeInsets(top: 31, left: 31, bottom: 31, right: 31)
        )

        shareButton.setImage(
            UIImage(named: "share")?.withRenderingMode(.alwaysTemplate),
            for: .normal
        )

        presenter?.didLoad()
        presenter?.refresh()
        submitButton.setTitle(LS.localize("Submit"), for: .normal)
        submitButton.isEnabled = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        imageGradientLayer.position = headerView.center
        imageGradientLayer.frame = headerView.bounds.insetBy(
            dx: -0.5 * headerView.bounds.size.width,
            dy: -0.5 * headerView.bounds.size.height
        )

        statusBarOverlayView.frame = UIApplication.shared.statusBarFrame
    }

    @objc
    private func choiceSelected(_ sender: QuestChoiceControl) {
        currentChoices.forEach { $0.isSelected = false }
        sender.isSelected = true
        submitButton.isEnabled = true
    }

    private func loadImage(from url: URL) {
        Nuke.loadImage(
            with: url,
            options: options,
            into: headerImageView
        )
    }

    @IBAction func onCloseButtonClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onSubmitButtonClick(_ sender: Any) {
        if let choiceIndex = currentChoices.firstIndex(where: { $0.isSelected }) {
            presenter?.send(answer: choiceIndex + 1)
        }
    }
}

extension QuestViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y

        if offset < QuestViewController.dismissOffsetThreshold {
            dismiss(animated: true, completion: nil)
        }

        statusBarOverlayView.alpha = max(
            0.0,
            min(1.0, offset / headerView.frame.height)
        )
        shouldUseLightStatusBar = statusBarOverlayView.alpha < 0.4
    }
}

extension QuestViewController: QuestViewProtocol {
    func set(viewModel: QuestViewModel) {
        questTitleLabel.text = viewModel.title
        pointsLabel.text = "+\(viewModel.reward) " + LS.localize("Points")
        questionLabel.text = viewModel.question

        if let url = viewModel.imageURL {
            loadImage(from: url)
        }

        for answer in viewModel.answers {
            let choiceControl = QuestChoiceControl(frame: .zero)
            choiceControl.text = answer
            choiceControl.addTarget(
                self,
                action: #selector(self.choiceSelected(_:)),
                for: .touchUpInside
            )
            currentChoices.append(choiceControl)
            choicesStackView.addArrangedSubview(choiceControl)
        }
    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}
