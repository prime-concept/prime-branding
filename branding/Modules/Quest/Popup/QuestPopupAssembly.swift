import UIKit

final class QuestPopupAssembly: UIViewControllerAssemblyProtocol {
    private var isCorrectAnswer: Bool
    private var reward: Int
    private var dismissCompletion: (() -> Void)?

    init(
        isCorrectAnswer: Bool,
        reward: Int,
        dismissCompletion: (() -> Void)? = nil
    ) {
        self.isCorrectAnswer = isCorrectAnswer
        self.reward = reward
        self.dismissCompletion = dismissCompletion
    }

    func buildModule() -> UIViewController {
        let controller = QuestPopupViewController(
            isCorrectAnswer: isCorrectAnswer,
            reward: reward,
            dismissCompletion: dismissCompletion
        )
        return controller
    }
}
