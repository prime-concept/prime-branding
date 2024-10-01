import UIKit

protocol PlanetariumMapViewProtocol: class, ModalRouterSourceProtocol {
    func show(banner: MapBannerViewModel, onAddClick: (() -> Void)?, onShareClick: (() -> Void)?)
    func updateFavoriteStatus(id: String, isFavorite: Bool)
}

final class PlanetariumMapViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet var buttonList: [LevelButton]!

    var presenter: PlanetariumMapPresenterProtocol?

    var bannerView: ActionTileView?
    var bannerViewTapRecognizer: UITapGestureRecognizer?

    private var originalImageSize: CGSize {
        return imageView.image?.size ?? .zero
    }

    private var actualImageHeight: CGFloat {
        return imageView.bounds.width * originalImageSize.height / originalImageSize.width
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupButtons()
        setupScrollView()
        setupImageView()

        labelTitle.text = "Уровень"

        presenter?.loadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presenter?.didAppear()
    }

    private func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true

        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(onScrollTouch(_:))
        )
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }

    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
    }

    @objc
    private func onScrollTouch(_ gestureRecognizer: UITapGestureRecognizer) {
        let tappedPoint: CGPoint = gestureRecognizer.location(in: imageView)
        let imageTappedPoint = CGPoint(
            x: tappedPoint.x,
            y: tappedPoint.y - (imageView.bounds.height - actualImageHeight) / 2
        )

        let levelHalls = presenter?.planetariumHalls().compactMap {
            PlanetariumHall(
                id: $0.id,
                selectedImage: $0.selectedImage,
                rectangles: $0.rectangles.map {
                    CGRect(
                        x: $0.origin.x * imageView.bounds.width / originalImageSize.width,
                        y: $0.origin.y * actualImageHeight / originalImageSize.height,
                        width: $0.width * imageView.bounds.width / originalImageSize.width,
                        height: $0.height * actualImageHeight / originalImageSize.height
                    )
                }
            )
        }

        let levelHall = levelHalls?.first {
            !$0.rectangles.filter {
                $0.contains(imageTappedPoint)
            }.isEmpty
        }

        if let selectedHall = levelHall {
            presenter?.selected(hall: selectedHall)
            imageView.image = selectedHall.selectedImage
        }
    }

    private func setupButtons() {
        for index in 0...(buttonList.count - 1) {
            buttonList[index].tag = index
            buttonList[index].title = "\(index)"
        }
        buttonList.first?.isSelected = true
        imageView.image = image(for: Level.zero.rawValue)
    }

    @IBAction func onButtonClick(_ button: UIButton) {
        if button.isSelected {
            return
        }

        presenter?.change(to: button.tag)

        button.isSelected = true
        for but in buttonList where but != button {
            but.isSelected = false
        }

        imageView.image = image(for: button.tag)

        scrollView.zoomScale = 1

        bannerView?.removeFromSuperview()
        presenter?.deselect()
    }

    private func image(for level: Int) -> UIImage? {
        guard let level = Level(rawValue: level) else {
            return nil
        }

        return level.image
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
                equalTo: scrollView.bottomAnchor,
                constant: 16
            ).isActive = true
        } else {
            placeView.topAnchor.constraint(
                equalTo: bottomLayoutGuide.topAnchor,
                constant: 16
            ).isActive = true
        }

        placeView.leadingAnchor.constraint(
            equalTo: view.leadingAnchor,
            constant: 16
        ).isActive = true

        placeView.trailingAnchor.constraint(
            equalTo: view.trailingAnchor,
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

    @objc
    func bannerViewTap() {
        presenter?.openChosenPlace()
    }
}

extension PlanetariumMapViewController: PlanetariumMapViewProtocol {
    func show(
        banner: MapBannerViewModel,
        onAddClick: (() -> Void)?,
        onShareClick: (() -> Void)?
    ) {
        func animatePlaceViewAppearence() {
            // populate view
            let bannerView = makePlaceView()
            bannerView.title = banner.name
            bannerView.subtitle = banner.address

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

    func updateFavoriteStatus(id: String, isFavorite: Bool) {
        guard let view = bannerView else {
            return
        }
        view.isFavoriteButtonSelected = isFavorite
    }
}

extension PlanetariumMapViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
