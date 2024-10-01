// swiftlint:disable weak_delegate
import CoreLocation
import GoogleMaps
import UIKit
import YandexMapsMobile

fileprivate extension UIEdgeInsets {
    static let boundsInsets = UIEdgeInsets(
        top: 70,
        left: 64,
        bottom: 0,
        right: 0
    )
}

protocol MapViewProtocol: class, CustomErrorShowable, ModalRouterSourceProtocol {
    func addMarker(with markerModel: MapMarkerModel)
    func moveCamera(at coordinate: YMKPoint)
    func addClusterPoints(points: [MapMarkerModel])
    func show(banner: MapBannerViewModel, onAddClick: (() -> Void)?, onShareClick: (() -> Void)?)
    func showLocationAccessError()
    func update(categories: [SearchTagViewModel], updatedIndexPaths: [IndexPath])
    func updateFavoriteStatus(slug: String, isFavorite: Bool)
    func setNavigationBarVisibility(isHidden: Bool)
}

// swiftlint:disable force_unwrapping
final class MapViewController: UIViewController {
    var presenter: MapPresenterProtocol?

    @IBOutlet weak var mapView: YMKMapView!
    @IBOutlet weak var locateButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    @IBOutlet weak var locateButtonBottomConstraint: NSLayoutConstraint!

    var bannerView: ActionTileView?
    var bannerViewTapRecognizer: UITapGestureRecognizer?
    private var clusterManager: GMUClusterManager?
    private var lastMarker: YMKPlacemarkMapObject?

    private let tagsDataSource = SearchTagsDataSource()
    private lazy var tagsDelegate = MapSearchTagsDelegate(selectionCompletion: { [weak self] _, indexPath in
            self?.lastMarker = nil
            self?.presenter?.selectedTag(at: indexPath.row)
        }
    )

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .always
        }
        setUpUI()
        setUpCollection()
        self.setUserLocationMarker()
        presenter?.loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear()
        AnalyticsEvents.Map.opened.send()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presenter?.viewDidAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.viewWillDisappear()
    }

    private func setUpCollection() {
        tagsCollectionView.delegate = tagsDelegate
        tagsCollectionView.dataSource = tagsDataSource
        tagsCollectionView.register(cellClass: SearchTagCollectionCell.self)
    }

    // MARK: - Actions
    @objc
    func search() {
        push(module: SearchAssembly().buildModule())
    }

    @objc
    func locate() {
        presenter?.updateLocation()
    }

    @objc
    func bannerViewTap() {
        presenter?.openChosenPlace()
    }

    @objc
    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            assertionFailure("Expected to always work")
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    // MARK: - Helpers

    private func setUpUI() {
        locateButton.addTarget(
            self,
            action: #selector(locate),
            for: .touchUpInside
        )
        locateButton.layer.cornerRadius = CGFloat(8)
        locateButton.layer.borderColor = UIColor.white.cgColor
        locateButton.layer.borderWidth = CGFloat(1)
        locateButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)

        searchButton.addTarget(
            self,
            action: #selector(search),
            for: .touchUpInside
        )
        searchButton.layer.cornerRadius = CGFloat(8)
        searchButton.layer.borderColor = UIColor.white.cgColor
        searchButton.layer.borderWidth = CGFloat(1)
        searchButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
    }

    func addClusterPoints(points: [MapMarkerModel]) {
        mapView.mapWindow.map.mapObjects.clear()
        let collection = mapView.mapWindow.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
        collection.clear()
        collection.addTapListener(with: self)

        points.forEach { markerModel in
            let placemark = collection.addPlacemark(
                with: markerModel.yandexPoint,
                image: markerModel.markerType.image
            )
            placemark.userData = markerModel
        }
        collection.clusterPlacemarks(withClusterRadius: 60, minZoom: 15)
    }

    private func makePlaceView() -> ActionTileView {
        let placeView: ActionTileView = .fromNib()
        placeView.cornerRadius = 10
        view.addSubview(placeView)
        placeView.translatesAutoresizingMaskIntoConstraints = false

        placeView.heightAnchor.constraint(
            equalToConstant: 120
        ).isActive = true

        if #available(iOS 11, *) {
            placeView.topAnchor.constraint(
                equalTo: mapView.bottomAnchor,
                constant: 16
            ).isActive = true
        } else {
            placeView.topAnchor.constraint(
                equalTo: bottomLayoutGuide.topAnchor,
                constant: 16
            ).isActive = true
        }

        placeView.leadingAnchor.constraint(
            equalTo: mapView.leadingAnchor,
            constant: 16
        ).isActive = true

        placeView.trailingAnchor.constraint(
            equalTo: mapView.trailingAnchor,
            constant: -16
        ).isActive = true

        let tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(bannerViewTap)
        )
        placeView.addGestureRecognizer(tapRecognizer)
        bannerViewTapRecognizer = tapRecognizer

        return placeView
    }

    private func updateLocateButtonConstraint() {
        locateButtonBottomConstraint.constant = CGFloat(145)
    }

    private func setUserLocationMarker() {
        mapView.mapWindow.map.isRotateGesturesEnabled = false
        let mapKit = YMKMapKit.sharedInstance()
        let userLocationLayer = mapKit.createUserLocationLayer(with: mapView.mapWindow)
        mapView.mapWindow.map.move(
            with: YMKCameraPosition(
                target: YMKPoint(
                    latitude: 55.75, longitude: 37.61
            ),
            zoom: 14,
            azimuth: 0,
            tilt: 0
            )
        )
        userLocationLayer.setVisibleWithOn(true)
        userLocationLayer.isHeadingEnabled = true
        userLocationLayer.setObjectListenerWith(self)
    }
}

