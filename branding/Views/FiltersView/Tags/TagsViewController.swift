import DeckTransition
import UIKit

final class TagsViewController: UIViewController, DeckTransitionViewControllerProtocol {
    private static let cornerRadius: CGFloat = 22
    private static let clearBackgroundColor = UIColor(
        red: 0.95,
        green: 0.95,
        blue: 0.95,
        alpha: 1
    )

    private var tags: [SearchTagViewModel] {
        didSet {
            tableView.reloadData()
        }
    }

    @IBOutlet private weak var tagsLabel: UILabel!

    @IBAction func onClearButtonTap(_ sender: Any) {
        for index in tags.indices {
            tags[index].selected = false
        }
    }

    @IBAction func onApplyButtonTap(_ sender: Any) {
        filtersDelegate?.setupTags(with: tags)
        dismiss(animated: true, completion: nil)
    }

    @IBOutlet private weak var clearButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var applyButton: UIButton!

    private weak var filtersDelegate: FiltersDelegate?

    var scrollViewForDeck: UIScrollView {
        return tableView
    }

    init(
        tags: [SearchTagViewModel],
        filtersDelegate: FiltersDelegate?
    ) {
        self.tags = tags
        self.filtersDelegate = filtersDelegate

        super.init(nibName: "TagsViewController", bundle: .main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupUI()
    }

    private func setupUI() {
        applyButton.layer.masksToBounds = true
        applyButton.layer.cornerRadius = TagsViewController.cornerRadius
        applyButton.backgroundColor = ApplicationConfig.Appearance.bookButtonColor
        applyButton.setTitle(LS.localize("Apply"), for: .normal)
		applyButton.sizeToFit()

        clearButton.layer.masksToBounds = true
        clearButton.layer.cornerRadius = TagsViewController.cornerRadius
        clearButton.tintColor = ApplicationConfig.Appearance.bookButtonColor
        clearButton.backgroundColor = TagsViewController.clearBackgroundColor
        clearButton.setTitle(LS.localize("Clear"), for: .normal)
		clearButton.sizeToFit()

        tagsLabel.text = LS.localize("Tags")
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cellClass: TagsTableViewCell.self)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TagsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TagsTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.setup(with: tags[indexPath.row])
        return cell
    }
}

extension TagsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tags[indexPath.row].selected = !tags[indexPath.row].selected
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
