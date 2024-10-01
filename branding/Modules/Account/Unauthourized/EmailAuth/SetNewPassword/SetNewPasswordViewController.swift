import UIKit

protocol SetNewPasswordViewProtocol: class {
    func getEditedRowViewModels() -> [EmailLoginViewModel]
    func dismiss()
    func show(error: String, for row: Int)
    func set(validationErrors: [String?])
}

final class SetNewPasswordViewController: BaseEmailAuthViewController, SetNewPasswordViewProtocol {
    var presenter: SetNewPasswordPresenterProtocol?

    override var tableModels: [EmailLoginViewModel] {
        return [
            .logo,
            .password(""),
            .actionButton
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = LS.localize("EnterNewPassword")
        let barButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(onBarButtonTouch)
        )
        navigationItem.leftBarButtonItem = barButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)
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
        case .password:
            let cell: InputTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setup(
                with: item.title,
                placeholder: item.placeholder,
                isSecurityInput: true,
				value: values[indexPath.row],
                error: errors[indexPath.row],
                onChange: { [weak self] changedValue in
                    self?.values[indexPath.row] = changedValue
                }
            )
            return cell
        case .actionButton:
            let cell: ActionButtonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setup(with: LS.localize("RefreshPassword")) { [weak self] in
                self?.view.endEditing(true)
                self?.presenter?.refresh()
            }
            return cell
        default:
            fatalError("Not implemented")
        }
    }

    override func dismiss() {
        dismiss(animated: true, completion: nil)
    }

    @objc
    private func onBarButtonTouch() {
        dismiss()
    }
}
