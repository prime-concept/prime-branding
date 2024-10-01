import UIKit

class ScanErrorView: UIView {
    // MARK: - Private properties
    private lazy var permissionsStackView: UIStackView = {
        let view = UIStackView()
        view.spacing = 16

        return view
    }()

    private lazy var imageView = UIImageView()

    private lazy var textLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 16, weight: .semibold)
        view.numberOfLines = 0
        view.textAlignment = .center

        return view
    }()

    private lazy var actionButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = UIColor(hex: 0x272361)
        view.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        view.setTitleColor(.white, for: .normal)
        view.layer.cornerRadius = 22
        view.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        return view
    }()

    var primaryError: ScanViewState.FailType?
    var onScanTap: ((ScanViewState.FailType) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    func setup(with state: ScanViewState) {
        permissionsStackView.safelyRemoveArrangedSubviews()

        func makeButton(text: String, isNormal: Bool) {
            let view = UIButton()
            view.setTitle(text, for: .normal)
            view.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)

            if isNormal {
                view.setImage(UIImage(named: "scan-mark")?.withRenderingMode(.alwaysTemplate), for: .normal)
                view.setTitleColor(UIColor(hex: 0x00A14D), for: .normal)
                view.tintColor = UIColor(hex: 0x00A14D)
            } else {
                view.setImage(UIImage(named: "scan-cancel")?.withRenderingMode(.alwaysTemplate), for: .normal)
                view.setTitleColor(UIColor(hex: 0xBFBFBF), for: .normal)
                view.tintColor = UIColor(hex: 0xBFBFBF)
            }

            view.imageEdgeInsets = UIEdgeInsets(
                top: 0,
                left: -5,
                bottom: 0,
                right: 0
            )

            permissionsStackView.addArrangedSubview(view)
        }

        var isPrimaryStateInit = false
        switch state {
        case let .fail(auth, camera, location):
            if let auth = auth {
                imageView.image = auth.image
                textLabel.text = auth.errorText
                actionButton.setTitle(auth.buttonText, for: .normal)
                isPrimaryStateInit = true
                primaryError = .auth
                makeButton(text: auth.text, isNormal: false)
            } else {
                makeButton(text: ScanViewState.FailType.auth.text, isNormal: true)
            }

            if let camera = camera {
                if !isPrimaryStateInit {
                    imageView.image = camera.image
                    textLabel.text = camera.errorText
                    actionButton.setTitle(camera.buttonText, for: .normal)
                    isPrimaryStateInit = true
                    primaryError = .camera
                }

                makeButton(text: camera.text, isNormal: false)
            } else {
                makeButton(text: ScanViewState.FailType.camera.text, isNormal: true)
            }

            if let location = location {
                if !isPrimaryStateInit {
                    imageView.image = location.image
                    textLabel.text = location.errorText
                    actionButton.setTitle(location.buttonText, for: .normal)
                    isPrimaryStateInit = true
                    primaryError = .location
                }

                makeButton(text: location.text, isNormal: false)
            } else {
                makeButton(text: ScanViewState.FailType.location.text, isNormal: true)
            }
        default:
            break
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("Must Implement")
    }

    private func commonInit() {
        addSubview(permissionsStackView)
        permissionsStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(15)
            } else {
                make.top.equalToSuperview().offset(15)
            }
        }

        let centerStackView = UIStackView(
            arrangedSubviews: [imageView, textLabel]
        )
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(95)
        }

        textLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
        }

        centerStackView.axis = .vertical
        centerStackView.spacing = 5
        centerStackView.alignment = .center
        addSubview(centerStackView)
        centerStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.right.left.equalToSuperview()
        }

        addSubview(actionButton)
        actionButton.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
        actionButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-15)
            } else {
                make.bottom.equalTo(snp.bottom).offset(-15)
            }
        }
    }

    @objc
    private func buttonTap() {
        guard let type = primaryError else {
            return
        }

        onScanTap?(type)
    }
}

