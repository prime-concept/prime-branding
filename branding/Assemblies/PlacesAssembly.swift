import Foundation
import UIKit

class PlacesAssembly<APIType: SectionRetrievable>: UIViewControllerAssemblyProtocol where APIType.T == Place {
    var url: String
    var apiSource: APIType
    var prefersLargeTitles: Bool
    var isFavoriteSection: Bool
    var shouldShowSearchBar: Bool
    var shouldShowTags: Bool
    var isCollection: Bool
    var tagType: TagType?

    init(
        url: String,
        apiSource: APIType,
        prefersLargeTitles: Bool = false,
        isFavoriteSection: Bool = false,
        shouldShowSearchBar: Bool = false,
        shouldShowTags: Bool = false,
        isCollection: Bool = false,
        tagType: TagType? = nil
    ) {
        self.url = url
        self.apiSource = apiSource
        self.prefersLargeTitles = prefersLargeTitles
        self.isFavoriteSection = isFavoriteSection
        self.shouldShowSearchBar = shouldShowSearchBar
        self.shouldShowTags = shouldShowTags
        self.isCollection = isCollection
        self.tagType = tagType
    }

    func buildModule() -> UIViewController {
        let sectionVC = SectionViewController(prefersLargeTitles: prefersLargeTitles)
        sectionVC.presenter = SectionPersistentPresenter<Place, APIType>(
            view: sectionVC,
            favoritesService: FavoritesService(),
            locationService: LocationService(),
            sharingService: SharingService(),
            adService: AdService(),
            sectionApi: apiSource,
            tagsAPI: TagsAPI(),
            areasAPI: AreasAPI(),
            headerAPI: HeaderAPI(),
            appearanceEvent: AnalyticsEvents.Places.opened,
            url: url,
            shouldShowTags: shouldShowTags,
            isFavoriteSection: isFavoriteSection,
            shouldShowEventsFilter: false,
            shouldShowFilters: false,
            shouldShowSearchBar: shouldShowSearchBar,
            isCollection: isCollection,
            tagType: tagType
        )
        return sectionVC
    }
}
