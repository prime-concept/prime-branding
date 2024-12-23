import UIKit

enum ItemSizeType {
    case detailPlaces
    case detailRestaurants
    case detailQuests
    case bigSection
    case smallSection
    case tickets
    case quests
    case videos

    var itemHeight: CGFloat {
        switch self {
        case .detailPlaces:
            return 120
        case .detailRestaurants:
            return 145
        case .detailQuests:
            return 130
        case .bigSection:
            return 230
        case .smallSection:
            return 120
        case .tickets:
            return 144
        case .quests:
            return 150
        case .videos:
            return 318
        }
    }

    var itemWidth: CGFloat {
        switch self {
        case .detailPlaces:
            return 293
        case .detailRestaurants:
            return 145
        case .detailQuests:
            return 275
        default:
            return 0
        }
    }

    var overlapDelta: CGFloat {
        switch self {
        case .detailPlaces:
            return 5
        case .detailRestaurants:
            return -10
        default:
            return 0
        }
    }
}

class BaseListFlowLayout: UICollectionViewFlowLayout {
    private var height: CGFloat
    private var halfHeight: CGFloat {
        return height / 2
    }

    private var itemHeightForSection: [Int: CGFloat] = [:]

    // We can't use collectionView.contentInset
    // cause we using refresh control with custom background
    var flowInset: UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 7.5, bottom: 0, right: 7.5)
    }

    private var previousSize: CGSize?
    var cache = [UICollectionViewLayoutAttributes]()

    var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = flowInset.left + flowInset.right
        return collectionView.bounds.width - insets
    }

    var contentHeight = CGFloat(0)

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    var shouldInvalidateAttributesCache: Bool {
        previousSize = collectionView?.bounds.size
        return true
//        if previousSize != collectionView?.bounds.size {
//            previousSize = collectionView?.bounds.size
//            return true
//        }
//        return false
    }

    required init(itemSizeType: ItemSizeType) {
        self.height = itemSizeType.itemHeight
        super.init()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(isHalfHeight: Bool, forSection section: Int) {
        itemHeightForSection[section] = isHalfHeight ? halfHeight : height
    }

    func setVideoBlockHeight(forSection section: Int) {
        itemHeightForSection[section] = ItemSizeType.videos.itemHeight
    }

    /// One tile height: 120 (item height in layout) + 15 (shadow paddings)
    func itemHeight(forSection section: Int) -> CGFloat {
        return (itemHeightForSection[section] ?? height) + 15
    }

    override func prepare() {
        super.prepare()

        if shouldInvalidateAttributesCache {
            cache.removeAll(keepingCapacity: true)
        }
    }

    // swiftlint:disable:next discouraged_optional_collection
    override func layoutAttributesForElements(
        in rect: CGRect
    ) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()

        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
}
