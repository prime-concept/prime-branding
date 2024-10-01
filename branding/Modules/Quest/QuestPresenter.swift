import Foundation

extension Notification.Name {
    static let questDone = Notification.Name("quest.done")
}

protocol QuestPresenterProtocol {
    func didLoad()
    func refresh()
    func send(answer: Int)
}

final class QuestPresenter: QuestPresenterProtocol {
    static let questDoneIDKey = "questDoneID"

    weak var view: QuestViewProtocol?

    private var questsAPI: QuestsAPI
    private var questID: String
    private var quest: Quest?

    init(
        view: QuestViewProtocol,
        questsAPI: QuestsAPI,
        questID: String
    ) {
        self.view = view
        self.questsAPI = questsAPI
        self.questID = questID
    }

    private func loadQuest() {
        _ = questsAPI.retrieveQuest(id: questID).done { [weak self] quest in
            self?.quest = quest
            self?.view?.set(viewModel: QuestViewModel(quest: quest))
        }
    }

    private func showPopup(isCorrectAnswer: Bool) {
        NotificationCenter.default.post(
            name: .questDone,
            object: nil,
            userInfo: [QuestPresenter.questDoneIDKey: questID]
        )
        let popupAssembly = QuestPopupAssembly(
            isCorrectAnswer: isCorrectAnswer,
            reward: quest?.reward ?? 0,
            dismissCompletion: view?.dismiss
        )
        let router = PopupRouter(source: view, destination: popupAssembly.buildModule())
        router.route()
    }

    func didLoad() {
        AnalyticsEvents.Quest.opened(id: questID).send()
    }

    func refresh() {
        loadQuest()
    }

    func send(answer: Int) {
        guard let quest = self.quest else {
            return
        }

        if !LocalAuthService.shared.isAuthorized {
            view?.showError(text: LS.localize("QuestError"))
            return
        }

        _ = questsAPI.answer(with: answer, for: quest.id).done { [weak self] isCorrect in
            AnalyticsEvents.Quest.completed(
                question: quest.question,
                answer: quest.answers[safe: answer - 1] ?? "",
                result: isCorrect
            ).send()
            self?.showPopup(isCorrectAnswer: isCorrect)
        }
    }
}
