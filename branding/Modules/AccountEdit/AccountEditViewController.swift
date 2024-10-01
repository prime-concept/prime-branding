import UIKit

protocol AccountEditViewProtocol: class {
    func display(rows: [AccountEditRowViewModel])
    func getEditedRowViewModels() -> [AccountEditRowViewModel]
    func dismiss()
}

fileprivate extension String {
    static let accountEditCell = "\(AccountEditTableCell.self)"
}

fileprivate extension CGFloat {
    static let cellHeight: CGFloat = 68
}

final class AccountEditViewController: UIViewController, TableViewCellRegisterable {
    var presenter: AccountEditPresenterProtocol?
    let application = UIApplication.shared

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            setUpTableView()
        }
    }
    @IBOutlet private weak var loyaltyLabel: UILabel!
    @IBOutlet private weak var loyaltyContainerView: UIView!

    var tableModel: [AccountEditRowViewModel] = []
    var values: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = LS.localize("Me")

        if presenter?.accountEditMode == .registration {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: LS.localize("Save"),
                style: .plain,
                target: self,
                action: #selector(onSaveButtonTap)
            )
        }

        loyaltyContainerView.isHidden = !(presenter?.shouldShowLoyaltyInfo ?? true)
        loyaltyLabel.text = LS.localize("AccountEditLoyaltyInfo")
        presenter?.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        // Call endEditing to force call onChange for each cells
        // before call save() in presenter
        view.window?.endEditing(true)
        super.viewWillDisappear(animated)
        presenter?.save()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }

    func setUpTableView() {
        tableView.register(cellClass: AccountEditTableCell.self)
        tableView.delegate = self
        tableView.dataSource = self
    }

    @objc
    private func onSaveButtonTap() {
        view.endEditing(true)
        presenter?.checkFilling()
    }
}

extension AccountEditViewController: AccountEditViewProtocol {
    func display(rows: [AccountEditRowViewModel]) {
        self.tableModel = rows
        self.values = rows.map {
            switch $0 {
            case .name(let value),
                 .familyName(let value),
                 .email(let value),
                 .phoneNumber(let value):
                return value
            }
        }
        tableView.reloadData()
    }

    func getEditedRowViewModels() -> [AccountEditRowViewModel] {
        return tableModel.enumerated().map {
            switch $0.element {
            case .email:
                return .email(values[$0.offset])
            case .familyName:
                return .familyName(values[$0.offset])
            case .name:
                return .name(values[$0.offset])
            case .phoneNumber:
                return .phoneNumber(values[$0.offset])
            }
        }
    }

    func dismiss() {
        navigationController?.dismiss(animated: true)
    }
}

extension AccountEditViewController: UITableViewDataSource {
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
        let cell: AccountEditTableCell = tableView.dequeueReusableCell(for: indexPath)
        let item = tableModel[indexPath.row]

        switch item {
        case .name(let value),
             .familyName(let value),
             .email(let value):

            cell.setUp(
                with: item.title,
                placeholder: item.placeholder,
                value: value,
                onChange: { [weak self] changedTitle in
                    self?.values[indexPath.row] = changedTitle
                }
            )
        case .phoneNumber(let value):
            cell.setUp(
                with: item.title,
                placeholder: item.placeholder,
                value: value,
                keyboardType: .numberPad,
                onChange: { [weak self] changedTitle in
                    self?.values[indexPath.row] = changedTitle
                }
            )

            cell.change(keyboardType: .phonePad)
        }

        return cell
    }
}

extension AccountEditViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        shouldHighlightRowAt indexPath: IndexPath
    ) -> Bool {
        return false
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return .cellHeight
    }
}
