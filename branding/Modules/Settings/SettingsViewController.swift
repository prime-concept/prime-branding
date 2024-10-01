import MessageUI
import SafariServices
import UIKit

protocol SettingsViewProtocol: class, SFViewControllerPresentable, SendEmailProtocol {
    func display(rows: [SettingsRowViewModel])
    func sendEmail(to receiverEmail: String, subject: String) throws
    func showDestructiveAlert(destruct: @escaping () -> Void)
    func dismiss()
}

fileprivate extension String {
    static let settingsSimpleCell = "\(SettingsSimpleTableCell.self)"
    static let settingsSwitchCell = "\(SettingsSwitchTableCell.self)"
}

fileprivate extension CGFloat {
    static let cellHeight: CGFloat = 64
}

final class SettingsViewController: UIViewController, TableViewCellRegisterable {
    var presenter: SettingsPresenterProtocol?
    let application = UIApplication.shared

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            setUpTableView()
        }
    }

    var tableModel: [SettingsRowViewModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = LS.localize("Settings")

        presenter?.reloadData()
        AnalyticsEvents.Settings.opened.send()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }

    func setUpTableView() {
        tableView.register(cellClass: SettingsSimpleTableCell.self)
        tableView.register(cellClass: SettingsSwitchTableCell.self)

        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension SettingsViewController: SettingsViewProtocol {
    func sendEmail(to receiverEmail: String, subject: String) throws {
        guard let controller = emailController(
            to: receiverEmail,
            subject: subject,
            messageBody: nil
        ) else {
            throw EmailCreationError()
        }
        controller.mailComposeDelegate = self
        ModalRouter(source: self, destination: controller).route()
    }

    func display(rows: [SettingsRowViewModel]) {
        self.tableModel = rows
        tableView.reloadData()
    }

    func showDestructiveAlert(destruct: @escaping () -> Void) {
        let alert = AlertContollerFactory.makeDestructionAlert(
            with: LS.localize("DeleteUserPrompt"),
            destructTitle: LS.localize("Delete"),
            destruct: destruct
        )
        self.present(alert, animated: true)
    }

    func dismiss() {
        navigationController?.popViewController(animated: true)
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return tableModel.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let item = tableModel[indexPath.row]
        switch item {
        case .pushNotifications:
            let cell: SettingsSwitchTableCell = tableView.dequeueReusableCell(
                for: indexPath
            )

            cell.itemTitleLabel.text = item.title

            return cell
        case .writeUs,
             .userAgreement,
             .logOut,
             .privacyPolicy,
             .deleteUser:

            let cell: SettingsSimpleTableCell = tableView.dequeueReusableCell(
                for: indexPath
            )
            cell.itemTitleLabel.text = item.title

            if case .logOut = item {
                cell.itemTitleLabel.textColor = .redColor
            }

            return cell
        }
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return .cellHeight
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        presenter?.selected(
            row: tableModel[indexPath.row]
        )
    }

    func tableView(
        _ tableView: UITableView,
        shouldHighlightRowAt indexPath: IndexPath
    ) -> Bool {
        return tableModel[indexPath.row] != .pushNotifications
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true, completion: nil)
    }
}
