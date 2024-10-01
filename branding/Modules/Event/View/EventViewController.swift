import SafariServices
import UIKit

//swiftlint:disable type_body_length
final class EventViewController: DetailViewController {
    var presenter: EventPresenterProtocol?

    private lazy var buyTicketButton: UIButton = {
        let button = BookingButton(type: .system)
        button.type = .ticket
        return button
    }()

    // Bottom panel

    private var bottomPanelTopConstraint: NSLayoutConstraint?
    private lazy var bottomPanelPadView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private lazy var bottomPanel: EventBottomPanelView = {
        let view: EventBottomPanelView = .fromNib()
        let recognizer = UISwipeGestureRecognizer(
            target: self,
            action: #selector(self.hideBottomPanel)
        )
        view.addGestureRecognizer(recognizer)
        recognizer.direction = .down
        return view
    }()

    private lazy var bottomPanelDimView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.backgroundColor = UIColor(
            red: 0.02,
            green: 0.02,
            blue: 0.06,
            alpha: 0.4
        )

        let tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.hideBottomPanel)
        )
        view.addGestureRecognizer(tapRecognizer)
        return view
    }()

    override var bottomButton: UIButton {
        return buyTicketButton
    }

    var currentViewModel: EventViewModel?

    override var rows: [DetailRow] {
        var rows: [DetailRow] = [
            .activeButtonSection,
            .rate,
            .aboutBooking,
        ]

        // Insert tags after location
        if FeatureFlags.shouldShowTags {
            rows.append(.tags)
        }

        rows.append(
            contentsOf: [
                .info,
                .location,
                .youtubeVideos,
                .sections(.place),
                .eventCalendar
            ]
        )

        return rows
    }

    convenience init() {
        self.init(nibName: "DetailViewController", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildViewService.set(rows: rows)
        presenter?.refresh()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsEvents.Event.opened.send()

        presenter?.viewDidAppear()
    }

    override func onBottomButtonClick(_ sender: Any) {
        if let url = bookingURL {
            // TODO: - WKWebView не грузит некоторые ссылки из-за внутреннего бага
            if FeatureFlags.shouldBuyTicketsInWebView {
                let controller = BuyTicketAssembly(url: url, buyTicketDelegate: self).buildModule()
                let router = ModalRouter(source: self, destination: controller)
                router.route()
            } else {
                let safariController = SFSafariViewController(url: url)
                safariController.delegate = self
                present(safariController, animated: true)
            }
            presenter?.buyTicketPresented()
        }
    }

    private func showBottomPanel() {
        bottomPanel.setNeedsLayout()
        bottomPanel.layoutIfNeeded()

        if bottomPanel.superview == nil {
            bottomPanel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bottomPanel)
            let bottomPanelTopConstraint: NSLayoutConstraint = {
                if #available(iOS 11.0, *) {
                    return bottomPanel.topAnchor.constraint(
                        equalTo: view.safeAreaLayoutGuide.bottomAnchor
                    )
                } else {
                    return bottomPanel.topAnchor.constraint(
                        equalTo: view.bottomAnchor
                    )
                }
            }()
            NSLayoutConstraint.activate(
                [
                    bottomPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    bottomPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    bottomPanelTopConstraint
                ]
            )

            self.bottomPanelTopConstraint = bottomPanelTopConstraint

            view.insertSubview(bottomPanelDimView, belowSubview: bottomPanel)
            view.insertSubview(bottomPanelPadView, aboveSubview: bottomPanelDimView)
        }

        bottomPanelDimView.alpha = 0.0
        bottomPanelDimView.frame = view.bounds

        if #available(iOS 11.0, *) {
            bottomPanelPadView.frame = CGRect(
                x: 0,
                y: view.frame.maxY - view.safeAreaInsets.bottom - (bottomPanel.height / 2),
                width: view.frame.width,
                height: view.safeAreaInsets.bottom + (bottomPanel.height / 2)
            )
        }

        bottomPanel.isHidden = false
        bottomPanelDimView.isHidden = false
        bottomPanelPadView.isHidden = false

        view.setNeedsLayout()
        view.layoutIfNeeded()

        bottomPanelTopConstraint?.constant = -bottomPanel.height

        UIView.animate(
            withDuration: 0.25,
            animations: {
                self.view.layoutIfNeeded()
                self.bottomPanelDimView.alpha = 1.0
            },
            completion: { _ in
                self.bottomPanel.layoutIfNeeded()
            }
        )
    }

    @objc
    private func hideBottomPanel() {
        view.setNeedsLayout()
        view.layoutIfNeeded()

        bottomPanelTopConstraint?.constant = 0
        UIView.animate(
            withDuration: 0.25,
            animations: {
                self.view.layoutIfNeeded()
                self.bottomPanelDimView.alpha = 0.0
            },
            completion: { _ in
                self.bottomPanelDimView.isHidden = true
                self.bottomPanelPadView.isHidden = true
                self.bottomPanel.isHidden = true
            }
        )
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func buildView(row: DetailRow, viewModel: EventViewModel) -> UIView? {
        switch row {
        case .tags:
            guard let tagsViewModel = viewModel.tags else {
                return nil
            }
            let typedView = row.buildView(from: tagsViewModel) as? TagsCollectionView
            return typedView
        case .info:
            let typedView = row.buildView(from: viewModel.info) as? DetailInfoView
            if viewModel.shouldExpandDescription {
                typedView?.isOnlyExpanded = true
            }
            typedView?.onExpand = { [weak self] in
                UIView.animate(withDuration: 0.25) {
                    self?.view.layoutIfNeeded()
                    self?.tableView.beginUpdates()
                    self?.tableView.endUpdates()
                }
            }
            typedView?.onOpenURL = { [weak self] in
                self?.presenter?.openInfoLink()
            }
            return typedView
        case .location:
            guard let locationViewModel = viewModel.location else {
                return nil
            }
            let typedView = row.buildView(from: locationViewModel) as? LocationView
            typedView?.onAddress = { [weak self] in
                self?.presenter?.showMap()
            }
            return typedView
        case .activeButtonSection:
            let typedView = row.buildView(
                from: viewModel.buttonSection
            ) as? DetailButtonSectionView
            typedView?.heightAnchor.constraint(equalToConstant: 50).isActive = true
            typedView?.onShare = { [weak self] in
                self?.onShareButtonClick()
            }
            return typedView
        case .eventCalendar:
            guard let calendarViewModel = viewModel.eventCalendar else {
                return nil
            }

            let typedView = row.buildView(
                from: calendarViewModel
            ) as? DetailCalendarView

            typedView?.onEventClick = { [weak self] event in
                if event.isOnlineRegistration {
                    self?.presenter?.openOnlineRegistrationForm(viewModel: event)
                }
            }
            typedView?.onLayoutUpdate = { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.tableView.beginUpdates()
                strongSelf.tableView.endUpdates()

                // workaround for iOS 9 & 10: status bar blinks after update
                if #available(iOS 11, *) { } else {
                    var contentOffset = strongSelf.tableView.contentOffset
                    contentOffset.y += 0.5
                    strongSelf.tableView.setContentOffset(
                        contentOffset,
                        animated: false
                    )
                }
            }
            typedView?.onDateChange = { [weak self] date in
                self?.presenter?.calendarDateChanged(to: date)
            }

            return typedView
        case .sections:
            guard let eventsViewModel = viewModel.places else {
                return nil
            }
            let typedView = row.buildView(
                from: eventsViewModel
            ) as? DetailSectionCollectionView<
                    DetailPlacesCollectionViewCell
            >

            typedView?.set(
                layout: DetailHorizontalListFlowLayout(
                    itemSizeType: .detailPlaces
                )
            )

            typedView?.onLayoutUpdate = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            typedView?.onCellClick = { [weak self] eventViewModel in
                if let position = eventViewModel.position {
                    self?.presenter?.selectPlace(position: position)
                }
            }
            return typedView
        case .rate:
            guard let rateViewModel = viewModel.rate else {
                return nil
            }

            let typedView = row.buildView(from: rateViewModel) as? DetailRateView
            typedView?.updateRating(value: rateViewModel.value)
            typedView?.onRatingSelect = { [weak self] rating in
                self?.presenter?.rateEvent(value: rating)
            }
            return typedView
        case .aboutBooking:
            guard let aboutBookingViewModel = viewModel.aboutBooking else {
                return nil
            }

            let typedView = row.buildView(from: aboutBookingViewModel) as? AboutBookingView

            return typedView
        case .youtubeVideos:
            guard let youtubeVideosViewModel = viewModel.youtubeVideos else {
                return nil
            }

            let typedView = row.buildView(
                from: youtubeVideosViewModel
            ) as? DetailVideosHorizontalListView

            let youtubeController = VideosHorizontalListAssembly(
                delegate: nil, viewModel: youtubeVideosViewModel
            ).buildModule()
            addChild(youtubeController)

            typedView?.setup(with: youtubeController.view)
            return typedView
        default:
            break
        }

        fatalError("Unsupported detail row")
    }

    override func onAddToFavoriteButtonClick() {
        presenter?.addToFavorite()
    }

    override func onShareButtonClick() {
        presenter?.share()
    }

    override func showMap(with coords: CLLocationCoordinate2D, address: String? = nil) {
        super.showMap(with: coords, address: address)
    }
}

