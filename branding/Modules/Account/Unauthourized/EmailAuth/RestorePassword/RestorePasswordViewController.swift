import UIKit

protocol RestorePasswordViewProtocol: class {
    func getEditedRowViewModels() -> [EmailLoginViewModel]
    func dismiss()
    func show(error: String, for row: Int)
    func showCustomAlert()
    func set(validationErrors: [String?])
    func removeCustomAlert()
}

final class RestorePasswordViewController: BaseEmailAuthViewController, RestorePasswordViewProtocol {
    var presenter: RestorePasswordPresenterProtocol?

    override var tableModels: [EmailLoginViewModel] {
        return [
            .logo,
            .email(""),
            .actionButton
        ]
    }

    private var restorePasswordAlertView: RestorePasswordAlertView?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = LS.localize("RestorePassword")
    }

    override func setupTableView() {
        super.setupTableView()

        tableView.register(cellClass: ActionButtonTableViewCell.self)
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let item = tableModels[indexPath.row]

        switch item {
        case .logo:
            let cell: LogoTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            return cell
        case .email:
            let cell: InputTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setup(
                with: item.title,
                placeholder: item.placeholder,
				value: values[indexPath.row],
                error: errors[indexPath.row],
                onChange: { [weak self] changedValue in
                    self?.values[indexPath.row] = changedValue
                }
            )
            return cell
        case .actionButton:
            let cell: ActionButtonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setup(with: LS.localize("RestorePassword")) { [weak self] in
                self?.view.endEditing(true)
                self?.presenter?.restore()
            }
            return cell
        default:
            fatalError("Not implemented")
        }
    }

    func showCustomAlert() {
        guard let view = view.window else {
            return
        }

        let restorePasswordAlertView: RestorePasswordAlertView = .fromNib()
        view.addSubview(restorePasswordAlertView)
        restorePasswordAlertView.translatesAutoresizingMaskIntoConstraints = false
        restorePasswordAlertView.attachEdges(to: view)
        restorePasswordAlertView.onButtonTouch = { [weak self] in
            self?.removeCustomAlert()
            self?.dismiss()
        }
        self.restorePasswordAlertView = restorePasswordAlertView
    }

    func removeCustomAlert() {
        self.restorePasswordAlertView?.removeFromSuperview()
        self.restorePasswordAlertView = nil
    }
}
