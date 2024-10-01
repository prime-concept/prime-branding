import Foundation

protocol ScanPresenterProtocol: ScanCameraViewDelegate {
    var view: ScanViewProtocol? { get set }

    func didAppear()
}
