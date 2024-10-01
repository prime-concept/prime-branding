import Foundation

protocol PersistentSectionRepresentable {
    static func cache(items: [Self], url: String)
    static func loadCached(url: String) -> [Self]
}

class SectionPersistentPresenter<
    ItemType: PersistentSectionRepresentable,
    APIType: SectionRetrievable
>: SectionPresenter<ItemType, APIType> where APIType.T == ItemType {
    override func cacheItems() {
        ItemType.cache(items: self.items, url: self.url)
    }

    override func loadCached() {
        self.items = ItemType.loadCached(url: self.url)

        if !items.isEmpty {
            view?.set(data: getItemsModels(items: items))
            view?.set(state: .normal)
        }
    }
}