extension EventViewController: EventViewProtocol {
    func displayEventAddedInCalendarCompletion() {
        hideBottomPanel()
    }

    func set(viewModel: EventViewModel) {
        updateHeaderViewContent(viewModel: viewModel.header)
        updateBookingButton(url: viewModel.bookingURL)

		tableView.scrollIndicatorInsets.bottom = 0

        buildViewService.update(with: viewModel, for: tableView) { row in
			let view = buildView(row: row, viewModel: viewModel)

			if let view = view, case .eventCalendar = row {
				self.present(calendar: view)
				tableView.scrollIndicatorInsets.bottom = 240
				return NamedViewStub {
					$0.make(.height, .equal, 220)
				}
			}

			return view
        }
    }

	private var curtainMinHeight: CGFloat {
		220 + self.view.safeAreaInsets.bottom
	}

	private func present(calendar: UIView) {
		let container = UIStackView.vertical(
			UIView { view in
				let label = UILabel { (label: UILabel) in
					label.text = "Календарь событий"
					label.textAlignment = .center
					label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
					label.make(.height, .equal, 22)
				}
				view.addSubview(label)
				label.make(.edges, .equalToSuperview, [5, 15, -10, -15])
			},
			calendar
		)
		let curtain = CurtainView(content: container)
		curtain.grabber.backgroundColor = UIColor(hex: 0xBFBFBF)

		let curtainMaxHeight = self.view.bounds.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom
		let curtainMinRatio = self.curtainMinHeight / curtainMaxHeight

		curtain.magneticRatios = [1, curtainMinRatio]

		self.view.addSubview(curtain)
		curtain.make(.edges(except: .top), .equalToSuperview)
		curtain.make(.top, .equal, to: self.view.safeAreaLayoutGuide)

		curtain.curtain.clipsToBounds = true
		curtain.curtain.dropShadow(y: -5, radius: 30, color: .black, opacity: 0.1)
		curtain.curtain.make(.height, .greaterThanOrEqual, curtainMinHeight)

		UIView.performWithoutAnimation {
			curtain.setNeedsLayout()
			curtain.layoutIfNeeded()
			curtain.scrollTo(ratio: curtainMinRatio)
		}

		curtain.alpha = 0
		UIView.animate(withDuration: 0.3) {
			curtain.alpha = 1
		}
	}
}

extension EventViewController: BuyTicketDelegate {
    func buyTicketsControllerDidFinish() {
        self.presenter?.buyTicketDismissed()
    }
}

extension EventViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        self.presenter?.buyTicketDismissed()
    }
}

//swiftlint:enable type_body_length
