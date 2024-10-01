import Foundation
import GoogleMaps

/// Adapter class for `GMSMarker`
class MapMarker: GMSMarker, GMUClusterItem {
    weak var model: MapMarkerModel?

    init(
        position: CLLocationCoordinate2D,
        model: MapMarkerModel
    ) {
        super.init()
        self.position = position
        self.model = model

        updateImage()
    }

    var selected: Bool = false {
        didSet {
            updateImage()
        }
    }

    func removeFromMap() {
        map = nil
    }

    private func updateImage() {
        if let model = model {
            if model.imagedTag == nil {
                iconView = model.markerType.imageViewForState(selected: selected)
            } else {
                iconView = model.imageViewForState(selected: selected)
            }
        }
    }
}
