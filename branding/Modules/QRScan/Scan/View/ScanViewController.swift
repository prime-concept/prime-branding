import UIKit

enum ScanViewState {
    enum FailType: String, Error {
        case auth = "Authorization"
        case camera = "Camera"
        case location = "Geolocatiom"

        var text: String {
            switch self {
            case .auth:
                return LS.localize("Authorization")
            case .camera:
                return LS.localize("Camera")
            case .location:
                return LS.localize("Geolocation")
            }
        }

        var errorText: String {
            return LS.localize("Allow\(self.rawValue)PermissionError")
        }

        var buttonText: String {
            return LS.localize("Allow\(self.rawValue)Permission")
        }

        var image: UIImage? {
            switch self {
            case .auth:
                return UIImage(named: "placeholder-auth-error")
            case .camera:
                return UIImage(named: "placeholder-camera-error")
            case .location:
                return UIImage(named: "placeholder-geolocation-error")
            }
        }
    }

    case setup
    case processing(ScanResultsMode)
    case fail(FailType?, FailType?, FailType?)
}

final class ScanViewController: UIViewController {
    // MARK: - Public Properties
    var presenter: ScanPresenterProtocol?
    lazy var errorView: ScanErrorView = {
        let view = ScanErrorView(frame: .zero)

        return view
    }()
    lazy var scanView: ScanCameraView = {
        let view = ScanCameraView(delegate: presenter)

        return view
    }()

    // MARK: - Initialization
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.didAppear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopSessionIfNeeded()
    }

    // MARK: - Private Methods
    private func setupView() {
        view.backgroundColor = .white
    }

    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func showErrorView(state: ScanViewState) {
        stopSessionIfNeeded()
        if scanView.superview != nil {
            scanView.removeFromSuperview()
        }

        guard errorView.superview == nil else {
            errorView.setup(with: state)
            return
        }

        errorView.onScanTap = { [weak self] type in
            guard let self = self else {
                return
            }

            switch type {
            case .auth:
                TabBarRouter(tab: 4).route()
            case .camera, .location:
                self.openSystemSettings()
            }
        }

        view.addSubview(errorView)
        errorView.snp.makeConstraints { make in
            make.top.right.left.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(bottomLayoutGuide.snp.top)
            }
        }
        errorView.setup(with: state)
    }

    private func showScanView() {
        startSessionIfNeeded()
        if errorView.superview != nil {
            errorView.removeFromSuperview()
        }

        guard scanView.superview == nil else {
            return
        }

        view.addSubview(scanView)
        scanView.snp.makeConstraints { make in
            make.top.right.left.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(bottomLayoutGuide.snp.top)
            }
        }
    }

    @objc
    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            assertionFailure("Expected to always work")
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

// MARK: - ScanViewProtocol
extension ScanViewController: ScanViewProtocol {
    func set(state: ScanViewState) {
        let onClose = { }

        switch state {
        case .setup:
            showScanView()
        case .fail:
            showErrorView(state: state)
        case .processing(let mode):
            let assembly = ScanResultsAssembly(mode: mode, onClose: onClose)

            switch mode {
            case .processing:
                let navigation = UINavigationController(rootViewController: assembly.buildModule())
                navigation.navigationBar.applyBrandingStyle()
                let router = ModalRouter(source: self, destination: navigation)
                router.route()
            case .data:
                if let navigation = presentedViewController as? UINavigationController,
                    let current = navigation.topViewController {
                    let router = PushRouter(source: current, destination: assembly.buildModule())
                    router.route()
                }
            }
        }
    }

    func stopSessionIfNeeded() {
        guard scanView.isInit, scanView.isRunning else {
            return
        }

        scanView.stopScanning()
    }

    func startSessionIfNeeded() {
        guard viewIfLoaded?.window != nil else {
            return
        }

        guard scanView.isInit, !scanView.isRunning else {
            return
        }

        scanView.startScanning()
    }
}
