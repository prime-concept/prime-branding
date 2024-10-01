// swiftlint:disable shortening
import AVFoundation
import Foundation
import SnapKit
import UIKit

enum ScanningError: Error {
    case setup
    case processing
}

protocol ScanCameraViewDelegate: class {
    func scanningDidFail(with error: ScanningError)
    func scanningSucceeded(withCode str: String)
    func scanningDidStop()
}

class ScanCameraView: UIView {
    // MARK: - Private propetries
    private var captureSession = AVCaptureSession()
    private var metadataOutput = AVCaptureMetadataOutput()
    private weak var delegate: ScanCameraViewDelegate?

    // MARK: - Public properties
    var isRunning: Bool {
        return captureSession.isRunning
    }

    var isInit = false

    // MARK: - Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        doInitialSetup()
    }

    init(delegate: ScanCameraViewDelegate?) {
        super.init(frame: .zero)
        self.delegate = delegate
        doInitialSetup()
    }

    // MARK: - Life circle
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    override var layer: AVCaptureVideoPreviewLayer {
        // swiftlint:disable force_cast
        return super.layer as! AVCaptureVideoPreviewLayer
        // swiftlint:enable force_cast
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateScanRect()
    }

    // MARK: - Public methods
    func startScanning() {
        captureSession.startRunning()
    }

    func stopScanning() {
        captureSession.stopRunning()
        delegate?.scanningDidStop()
    }

    private func doInitialSetup() {
        clipsToBounds = true
        setupSession()
        addBottomView()
    }

    // MARK: - Private methods
    private func setupSession() {
        guard
            let videoCaptureDevice = AVCaptureDevice.default(for: .video),
            let captureDeviceInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
            captureSession.canAddInput(captureDeviceInput),
            captureSession.canAddOutput(metadataOutput)
        else {
            delegate?.scanningDidFail(with: .setup)
            return
        }

        captureSession.addOutput(metadataOutput)
        captureSession.addInput(captureDeviceInput)

        guard metadataOutput.availableMetadataObjectTypes.contains(.qr) else {
            delegate?.scanningDidFail(with: .setup)
            return
        }

        metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
        metadataOutput.metadataObjectTypes = [.qr]

        self.layer.session = captureSession
        self.layer.videoGravity = .resizeAspectFill
        isInit = true
    }

    private func addBottomView() {
        let overlayView = ScanOverlayView(frame: .zero)
        overlayView.backgroundColor = .clear
        addSubview(overlayView)
        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.setRoundedCorners(radius: 10)
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-15)
            } else {
                make.bottom.equalToSuperview().offset(-15)
            }
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }

        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.font = .boldSystemFont(ofSize: 25)
        titleLabel.text = LS.localize("ScanQrTitle")
        titleLabel.textColor = .black
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(16)
            make.right.equalToSuperview().offset(-16)
            make.left.equalToSuperview().inset(16)
        }

        let subTitleLabel = UILabel()
        subTitleLabel.numberOfLines = 0
        subTitleLabel.text = LS.localize("ScanQrDescription")
        subTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        subTitleLabel.numberOfLines = 0
        subTitleLabel.textColor = .black
        contentView.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-16)
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-15)
        }
    }

    func scanningDidFail(error: ScanningError) {
        delegate?.scanningDidFail(with: error)
    }

    private func updateScanRect() {
        let widthRect = 205 * UIScreen.main.bounds.width / 375
        let scanRect = CGRect(
            x: (frame.width - widthRect) / 2,
            y: (frame.height - widthRect) * 1 / 3,
            width: widthRect,
            height: widthRect
        )
        let rectOfInterest = layer.metadataOutputRectConverted(fromLayerRect: scanRect)
        metadataOutput.rectOfInterest = rectOfInterest
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension ScanCameraView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard
            let metadataObject = metadataObjects.first,
            let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
            let stringValue = readableObject.stringValue
        else {
            delegate?.scanningDidFail(with: .processing)
            return
        }
        stopScanning()
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        delegate?.scanningSucceeded(withCode: stringValue)
    }
}
// swiftlint:enable shortening
