import UIKit

class LoyaltyGoodsListViewController: DetailViewController {
    // MARK: - Private properties
    private lazy var bottomButtonView: LoyaltyGoodsListBottomView = .fromNib()

    // MARK: - Public properties
    var presenter: LoyaltyGoodsListPresenterProtocol?

    override var rows: [DetailRow] {
        return [
            .loyaltyGoodsList
        ]
    }

    override var bottomInset: CGFloat {
        return 65
    }

    // MARK: - Initialization
    init() {
        super.init(nibName: "DetailViewController", bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        buildViewService.set(rows: rows)
        setupSubviews()
        presenter?.load()
    }

    // MARK: - Private methods
    private func setupSubviews() {
        view.addSubview(bottomButtonView)
        bottomButtonView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
            make.height.equalTo(65)
        }
    }

    private func buildView(row: DetailRow, viewModel: LoyaltyGoodsListViewModel) -> UIView? {
        switch row {
        case .loyaltyGoodsList:
            let typedView = row.buildView(from: viewModel.goods) as? DetailLoyaltyGoodsListView
            typedView?.onChoseGood = { [weak self] model in
                if let position = model.position {
                    self?.presenter?.selectGood(position: position)
                }
            }
            typedView?.onLayoutUpdate = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            typedView?.onShareTap = { [weak self] model in
                if let position = model.position {
                    self?.presenter?.shareGood(position: position)
                }
            }

            return typedView
        default:
            break
        }

        fatalError("Unsupported detail row")
    }
}

extension LoyaltyGoodsListViewController: LoyaltyGoodsListViewProtocol {
    func set(viewModel: LoyaltyGoodsListViewModel) {
        updateHeaderViewContent(viewModel: viewModel.header)

        buildViewService.update(with: viewModel, for: tableView) { row in
            buildView(row: row, viewModel: viewModel)
        }
    }

    func setBottomView(viewModel: LoyaltyGoodsListBottomViewModel) {
        bottomButtonView.update(with: viewModel)
    }

    func showScan() {
        TabBarRouter(tab: 2).route()
        dismiss()
    }
}
