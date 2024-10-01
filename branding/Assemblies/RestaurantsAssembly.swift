import UIKit

class RestaurantsAssembly<APIType: SectionRetrievable>: UIViewControllerAssemblyProtocol where APIType.T == Restaurant {
    var url: String
    var apiSource: APIType
    var prefersLargeTitles: Bool
    var isFavoriteSection: Bool
    var isCollection: Bool

    init(
        url: String,
        apiSource: APIType,
        prefersLargeTitles: Bool = false,
        isFavoriteSection: Bool = false,
        isCollection: Bool = false
    ) {
        self.url = url
        self.apiSource = apiSource
        self.prefersLargeTitles = prefersLargeTitles
        self.isFavoriteSection = isFavoriteSection
        self.isCollection = isCollection
    }

    func buildModule() -> UIViewController {
        let sectionVC = SectionViewController(prefersLargeTitles: prefersLargeTitles)
        sectionVC.presenter = SectionPersistentPresenter<Restaurant, APIType>(
            view: sectionVC,
            favoritesService: FavoritesService(),
            locationService: LocationService(),
            sharingService: SharingService(),
            adService: AdService(),
            sectionApi: apiSource,
            tagsAPI: TagsAPI(),
            areasAPI: AreasAPI(),
            headerAPI: HeaderAPI(),
            appearanceEvent: AnalyticsEvents.Restaurants.opened,
            url: url,
            shouldShowTags: false,
            isFavoriteSection: isFavoriteSection,
            shouldShowEventsFilter: false,
            shouldShowFilters: false,
            shouldShowSearchBar: false,
            isCollection: isCollection
        )
        return sectionVC
    }
}
