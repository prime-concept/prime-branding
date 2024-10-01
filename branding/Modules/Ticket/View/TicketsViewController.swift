import MessageUI
import UIKit

protocol TicketsViewProtocol: class, SFViewControllerPresentable, ModalRouterSourceProtocol, SendEmailProtocol {
    func set(data: [TicketViewModel])
    func set(state: SectionViewState)
    func share(with text: String)
    func sendEmail(to receiverEmail: String, subject: String, messageBody: String) throws
}

final class TicketsViewController: CollectionViewController {
    static let manualButtonColor = UIColor(
        red: 0.15,
        green: 0.14,
        blue: 0.38,
        alpha: 1
    )

    var presenter: TicketsPresenterProtocol?
    let application = UIApplication.shared

    override var shouldUsePagination: Bool {
        return false
    }

    func collectionView(
        _ collectionView: UICollectionView,
        performAction action: Selector,
        forItemAt indexPath: IndexPath,
        withSender sender: Any?
    ) {
        presenter?.returnTicket(at: indexPath.row)
    }

    private var state: SectionViewState = .loading {
        didSet {
            switch state {
            case .normal:
                loadingIndicator.isHidden = true
                collectionView.isHidden = false
                emptyStateView?.isHidden = true
                refreshControl?.endRefreshing()
            case .loading:
                collectionView.isHidden = true
                loadingIndicator.isHidden = false
                emptyStateView?.isHidden = true
            case .empty:
                collectionView.isHidden = false
                loadingIndicator.isHidden = true
                emptyStateView?.isHidden = false
            }
        }
    }

    private var data: [TicketViewModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = LS.localize("MyTickets")
        setupEmptyView(for: .tickets)

        set(state: .loading)

        presenter?.didLoad()
        presenter?.refresh()

        setupNavigationItem()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }

    override func setupCollectionView() {
        super.setupCollectionView()

        collectionView.register(cellClass: TicketsCollectionViewCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.setCollectionViewLayout(
            SectionListFlowLayout(
                itemSizeType: .tickets
            ),
            animated: true
        )
    }

    override func setupNavigationItem() {
        let rightButton = UIBarButtonItem(
            image: #imageLiteral(resourceName: "show-manual"),
            style: .plain,
            target: self,
            action: #selector(manualButtonClicked)
        )
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.rightBarButtonItem?.tintColor = TicketsViewController.manualButtonColor
    }

    @objc
    func manualButtonClicked() {
        presenter?.showManual()
    }

    override func refreshData(_ sender: Any) {
        presenter?.refresh()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        presenter?.selectItem(at: indexPath.row)
    }
}

extension TicketsViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return data.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let item = data[indexPath.row]
        let cell: TicketsCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.update(viewModel: item)
        cell.onShareButtonTouch = { [weak self] in
            self?.presenter?.share(at: indexPath.row)
        }
        cell.onReturnViewTap = { [weak self] in
            self?.presenter?.returnTicket(at: indexPath.row)
        }
        return cell
    }
}

extension TicketsViewController: TicketsViewProtocol {
    func set(state: SectionViewState) {
        self.state = state
    }

    func set(data: [TicketViewModel]) {
        self.data = data
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func share(with text: String) {
        let activityViewController = UIActivityViewController(
            activityItems: [text as String],
            applicationActivities: nil
        )
        ModalRouter(source: self, destination: activityViewController).route()
    }

    func sendEmail(to receiverEmail: String, subject: String, messageBody: String) throws {
        guard let controller = emailController(
            to: receiverEmail,
            subject: subject,
            messageBody: messageBody
        ) else {
            throw EmailCreationError()
        }
        controller.mailComposeDelegate = self
        ModalRouter(source: self, destination: controller).route()
    }
}

extension TicketsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true)
    }
}

