import Foundation

protocol EventFeedbackPresenterProtocol: class {
    func updateViewModel(index: Int)
    func updateFeedback(feedback: String)
    func sendFeedback()
    func viewWillAppear()
}

final class EventFeedbackPresenter: EventFeedbackPresenterProtocol {
    weak var view: EventFeedbackViewControllerProtocol?
    var eventFeedbackAPI: EventFeedbackAPI
    var eventInfo: EventFeedbackInfo
    var feedback: EventFeedback
    
    init(
        view: EventFeedbackViewControllerProtocol,
        info: EventFeedbackInfo,
        eventFeedbackAPI: EventFeedbackAPI
    ) {
        self.view = view
        self.eventInfo = info
        self.eventFeedbackAPI = eventFeedbackAPI
        self.feedback = EventFeedback(
            comment: "",
            id: self.eventInfo.id,
            stars: 0)
        createViewModel()
    }
    
    func viewWillAppear() {
        self.setupView()
    }
    
    func createViewModel(selectedIndex: Int? = nil) {
        var viewModel = Array(
            repeating: StarViewModel(
                position: .average,
                isSelected: false),
            count: 5
        )
        viewModel[0].position = .first
        viewModel[4].position = .last
        if let index = selectedIndex {
            viewModel.indices.forEach {
                viewModel[$0].isSelected = ($0 <= index)
            }
        }
        self.view?.set(viewModel: viewModel)
    }
    
    func setupView() {
        self.convertDate()
        self.view?.setupInfo(info: self.eventInfo)
    }

    func updateViewModel(index: Int) {
        self.feedback.stars = index + 1
        self.createViewModel(selectedIndex: index)
    }
    
    func sendFeedback() {
        eventFeedbackAPI.rateEvent(feedback: self.feedback).done {
            print("event feedback sent")
            self.view?.showGratitudeView()
        }.catch { error in
            print("error while sending app feedback: \(error)")
        }
    }
    
    func updateFeedback(feedback: String) {
        self.feedback.comment = feedback
    }
    
    private func convertDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, HH:mm"
        self.eventInfo.timeSlot = formatter.string(
            from: Date(
                string: self.eventInfo.timeSlot
            )
        )
    }
}

struct EventFeedbackInfo {
    let id: String
    var timeSlot: String
    let title: String
}

struct EventFeedback {
    var comment: String
    var id: String
    var stars: Int
}
