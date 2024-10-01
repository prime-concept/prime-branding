import Foundation

struct ListHeaderViewModel {
    var info: String?
    var title: String
    var images: [DetailGradientImage] = []

    init(listHeader: ListHeader) {
        info = listHeader.description
        title = listHeader.title
        images = listHeader.images.compactMap { DetailGradientImage(gradientImage: $0) }
    }
}
