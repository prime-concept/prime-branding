import UIKit

protocol TableViewCellRegisterable {
    // swiftlint:disable:next implicitly_unwrapped_optional
    var tableView: UITableView! { get set }
    func registerCells(nibNames: [String])
}

extension TableViewCellRegisterable {
    func registerCells(nibNames: [String]) {
        func registerCell(nibName: String) {
            tableView.register(
                UINib(
                    nibName: nibName,
                    bundle: nil
                ),
                forCellReuseIdentifier: nibName
            )
        }

        nibNames.forEach(registerCell)
    }
}
