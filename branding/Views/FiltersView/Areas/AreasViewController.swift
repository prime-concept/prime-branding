import UIKit

struct SectionModel {
    var letter: String
    var areas: [AreaViewModel]
}

final class AreasViewController: UIViewController {
    private static let cornerRadius: CGFloat = 22
    private static let clearBackgroundColor = UIColor(
        red: 0.95,
        green: 0.95,
        blue: 0.95,
        alpha: 1
    )

    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var districtsLabel: UILabel!
    @IBOutlet private weak var clearButton: UIButton!
    @IBOutlet private weak var applyButton: UIButton!

    private weak var filtersDelegate: FiltersDelegate?

    private var areas: [AreaViewModel] {
        didSet {
            tableView.reloadData()
        }
    }

    private var alphabetSection = [SectionModel]() {
        didSet {
            updateAreasFromSection()
        }
    }

    private var filteredData: [AreaViewModel] = [] {
        didSet {
            alphabetSection = setupSectionPresent(from: filteredData)
            tableView.reloadData()
        }
    }

    init(
        areas: [AreaViewModel],
        filtersDelegate: FiltersDelegate?
    ) {
        self.areas = areas
        self.filtersDelegate = filtersDelegate

        super.init(nibName: "AreasViewController", bundle: .main)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround()
        setupUI()
        setupTableView()
        setupSearchBar()
        filteredData = areas
        alphabetSection = setupSectionPresent(from: areas)
    }

    private func updateAreasFromSection() {
        for area in areas {
            for section in alphabetSection {
                for element in section.areas where area.id == element.id {
                    if let index = areas.firstIndex(where: { $0.id == area.id }) {
                        areas[index].selected = element.selected
                    }
                }
            }
        }
    }

    private func setupSectionPresent(from areas: [AreaViewModel]) -> [SectionModel] {
        let letters = areas.map { area -> String in
            if let letter = area.title.first {
                return String(letter)
            } else {
                return ""
            }
        }
        let alphabet = Array(Set(letters))
        var sectionModels = [SectionModel]()
        for letter in alphabet {
            var letterSection: [AreaViewModel] = []
            for area in areas {
                if let firstLetter = area.title.first {
                    if String(firstLetter) == letter {
                        letterSection.append(area)
                    }
                }
            }
            sectionModels.append(SectionModel(letter: letter, areas: letterSection))
        }
        sectionModels = sectionModels.sorted { $0.letter < $1.letter }
        return sectionModels
    }

    private func setupUI() {
        applyButton.layer.masksToBounds = true
        applyButton.layer.cornerRadius = AreasViewController.cornerRadius
        applyButton.backgroundColor = ApplicationConfig.Appearance.bookButtonColor
        applyButton.setTitle(LS.localize("Apply"), for: .normal)

        clearButton.layer.masksToBounds = true
        clearButton.layer.cornerRadius = AreasViewController.cornerRadius
        clearButton.tintColor = ApplicationConfig.Appearance.bookButtonColor
        clearButton.backgroundColor = AreasViewController.clearBackgroundColor
        clearButton.setTitle(LS.localize("Clear"), for: .normal)

        cancelButton.tintColor = ApplicationConfig.Appearance.bookButtonColor
        cancelButton.setTitle(LS.localize("Cancel"), for: .normal)

        districtsLabel.text = LS.localize("DistrictsAndMetro")
    }

    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = LS.localize("SearchPlaceholder")
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cellClass: AreasTableViewCell.self)
    }

    @IBAction func cancelButtonTap(_ sender: Any) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        filteredData = areas
        cancelButton.isHidden = true
    }

    @IBAction func clearButtonTap(_ sender: Any) {
        for index in filteredData.indices {
            filteredData[index].selected = false
        }
    }

    @IBAction func applyButtonTap(_ sender: Any) {
        filtersDelegate?.setupAreas(with: areas)
        dismiss(animated: true, completion: nil)
    }
}

extension AreasViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return alphabetSection.count
    }

    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        return alphabetSection[section].letter
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alphabetSection[section].areas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AreasTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.setup(with: alphabetSection[indexPath.section].areas[indexPath.row])
        return cell
    }
}

extension AreasViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        alphabetSection[indexPath.section]
            .areas[indexPath.row].selected =
            !alphabetSection[indexPath.section]
                .areas[indexPath.row].selected
        tableView.deselectRow(at: indexPath, animated: false)
        tableView.reloadData()
    }
}

extension AreasViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        cancelButton.isHidden = false
        if let searchText = searchBar.text {
            filteredData = searchText.isEmpty ? areas : areas.filter {(dataString: AreaViewModel) -> Bool in
                let title = dataString.title
                return title.range(of: searchText, options: .caseInsensitive) != nil
            }
            tableView.reloadData()
        }
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        cancelButton.isHidden = false
    }
}
