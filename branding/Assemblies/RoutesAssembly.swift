import UIKit

class RoutesAssembly<APIType: SectionRetrievable>: UIViewControllerAssemblyProtocol where APIType.T == Route {
    var url: String
    var apiSource: APIType
    var source: String
    var prefersLargeTitles: Bool
    var isFavoriteSection: Bool

    init(
        url: String,
        apiSource: APIType,
        source: String,
        prefersLargeTitles: Bool = false,
        isFavoriteSection: Bool = false
    ) {
        self.url = url
        self.apiSource = apiSource
        self.source = source
        self.prefersLargeTitles = prefersLargeTitles
        self.isFavoriteSection = isFavoriteSection
    }

    func buildModule() -> UIViewController {
        let sectionVC = SectionViewController(prefersLargeTitles: prefersLargeTitles)
        sectionVC.presenter = SectionPersistentPresenter<Route, APIType>(
            view: sectionVC,
            favoritesService: FavoritesService(),
            locationService: LocationService(),
            sharingService: SharingService(),
            adService: AdService(),
            sectionApi: apiSource,
            tagsAPI: TagsAPI(),
            areasAPI: AreasAPI(),
            headerAPI: HeaderAPI(),
            appearanceEvent: AnalyticsEvents.Routes.opened(url: url, source: source),
            url: url,
            shouldShowTags: false,
            isFavoriteSection: isFavoriteSection,
            shouldShowEventsFilter: false,
            shouldShowFilters: false,
            shouldShowSearchBar: false,
            isCollection: false
        )
        return sectionVC
    }
}
