import Foundation

final class FilterHorizontalListFlowLayout: BaseListFlowLayout {
    override var flowInset: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 7.5, bottom: 0.0, right: 7.5)
    }

    override var contentWidth: CGFloat {
        return _contentWidth
    }

    private var _contentWidth = CGFloat(0)

    private var overlapDelta: CGFloat {
        return -10
    }
    private var itemHeight: CGFloat {
        return 55
    }
    private var itemWidthConstant: CGFloat {
        return 90
    }

    var tagData: String?
    var dateData: String?
    var areaData: String?
    let filterTypes: [FilterType] = [.date, .tags, .areas]

    override func prepare() {
        super.prepare()

        guard cache.isEmpty else {
            return
        }

        guard let collectionView = collectionView else {
            return
        }

        var yOffset = flowInset.top
        var xOffset = CGFloat(0)

        for section in 0..<collectionView.numberOfSections {
            xOffset = flowInset.left
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                let indexPath = IndexPath(item: item, section: section)

                let frame = CGRect(
                    x: xOffset,
                    y: yOffset,
                    width: itemWidth(for: indexPath, height: itemHeight),
                    height: itemHeight
                )

                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                cache.append(attributes)

                xOffset += itemWidth(for: indexPath, height: itemHeight) + overlapDelta
            }

            yOffset += itemHeight
            xOffset += flowInset.right - overlapDelta
        }

        yOffset += flowInset.bottom

        contentHeight = max(contentHeight, yOffset)
        _contentWidth = max(_contentWidth, xOffset)
    }

    func itemWidth(for indexPath: IndexPath, height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        var title = filterTypes[indexPath.row].title

        let boundingBox = { (title: String) -> CGRect in
            title.boundingRect(
                with: constraintRect,
                options: .usesLineFragmentOrigin,
                attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .semibold)],
                context: nil
            )
        }

        switch filterTypes[indexPath.row] {
        case .tags:
            guard let tagTitle = tagData else {
                return ceil(boundingBox(title).width) + itemWidthConstant
            }
            title = tagTitle
        case .date:
            guard let dateTitle = dateData else {
                return ceil(boundingBox(title).width) + itemWidthConstant
            }
            title = dateTitle
        case .areas:
            guard let areaTitle = areaData else {
                return ceil(boundingBox(title).width) + itemWidthConstant
            }
            title = areaTitle
        }

        return ceil(boundingBox(title).width) + itemWidthConstant
    }
}

