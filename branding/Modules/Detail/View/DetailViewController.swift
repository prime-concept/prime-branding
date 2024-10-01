import CoreLocation.CLLocation
import GoogleMaps
import UIKit

class DetailViewController: UIViewController, SFViewControllerPresentable {
    @IBOutlet weak var tableView: DetailTableView!

    // swiftlint:disable implicitly_unwrapped_optional
    private var headerHeightConstraint: NSLayoutConstraint!
    private var headerTopConstraint: NSLayoutConstraint!
    // swiftlint:enable implicitly_unwrapped_optional

    private var draggingStartOffset: CGFloat = 0
    private var isDragging = false
    var buildViewService = DetailBuildViewService()

    var headerView: DetailHeaderView?
    var currentMapView: YandexMapViewProtocol?

    var bottomInset: CGFloat {
        return 0
    }

    var bottomButton: UIButton? {
        return nil
    }

    var rows: [DetailRow] {
        return []
    }

    var bookingURL: URL? {
        didSet {
            bottomButton?.isHidden = bookingURL == nil
        }
    }

    private var shouldUseLightStatusBar: Bool = true

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return shouldUseLightStatusBar ? .lightContent : .default
    }

    var headerHeight: CGFloat {
        if statusBarHeight > 20 {
            // Large status bar (e. g. iPhone X)
            return CGFloat(250 + statusBarHeight)
        } else {
            return CGFloat(250)
        }
    }

    var statusBarHeight: CGFloat {
        return min(
            UIApplication.shared.statusBarFrame.height,
            UIApplication.shared.statusBarFrame.width
        )
    }

    var rowViews: [NamedViewProtocol] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupConstraints()

        setupTableView()
        setupHeaderView()
        setupSubviews()
        updateTableInset(isFirstUpdate: true)
        setupBottomButton()
    }

    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async { [weak self] in
            self?.updateTableInset()
        }
    }

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		self.adjustDetailTableViewToPreventOverlap()
	}

	private func adjustDetailTableViewToPreventOverlap() {
		guard let button = self.bottomButton, !button.isHidden else {
			self.tableView.contentInset.bottom = 20
			return
		}

		let intersectionHeight = self.tableView.frame.intersection(button.frame).height
		if (intersectionHeight <= 0) {
			self.tableView.contentInset.bottom = 20
			return
		}

		self.tableView.contentInset.bottom = intersectionHeight + 20
	}

    func updateHeaderViewContent(
        viewModel: DetailHeaderViewModel
    ) {
        headerView?.set(viewModel: viewModel)
        headerView?.onAdd = { [weak self] in
            self?.onAddToFavoriteButtonClick()
        }
        headerView?.onPanorama = { [weak self] in
            self?.onPanoramaButtonClick()
        }
    }

    func updateBookingButton(url: URL?) {
        bookingURL = url
    }

	private func placeCloseButton() {
		let closeButton = UIButton()
		closeButton.setImage(UIImage(named: "cross")?.withRenderingMode(.alwaysTemplate), for: .normal)
		closeButton.tintColor = .white
		closeButton.addTarget(
			self,
			action: #selector(closeButtonPressed),
			for: .touchUpInside
		)
		closeButton.snp.makeConstraints { make in
			make.size.equalTo(CGSize(width: 32, height: 32))
		}
		closeButton.backgroundColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.25)
		closeButton.layer.masksToBounds = true
		closeButton.layer.cornerRadius = 16

		closeButton.imageView?.make(.size, .equal, [10, 10], priorities: [UILayoutPriority.defaultHigh])
		closeButton.imageView?.make(.center, .equalToSuperview, priorities: [UILayoutPriority.defaultHigh])

		let container = BlurringContainer(with: closeButton)
		container.alignCornerRadiiToContent()

		self.view.addSubview(container)
		container.snp.makeConstraints { make in
			make.top.equalTo(self.view.safeAreaLayoutGuide).inset(6)
			make.trailing.equalTo(self.view.safeAreaLayoutGuide).inset(15)
		}
	}

    private func updateTableInset(isFirstUpdate: Bool = false) {
        let topInset = headerHeight - statusBarHeight
        // Workaround: bounds don't change after contentInset changed
        let delta = topInset - tableView.contentInset.top

        // After first update insets changed but we shouldn't update offset
        if !isFirstUpdate {
            var offset = tableView.contentOffset
            offset.y -= delta
            tableView.contentOffset = offset
        }
        tableView.contentInset.top = topInset
        tableView.contentInset.bottom = bottomInset
    }

    private func setupHeaderView() {
        let headerView: DetailHeaderView = .fromNib()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(headerView, belowSubview: tableView)
        headerView.onClose = { [weak self] in
            self?.dismiss()
        }
        headerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        headerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        headerHeightConstraint = headerView.heightAnchor.constraint(
            equalToConstant: headerHeight
        )
        headerHeightConstraint.isActive = true
        headerTopConstraint = headerView.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor)
        headerTopConstraint.isActive = true
        self.headerView = headerView
        self.tableView.headerView = headerView
    }

    private func setupSubviews() {
		self.placeCloseButton()
    }

    private func setupTableView() {
        tableView.estimatedRowHeight = 500
        tableView.rowHeight = UITableView.automaticDimension

        tableView.delegate = self
        tableView.dataSource = self
    }

    private func setupBottomButton() {
        guard let bottomButton = self.bottomButton else {
            return
        }

        view.addSubview(bottomButton)
        bottomButton.translatesAutoresizingMaskIntoConstraints = false
        bottomButton.isHidden = true

        if #available(iOS 11.0, *) {
            bottomButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -15
            ).isActive = true
        } else {
            bottomButton.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -15
            ).isActive = true
        }
        bottomButton.centerXAnchor.constraint(
            equalTo: view.centerXAnchor
        ).isActive = true
        bottomButton.heightAnchor.constraint(
            equalToConstant: 44
        ).isActive = true

        bottomButton.addTarget(
            self,
            action: #selector(onBottomButtonClick),
            for: .touchUpInside
        )
    }

    func dismiss() {
        dismiss(animated: true)
    }

    private func setupConstraints() {
        var topAnchor: NSLayoutYAxisAnchor

        if #available(iOS 11, *) {
            topAnchor = view.safeAreaLayoutGuide.topAnchor
        } else {
            topAnchor = self.topLayoutGuide.bottomAnchor
        }

        tableView.topAnchor.constraint(
            equalTo: topAnchor,
            constant: 0
        ).isActive = true
    }

    @objc func closeButtonPressed() {
        dismiss()
    }

    @objc
    func onBottomButtonClick(_ sender: Any) {
        if let url = bookingURL {
            let controller = BuyTicketAssembly(url: url, buyTicketDelegate: nil).buildModule()
            let router = DeckRouter(source: self, destination: controller)
            router.route()
        }
    }

    func showMap(with coords: CLLocationCoordinate2D, address: String? = nil) {
        let baseUrl = "yandexmaps://maps.yandex.ru/"
        let latitude = coords.latitude
        let longitude = coords.longitude
        let zoom = 12
        let url = URL(string: "\(baseUrl)?pt=\(longitude),\(latitude)&z=\(zoom)")
        
        guard let urlSchema = URL(string: "yandexmaps://"),
              let configuredURL = url else {
            return
        }
        if UIApplication.shared.canOpenURL(urlSchema) {
            UIApplication.shared.open(configuredURL)
        } else {
            if let webUrl = URL(string: "https://itunes.apple.com/ru/app/yandex.maps/id313877526?mt=8") {
                UIApplication.shared.open(webUrl)
            }
        }
    }

    func showMap(with address: String) {
    }

    func onShareButtonClick() {
        preconditionFailure("Method should be overriden in concrete implementation")
    }

    func onAddToFavoriteButtonClick() {
        preconditionFailure("Method should be overriden in concrete implementation")
    }

    func onPanoramaButtonClick() {
        preconditionFailure("Method should be overriden in concrete implementation")
    }

    func dismissModalStack() {
        var controller = self.presentingViewController
        while controller != nil {
            guard let viewController = controller?.presentingViewController else { break }

            controller = viewController
        }

        controller?.dismiss(animated: true)
    }
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buildViewService.rowViews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        guard let view = buildViewService.rowViews[indexPath.row] as? UIView else {
            return cell
        }
        view.removeFromSuperview()

        view.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(view)
        view.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true

        cell.contentView.clipsToBounds = false
        cell.clipsToBounds = false
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear

        return cell
    }
}

