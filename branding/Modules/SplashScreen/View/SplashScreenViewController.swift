import UIKit

final class SplashScreenViewController: UIViewController {
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "logo")
        return imageView
    }()

    private var onComplete: (([TabBarItem]) -> Void)?

    private var tabBarAPI = TabBarAPI()

    init(onComplete: (([TabBarItem]) -> Void)? = nil) {
        self.onComplete = onComplete
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadTabs()
    }

    private func setupUI() {
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                imageView.heightAnchor.constraint(equalToConstant: 92),
                imageView.widthAnchor.constraint(equalToConstant: 100)
            ]
        )

        view.backgroundColor = .white
    }

    private func loadTabs() {
        tabBarAPI.retrieveTabBar().done { [weak self] items in
            self?.onComplete?(items)
        }.catch { [weak self] _ in
            self?.onComplete?([])
        }
    }
}
