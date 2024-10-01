import Foundation

protocol ScanViewProtocol: class {
    var presenter: ScanPresenterProtocol? { get set }

    func set(state: ScanViewState)

    func stopSessionIfNeeded()

    func startSessionIfNeeded()
}
