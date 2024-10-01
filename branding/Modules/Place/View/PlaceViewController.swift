import UIKit
import SnapKit

final class PlaceViewController: DetailViewController {
    var presenter: PlacePresenterProtocol?

    override var rows: [DetailRow] {
        return [
            .activeButtonSection,
            .tags,
            .info,
            .tagsRow,
            .schedule,
            .contactInfo,
            .location,
            .restaurants,
            .sections(.event),
            .eventCalendar
        ]
    }

    private weak var eventsView: DetailSectionCollectionView<DetailEventsCollectionViewCell>?

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

        AnalyticsEvents.Place.opened.send()
        presenter?.didAppear()
    }

    override func onAddToFavoriteButtonClick() {
        presenter?.addToFavorite()
    }

    override func onShareButtonClick() {
        presenter?.share()
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func buildView(row: DetailRow, viewModel: PlaceViewModel) -> UIView? {
        switch row {
        case .activeButtonSection:
            let typedView = row.buildView(
                from: viewModel.buttonSection
            ) as? DetailButtonSectionView
            typedView?.heightAnchor.constraint(equalToConstant: 50).isActive = true
            typedView?.onShare = { [weak self] in
                self?.onShareButtonClick()
            }
            return typedView
        case .tags:
            guard let tagsViewModel = viewModel.tags else {
                return nil
            }
            let typedView = row.buildView(from: tagsViewModel) as? DetailTagsView
            return typedView
        case .quests:
            guard let questsViewModel = viewModel.quests else {
                return nil
            }
            let typedView = row.buildView(
                from: questsViewModel
            ) as? DetailQuestsCollectionView

            typedView?.onLayoutUpdate = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            typedView?.onChoseQuest = { questViewModel in
                // pass to presenter
            }
            return typedView
        case .info:
            let typedView = row.buildView(from: viewModel.info) as? DetailInfoView
            typedView?.onExpand = { [weak self] in
                UIView.animate(withDuration: 0.25) {
                    self?.view.layoutIfNeeded()
                    self?.tableView.beginUpdates()
                    self?.tableView.endUpdates()
                }
            }
            return typedView
        case .schedule:
            guard let scheduleViewModel = viewModel.schedule else {
                return nil
            }

            let typedView = row.buildView(from: scheduleViewModel) as? DetailPlaceScheduleView
            typedView?.onLayoutUpdate = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            return typedView
        case .contactInfo:
            guard let contactInfoViewModel = viewModel.contactInfo else {
                return nil
            }

            let typedView = row.buildView(from: contactInfoViewModel) as? DetailContactInfoView
            typedView?.onPhoneTap = { [weak self] in
                self?.presenter?.makePhoneCall()
            }
            typedView?.onWebSiteTap = { [weak self] in
                self?.presenter?.openWebSite()
            }
            typedView?.onLayoutUpdate = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            return typedView
        case .location:
            guard let locationViewModel = viewModel.location else {
                return nil
            }

            let typedView = row.buildView(from: locationViewModel) as? LocationView
            typedView?.onTaxi = { [weak self] in
                self?.presenter?.getTaxi()
            }
            typedView?.onAddress = { [weak self] in
                self?.presenter?.showMap()
            }
            return typedView
        case .tagsRow:
            guard let tagsViewModel = viewModel.tagsRow else {
                return nil
            }
            let typedView = row.buildView(from: tagsViewModel) as? TagsCollectionView
            typedView?.onLayoutUpdate = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            return typedView
        case .restaurants:
            guard let restaurantsViewModel = viewModel.restaurants else {
                return nil
            }
            let typedView = row.buildView(
                from: restaurantsViewModel
            ) as? DetailRestaurantsCollectionView

            typedView?.onLayoutUpdate = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            typedView?.onCellClick = { [weak self] restaurantViewModel in
                if let position = restaurantViewModel.position {
                    self?.presenter?.selectRestaurant(position: position)
                }
            }
            return typedView
        case .eventCalendar:
            guard let models = viewModel.eventCalendar else {
                return nil
            }
            let calendarViewModel = DetailDateListsViewModel(dateLists: models)

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
            return typedView
        case .sections:
            guard let eventsViewModel = viewModel.events else {
                return nil
            }
            if let view = eventsView {
                view.setup(viewModel: eventsViewModel)
                return view
            }

            let typedView = row.buildView(
                from: eventsViewModel
            ) as? DetailSectionCollectionView<
                DetailEventsCollectionViewCell
            >

            typedView?.set(
                layout: SectionListFlowLayout(
                    itemSizeType: .smallSection
                )
            )

            typedView?.onLayoutUpdate = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            typedView?.onCellClick = { [weak self] eventViewModel in
                if let position = eventViewModel.position {
                    self?.presenter?.selectEvent(position: position)
                }
            }
            typedView?.onCellAddButtonTap = { [weak self] eventViewModel in
                if let position = eventViewModel.position {
                    self?.presenter?.addEventToFavorite(position: position)
                }
            }
            typedView?.onCellShareButtonTap = { [weak self] eventViewModel in
                if let position = eventViewModel.position {
                    self?.presenter?.shareEvent(position: position)
                }
            }

            eventsView = typedView
            return typedView
        default:
            fatalError("Unsupported detail row")
        }
    }

    override func onBottomButtonClick(_ sender: Any) {
        self.presenter?.onlineRegistration()
    }
}

extension PlaceViewController: PlaceViewProtocol {
    func open(_ url: URL) {
        UIApplication.shared.open(url)
    }

    func expandDescription() {
//        detailExpandBlock?()
    }

    func makePhoneCall(to phoneNumber: String) {
        let phoneUrl = "tel://\(phoneNumber))"
        guard let url = URL(string: phoneUrl) else {
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func set(viewModel: PlaceViewModel) {
        updateHeaderViewContent(viewModel: viewModel.header)
        buildViewService.update(with: viewModel, for: tableView) { row in
            let view = buildView(row: row, viewModel: viewModel)

            if let view = view, case .eventCalendar = row {
                self.present(calendar: view)
                tableView.scrollIndicatorInsets.bottom = 200
                return NamedViewStub {
                    $0.make(.height, .equal, 220)
                }
            }

            return view
        }

        self.bottomButton?.isHidden = !viewModel.isOnlineRegistrationAvailable
    }
    
    private var curtainMinHeight: CGFloat {
        60 + self.view.safeAreaInsets.bottom
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
