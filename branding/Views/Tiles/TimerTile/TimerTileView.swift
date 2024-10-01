import UIKit

class TimerTileView: ImageTileView {
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!

    private var timer = Timer()

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var subtitle: String? {
        didSet {
            subtitleLabel.text = subtitle
        }
    }

    var sourceDate: Date? {
        didSet {
            scheduleTimer()
            updateTimer()
        }
    }

    func scheduleTimer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(updateTimer),
            userInfo: nil,
            repeats: true
        )
    }

    @objc
    func updateTimer() {
        guard let sourceDate = sourceDate else {
            return
        }
        counterLabel.text = getTimeString(sourceDate: sourceDate)
    }

    private func getTimeString(sourceDate: Date) -> String {
        let currentDate = Date()

        guard sourceDate > currentDate else {
            return "0:00:00:00"
        }

        let diff = Calendar.current.dateComponents(
            [.day, .hour, .minute, .second],
            from: currentDate,
            to: sourceDate
        )

        return "\(diff.day ?? 0):\(diff.hour ?? 0):\(diff.minute ?? 0):\(diff.second ?? 0)"
    }
}