extension DetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let heightOffset = min(statusBarHeight, scrollView.contentOffset.y)

        if heightOffset > statusBarHeight / 2 {
            shouldUseLightStatusBar = false
            self.setNeedsStatusBarAppearanceUpdate()
        } else {
            shouldUseLightStatusBar = true
            self.setNeedsStatusBarAppearanceUpdate()
        }

        let boundaryOffset = headerHeight - statusBarHeight
        let isDraggedDown = heightOffset < -boundaryOffset
        if isDraggedDown {
            headerTopConstraint.constant = 0
            headerHeightConstraint.constant = -heightOffset + statusBarHeight
//            closeButton.alpha = 0.0
        } else {
            headerTopConstraint.constant = -(boundaryOffset + heightOffset)
            headerHeightConstraint.constant = headerHeight

            let closeButtonAlpha = min(1.0, max(0, -heightOffset / statusBarHeight))
//            closeButton.alpha = 1.0 - closeButtonAlpha
        }

        let yOffset = scrollView.contentOffset.y
        if isDragging && yOffset + headerHeight < 0 {
            let offsetDiff = abs(draggingStartOffset - yOffset)
            let percent = offsetDiff / view.frame.height
            let dismissThreshold: CGFloat = 0.08
            if percent > dismissThreshold {
                dismiss(animated: true, completion: nil)
            }
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        draggingStartOffset = scrollView.contentOffset.y
        isDragging = true
    }

    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        isDragging = false
    }
}
