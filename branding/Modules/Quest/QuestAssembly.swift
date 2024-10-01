import UIKit

final class QuestAssembly: UIViewControllerAssemblyProtocol {
    private var id: String

    init(id: String) {
        self.id = id
    }

    func buildModule() -> UIViewController {
        let questVC = QuestViewController()
        questVC.presenter = QuestPresenter(
            view: questVC,
            questsAPI: QuestsAPI(),
            questID: id
        )
        return questVC
    }
}
