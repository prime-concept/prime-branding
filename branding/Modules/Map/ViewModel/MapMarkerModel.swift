import Foundation
import Nuke
import YandexMapsMobile

final class MapMarkerModel: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var yandexPoint: YMKPoint
    var markerType: MapMarkerType
    var selected: Bool {
        didSet {
            storedMarker?.selected = selected
        }
    }

    var imagedTag: MarkerImage?
    var storedMarker: MapMarker?

    private var size: CGSize {
        guard let imageTag = imagedTag?.markerImage, !imageTag.isEmpty else {
            return CGSize(width: 24, height: 35)
        }

        return CGSize(width: 48, height: 48)
    }

    init(
        position: CLLocationCoordinate2D,
        markerType: MapMarkerType,
        selected: Bool = false,
        imagedTag: MarkerImage? = nil
    ) {
        self.position = position
        self.markerType = markerType
        self.selected = selected
        self.imagedTag = imagedTag
        self.yandexPoint = YMKPoint(latitude: position.latitude, longitude: position.longitude)
    }

    func imageViewForState(selected: Bool) -> UIImageView {
        let iconImageView = UIImageView(
            frame: CGRect(origin: .zero, size: size)
        )
        let path = selected ? imagedTag?.selectedMarkerImage : imagedTag?.markerImage

        if let url = URL(string: path ?? "") {
            Nuke.loadImage(with: url, into: iconImageView)
        } else {
            iconImageView.image = selected ? markerType.selectedImage : markerType.image
        }

        return iconImageView
    }

    func makeMarker() -> MapMarker {
        if let marker = storedMarker {
            return marker
        }

        let marker = MapMarker(position: position, model: self)
        marker.selected = selected
        storedMarker = marker

        return marker
    }
}
