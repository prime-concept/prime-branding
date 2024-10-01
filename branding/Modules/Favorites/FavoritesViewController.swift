import UIKit

final class FavoritesViewController: UIViewController {
    enum Segment: Int {
        case events
        case places
        case restaurants
        case routes

        var title: String {
            switch self {
            case .events:
                return LS.localize("Events")
            case .restaurants:
                return LS.localize("Restaurants")
            case .places:
                return LS.localize(ApplicationConfig.StringConstants.placeTitle)
            case .routes:
                return LS.localize("Routes")
            }
        }
    }

    @IBOutlet private weak var segmentedControl: SegmentedControl!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!

    private var currentContentView: UIView?
    private var defaultSection: FavoriteType?

    private lazy var eventsView: UIView = {
        let viewController = EventsAssembly(
            url: "favorites",
            apiSource: EventsFavoritesAPI(),
            isFavoriteSection: true
        ).buildModule()
        addChild(viewController)
        return viewController.view
    }()

    private lazy var placesView: UIView = {
        let viewController = PlacesAssembly(
            url: "favorites",
            apiSource: PlacesFavoritesAPI(),
            isFavoriteSection: true
        ).buildModule()
        addChild(viewController)
        return viewController.view
    }()

    private lazy var restaurantsView: UIView = {
        let viewController = RestaurantsAssembly(
            url: "favorites",
            apiSource: RestaurantsFavoritesAPI(),
            isFavoriteSection: true
        ).buildModule()
        addChild(viewController)
        return viewController.view
    }()

    private lazy var routesView: UIView = {
        let viewController = RoutesAssembly(
            url: "favorites",
            apiSource: RoutesFavoritesAPI(),
            source: "favorites",
            isFavoriteSection: true
        ).buildModule()
        addChild(viewController)
        return viewController.view
    }()

    init(defaultSection: FavoriteType?) {
        self.defaultSection = defaultSection

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationItem()

        guard let nonZeroSection = self.defaultSection else {
            replaceContentView(eventsView)
            return
        }

        switch nonZeroSection {
        case .events:
            replaceContentView(eventsView)
            segmentedControl.selectedItemIndex = Segment.events.rawValue
        case .places:
            replaceContentView(placesView)
            segmentedControl.selectedItemIndex = Segment.places.rawValue
        case .restaurants:
            replaceContentView(restaurantsView)
            segmentedControl.selectedItemIndex = Segment.restaurants.rawValue
        case .routes:
            replaceContentView(routesView)
            segmentedControl.selectedItemIndex = Segment.routes.rawValue
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }

    private func setupNavigationItem() {
        title = LS.localize("Favorites")

        segmentedControl.delegate = self
        segmentedControl.titles = [
            Segment.events.title,
            Segment.places.title
        ]

        if FeatureFlags.shouldUseRestaurants {
            segmentedControl.titles.append(Segment.restaurants.title)
        }

        if FeatureFlags.shouldUseRoutes {
            segmentedControl.titles.append(Segment.routes.title)
        }

        segmentedControl.appearance.backgroundColor = .white
        scrollView.contentSize.width = segmentedControl.contentSize.width
    }
}

extension FavoritesViewController: SegmentedControlDelegate {
    private func replaceContentView(_ view: UIView) {
        currentContentView?.removeFromSuperview()
        containerView.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        view.attachEdges(to: containerView)

        currentContentView = view
    }

    func segmentedControl(_ segmentedControl: SegmentedControl, didTapItemAtIndex index: Int) {
        switch index {
        case Segment.events.rawValue:
            replaceContentView(eventsView)
        case Segment.places.rawValue:
            replaceContentView(placesView)
        case Segment.restaurants.rawValue:
            replaceContentView(restaurantsView)
        case Segment.routes.rawValue:
            replaceContentView(routesView)
        default:
            break
        }
    }
}
