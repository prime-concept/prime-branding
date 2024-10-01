import UIKit

protocol EmailLoginViewProtocol: class, PushRouterSourceProtocol {
    func getEditedRowViewModels() -> [EmailLoginViewModel]
    func show(error: String, for row: Int)
    func dismiss()
    func set(validationErrors: [String?])
}

final class EmailLoginViewController: BaseEmailAuthViewController, EmailLoginViewProtocol {
    var presenter: EmailLoginPresenterProtocol?

    override var tableModels: [EmailLoginViewModel] {
        return [
            .logo,
            .email(""),
            .password(""),
            .loginButtons
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter?.didLoad()
        title = LS.localize("LogInWithEmail")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }

    override func setupTableView() {
        super.setupTableView()

        tableView.register(cellClass: LoginButtonsTableViewCell.self)
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
		case .email, .password:
            let cell: InputTableViewCell = tableView.dequeueReusableCell(for: indexPath)
			var isSecure = false
			if case .password(_) = item {
				isSecure = true
			}

            cell.setup(
                with: item.title,
                placeholder: item.placeholder,
				isSecurityInput: isSecure,
				value: values[indexPath.row],
                error: errors[indexPath.row],
                onChange: { [weak self] changedValue in
                    self?.values[indexPath.row] = changedValue
                }
            )
            return cell
        case .loginButtons:
            let cell: LoginButtonsTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setup(
                with: { [weak self] in
                    self?.view.endEditing(true)
                    self?.presenter?.forgetPassword()
                },
                onLoginButtonTouch: { [weak self] in
                    self?.view.endEditing(true)
                    self?.presenter?.login()
                }
            )
            return cell
        default:
            fatalError("Not implemented")
        }
    }
}

