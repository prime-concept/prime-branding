import UIKit

protocol ProfileViewProtocol: class, SFViewControllerPresentable, ModalRouterSourceProtocol {
    func display(rows: [ProfileRowViewModel])
}

final class ProfileViewController: UIViewController, TableViewCellRegisterable {
    var presenter: ProfilePresenterProtocol?

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            setUpTableView()
        }
    }

    var tableModel: [ProfileRowViewModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter?.reloadData()

        guard FeatureFlags.loyaltyEnabled else {
            return
        }
        presenter?.loadLoyaltyCard()
        presenter?.loadBalance()
        presenter?.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presenter?.viewDidAppear()
    }
	
    func setUpTableView() {
        tableView.register(cellClass: ProfileInfoTableCell.self)
        tableView.register(cellClass: ProfileItemTableCell.self)
        tableView.register(cellClass: ProfileAchievementTableCell.self)
        tableView.register(cellClass: LoyaltyTableViewCell.self)
        tableView.register(cellClass: SocialAccountsTableCell.self)
        tableView.register(cellClass: PrimeLoyaltyTableViewCell.self)
        tableView.register(cellClass: ProfileBookingTableViewCell.self)

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 67
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension ProfileViewController: ProfileViewProtocol {
    func display(rows: [ProfileRowViewModel]) {
        self.tableModel = rows
        tableView.reloadData()
    }
}

extension ProfileViewController: UITableViewDataSource {
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
        switch tableModel[indexPath.row] {
        case .profile(let profileModel):

            let cell: ProfileInfoTableCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setUp(
                with: profileModel
            )
            return cell

        case .item(let itemModel, let number):

            let cell: ProfileItemTableCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setUp(
                with: itemModel,
                number: number
            )
            return cell
        case .achievement(let model, let registrationsCount):
            let cell: ProfileAchievementTableCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setupView(
                with: model,
                registrationsCount: registrationsCount
            )
            return cell
        case .booking(let model):
            let cell: ProfileBookingTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setup(with: model)
            return cell
        }
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter?.selected(row: tableModel[indexPath.row])
    }

    func tableView(
        _ tableView: UITableView,
        shouldHighlightRowAt indexPath: IndexPath
    ) -> Bool {
        return true
    }
}