extension MapViewController: MapViewProtocol {
    func showLocationAccessError() {
        let alert = LocationErrorAlert.makeController {
            [weak self] in
            self?.openSystemSettings()
        }

        ModalRouter(source: self, destination: alert).route()
    }

    func addMarker(with markerModel: MapMarkerModel) {
        clusterManager?.add(markerModel)
    }

    func moveCamera(at coordinate: YMKPoint) {
        mapView.mapWindow.map.move(
            with: YMKCameraPosition(target: coordinate, zoom: 15, azimuth: 0, tilt: 0)
        )
    }

    func show(
        banner: MapBannerViewModel,
        onAddClick: (() -> Void)? = nil,
        onShareClick: (() -> Void)? = nil
    ) {
        func animatePlaceViewAppearence() {
            // populate view
            let bannerView = makePlaceView()
            bannerView.title = banner.name
            bannerView.subtitle = banner.address
            bannerView.metro = banner.metro
            bannerView.metroAndDistrictText = banner.metroAndDistrict

            banner.color.flatMap { bannerView.color = $0 }
            banner.imageUrl.flatMap { bannerView.loadImage(from: $0) }

            bannerView.leftTopText = banner.distanceText

            bannerView.onAddClick = onAddClick
            bannerView.onShareClick = onShareClick
            bannerView.isFavoriteButtonHidden = !banner.state.isFavoriteAvailable
            bannerView.isFavoriteButtonSelected = banner.state.isFavorite

            //show view
            let finalTransform = bannerView.transform.translatedBy(
                x: 0,
                y: -(bannerView.frame.height + 16)
            )

            UIView.animate(withDuration: 0.1) {
                bannerView.transform = finalTransform
                self.updateLocateButtonConstraint()
            }

            self.bannerView = bannerView
        }

        //hide previous view
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.bannerView?.layer.opacity = 0
            },
            completion: { [weak self] _ in
                self?.bannerView?.removeFromSuperview()
                animatePlaceViewAppearence()
            }
        )
    }

    func update(categories: [SearchTagViewModel], updatedIndexPaths: [IndexPath]) {
        if tagsDataSource.data.isEmpty {
            tagsDataSource.data = categories
            tagsCollectionView.reloadData()
        } else {
            tagsDataSource.data = categories
            tagsCollectionView.reloadItems(at: updatedIndexPaths)
        }
    }

    func updateFavoriteStatus(slug: String, isFavorite: Bool) {
        guard let view = bannerView else {
            return
        }
        view.isFavoriteButtonSelected = isFavorite
    }

    func setNavigationBarVisibility(isHidden: Bool) {
        navigationController?.setNavigationBarHidden(isHidden, animated: false)
    }
}

// swiftlint:enable weak_delegate

extension MapViewController: YMKUserLocationObjectListener {
    func onObjectAdded(with view: YMKUserLocationView) {
        let pinPlacemark = view.pin.useCompositeIcon()
        pinPlacemark.setIconWithName(
            "pin",
            image: UIImage(named: "pin_self") ?? UIImage(),
            style: YMKIconStyle(
                anchor: CGPoint(x: 0.5, y: 0.5) as NSValue,
                rotationType: YMKRotationType.rotate.rawValue as NSNumber,
                zIndex: 1,
                flat: true,
                visible: true,
                scale: 0.8,
                tappableArea: nil
            )
        )
    }

    func onObjectRemoved(with view: YMKUserLocationView) {}

    func onObjectUpdated(with view: YMKUserLocationView, event: YMKObjectEvent) {}
}

extension MapViewController: YMKClusterListener, YMKClusterTapListener {
    func onClusterAdded(with cluster: YMKCluster) {
        cluster.appearance.setIconWith(clusterImage(cluster.size))
        cluster.addClusterTapListener(with: self)
    }

    func onClusterTap(with cluster: YMKCluster) -> Bool {
        return true
    }

    func clusterImage(_ clusterSize: UInt) -> UIImage {
        guard let image = ClusterIconGenerator().icon(forSize: clusterSize) else {
            return UIImage()
        }
        return image
    }

    func createPoints(markers: [MapMarkerModel]) -> [YMKPoint] {
        var points = [YMKPoint]()
        for marker in markers {
            points.append(YMKPoint(latitude: marker.position.latitude, longitude: marker.position.longitude))
        }
        return points
    }
}

extension MapViewController: YMKMapObjectTapListener {
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let userPoint = mapObject as? YMKPlacemarkMapObject,
              let userData = userPoint.userData as? MapMarkerModel else {
            return true
        }
        if let lastMarker = self.lastMarker, let lastMarkerData = lastMarker.userData as? MapMarkerModel {
            lastMarker.setIconWith(lastMarkerData.markerType.image)
        }
        userPoint.setIconWith(userData.markerType.selectedImage)
        self.lastMarker = userPoint
        presenter?.selected(marker: userData)
        return true
    }
}
