import UIKit

protocol EmailSignInViewProtocol: class, SFViewControllerPresentable {
    func dismiss()
    func getEditedRowViewModels() -> [EmailLoginViewModel]
    func show(error: String, for row: Int)
    func set(validationErrors: [String?])
    var isButtonEnabled: Bool { get set }
}

final class EmailSignInViewController: BaseEmailAuthViewController, EmailSignInViewProtocol {
    var presenter: EmailSignInPresenterProtocol?
    var isButtonEnabled = true {
        didSet {
            self.tableView.reloadData()
        }
    }

    override var tableModels: [EmailLoginViewModel] {
        return [
            .logo,
            .name(""),
            .email(""),
            .password(""),
            .privacyPolicy,
            .actionButton
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter?.didLoad()
        title = LS.localize("SignUp")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }

    override func setupTableView() {
        super.setupTableView()

        tableView.register(cellClass: PrivacyPolicyTableViewCell.self)
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
		case .name, .email, .password:
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
        case .privacyPolicy:
            let cell: PrivacyPolicyTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.onUrlOpen = { [weak self] url in
                self?.open(url: url)
            }
            return cell
        case .loginButtons:
            fatalError("Not implemented")
        case .actionButton:
            let cell: ActionButtonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setup(with: LS.localize("ToSignIn"), isEnabled: self.isButtonEnabled) { [weak self] in
                self?.view.endEditing(true)
                self?.presenter?.signIn()
            }
            return cell
        }
    }
}
