import UIKit

final class TicketsManualViewConroller: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var ticketLabel: UILabel!
    @IBOutlet private weak var changeLabel: UILabel!
    @IBOutlet private weak var dockLabel: UILabel!
    @IBOutlet private weak var clockLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabelsText()
    }

    private func updateLabelsText() {
        titleLabel.text = LS.localize("TitleManual")
        ticketLabel.text = LS.localize("TicketLabel")
        changeLabel.text = LS.localize("ChangeLabel")
        dockLabel.text = LS.localize("DockLabel")
        clockLabel.text = LS.localize("ClockLabel")
    }
}
