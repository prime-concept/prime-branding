// swiftlint:disable shortening
import AVFoundation
import Foundation
import PromiseKit

final class ScanPresenter: ScanPresenterProtocol {
    weak var view: ScanViewProtocol?

    private let scanAPI: ScanAPI
    private let authService: LocalAuthService
    private let locationService: LocationServiceProtocol

    init(
        view: ScanViewProtocol,
        scanAPI: ScanAPI,
        authService: LocalAuthService = .shared,
        locationService: LocationService = LocationService()
    ) {
        self.view = view
        self.scanAPI = scanAPI
        self.authService = authService
        self.locationService = locationService

        addObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func didAppear() {
        when(
            resolved: [
                fetchAuthState(),
                fetchCameraState(),
                fetchLocationState()
            ]
        ).done { [weak self] states in
            guard let self = self else {
                return
            }

            let failStates: [ScanViewState.FailType?] = states.map {
                switch $0 {
                case .fulfilled:
                    return nil
                case .rejected(let error):
                    return error as? ScanViewState.FailType
                }
            }

            if failStates.allSatisfy({ $0 == nil }) {
                self.performState(.setup)
            } else {
                let state = ScanViewState.fail(
                    failStates[0],
                    failStates[1],
                    failStates[2]
                )
                self.performState(state)
            }
        }
    }

    private func performState(_ state: ScanViewState) {
        if Thread.isMainThread {
            view?.set(state: state)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.view?.set(state: state)
            }
        }
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appMovedToBackground),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appMovedToForeground),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc
    private func appMovedToBackground() {
        view?.stopSessionIfNeeded()
    }

    @objc
    private func appMovedToForeground() {
        didAppear()
    }

    // MARK: - Permissions
    private func fetchAuthState() -> Promise<ScanViewState> {
        return Promise { [weak self] seal in
            guard let self = self else {
                return
            }

            if self.authService.isAuthorized {
                seal.fulfill(.setup)
            } else {
                seal.reject(ScanViewState.FailType.auth)
            }
        }
    }

    private func fetchCameraState() -> Promise<ScanViewState> {
        let mediaType = AVMediaType.video
        let semaphore = DispatchSemaphore(value: 0)

        return Promise { seal in
            var isAllowed = false
            switch AVCaptureDevice.authorizationStatus(for: mediaType) {
            case .authorized:
                isAllowed = true
            case .restricted, .denied:
                break
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: mediaType) { granted in
                    isAllowed = granted
                    semaphore.signal()
                }
                semaphore.wait()
            }

            if isAllowed {
                return seal.fulfill(.setup)
            } else {
                return seal.reject(ScanViewState.FailType.camera)
            }
        }
    }

    private func fetchLocationState() -> Promise<ScanViewState> {
        return Promise { seal in
            firstly {
                locationService.getLocation()
            }.done { _ in
                seal.fulfill(.setup)
            }.catch { _ in
                seal.reject(ScanViewState.FailType.location)
            }
        }
    }

    private func performRequest(id: String, text: String) {
        firstly {
            locationService.getLocation()
        }.then { coordinate in
            self.scanAPI.processCode(id: id, coordinate: coordinate)
        }.done { [weak self] result in
            AnalyticsEvents.QRScan.scanned(
                text: text,
                count: result.count,
                type: result.type.rawValue,
                message: result.description
            ).send()

            self?.performState(.processing(.data(result)))
        }.cauterize()
    }

    private func showInvalidQRError() {
        let scanResult = ScanResult(
            id: "",
            type: .other,
            title: LS.localize("ScanQrInvalidTitle"),
            description: ""
        )
        view?.set(state: .processing(.data(scanResult)))
    }
}

extension ScanPresenter {
    func scanningDidFail(with error: ScanningError) {}

    func scanningSucceeded(withCode str: String) {
        view?.set(state: .processing(.processing))
        view?.stopSessionIfNeeded()

        var queryStrings = [String: String]()
        if
            let url = URL(string: "https://www.apple.com?\(str)"),
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        {
            let queryItems = components.queryItems ?? []
            for queryItem in queryItems {
                queryStrings[queryItem.name] = queryItem.value
            }
        }

        if let id = queryStrings["id"] {
            performRequest(id: id, text: str)
        } else {
            showInvalidQRError()
        }
    }

    func scanningDidStop() {}
}
// swiftlint:enable shortening
