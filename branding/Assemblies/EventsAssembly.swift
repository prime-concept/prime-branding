import Foundation
import UIKit

class EventsAssembly<APIType: SectionRetrievable>: UIViewControllerAssemblyProtocol where APIType.T == Event {
    var url: String
    var apiSource: APIType
    var prefersLargeTitles: Bool
    var shouldShowTags: Bool
    var shouldClearURL: Bool
    var isFavoriteSection: Bool
    var shouldShowEventsFilter: Bool
    var shouldShowFilters: Bool
    var shouldShowSearchBar: Bool
    var isCollection: Bool
    var tagType: TagType?

    init(
        url: String,
        apiSource: APIType,
        prefersLargeTitles: Bool = false,
        shouldShowTags: Bool = false,
        shouldClearURL: Bool = false,
        isFavoriteSection: Bool = false,
        shouldShowEventsFilter: Bool = false,
        shouldShowFilters: Bool = false,
        shouldShowSearchBar: Bool = false,
        isCollection: Bool = false,
        tagType: TagType? = nil
    ) {
        self.url = url
        self.apiSource = apiSource
        self.prefersLargeTitles = prefersLargeTitles
        self.shouldShowTags = shouldShowTags
        self.shouldClearURL = shouldClearURL
        self.isFavoriteSection = isFavoriteSection
        self.shouldShowEventsFilter = shouldShowEventsFilter
        self.shouldShowFilters = shouldShowFilters
        self.shouldShowSearchBar = shouldShowSearchBar
        self.isCollection = isCollection
        self.tagType = tagType
    }

    func buildModule() -> UIViewController {
        let sectionVC = SectionViewController(prefersLargeTitles: prefersLargeTitles)
        sectionVC.presenter = SectionPersistentPresenter<Event, APIType>(
            view: sectionVC,
            favoritesService: FavoritesService(),
            locationService: LocationService(),
            sharingService: SharingService(),
            adService: AdService(),
            sectionApi: apiSource,
            tagsAPI: TagsAPI(),
            areasAPI: AreasAPI(),
            headerAPI: HeaderAPI(),
            appearanceEvent: AnalyticsEvents.Events.opened,
            url: url,
            shouldShowTags: shouldShowTags,
            shouldClearURL: shouldClearURL,
            isFavoriteSection: isFavoriteSection,
            shouldShowEventsFilter: shouldShowEventsFilter,
            shouldShowFilters: shouldShowFilters,
            shouldShowSearchBar: shouldShowSearchBar,
            isCollection: isCollection,
            tagType: tagType
        )
        return sectionVC
    }
}
