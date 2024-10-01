import UIKit

final class QuestPopupViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var nextButton: UIButton!

    private var isCorrectAnswer: Bool
    private var reward: Int
    private var dismissCompletion: (() -> Void)?

    init(
        isCorrectAnswer: Bool,
        reward: Int = 0,
        dismissCompletion: (() -> Void)? = nil
    ) {
        self.isCorrectAnswer = isCorrectAnswer
        self.reward = reward
        self.dismissCompletion = dismissCompletion
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        titleLabel.text = isCorrectAnswer
                        ? LS.localize("CorrectAnswer") + " \(reward) " + LS.localize("Points")
                        : LS.localize("WrongAnswer")
        nextButton.titleLabel?.text = LS.localize("Continue")
        imageView.image = isCorrectAnswer
                        ? UIImage(named: "quest-popup-cup-success")
                        : UIImage(named: "quest-popup-cup-fail")
        nextButton.setTitle(LS.localize("QuestContinue"), for: .normal)
    }

    @IBAction func onNextButtonTouch(_ button: UIButton) {
        dismiss(animated: true, completion: dismissCompletion)
    }
}
