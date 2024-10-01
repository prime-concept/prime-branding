import UIKit

enum AuthItemType: String {
    case vk, fb, apple

    var title: String {
        switch self {
        case .vk:
            return LS.localize("LoginVK")
        case .fb:
            return LS.localize("LoginFB")
        case .apple:
          return ""
        }
    }

    var titleColor: UIColor {
        return .white
    }

    var backgroundColor: UIColor {
        switch self {
        case .vk:
            return UIColor(red: 0.24, green: 0.51, blue: 0.8, alpha: 1)
        case .fb:
            return UIColor(red: 0.26, green: 0.4, blue: 0.7, alpha: 1)
        case .apple:
          return .black
        }
    }

    var image: UIImage? {
        return UIImage(named: "\(self)-auth-icon")
    }

    var shouldShowShadow: Bool {
        switch self {
        case .vk, .fb:
            return true
        case .apple:
            return false
        }
    }
}

final class AuthItemView: UIView {
    private static var cornerRadius = CGFloat(10)
    private static var shadowColor = UIColor.black
    private static var shadowOffset = CGSize(width: 0, height: 2)
    private static var shadowRadius = CGFloat(4.0)
    private static var shadowOpacity = Float(0.2)

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()

    private var control: UIControl?

    private var type: AuthItemType

    init(type: AuthItemType) {
        self.type = type

        super.init(frame: .zero)

        setupSubviews()
        setupAppearance()
    }

    init(control: UIControl, type: AuthItemType) {
        self.control = control
        self.type = type

        super.init(frame: .zero)

        backgroundColor = type.backgroundColor
        layer.cornerRadius = 10
        addSubview(control)
        control.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if type.shouldShowShadow {
            updateShadowPosition()
        }
    }

    private func setupSubviews() {
        addSubview(iconImageView)
        addSubview(titleLabel)

        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }

    private func setupAppearance() {
        iconImageView.image = type.image
        titleLabel.text = type.title
        titleLabel.textColor = type.titleColor
        backgroundColor = type.backgroundColor

        layer.cornerRadius = 10
    }

    private func updateShadowPosition() {
        // We should re-add shadow every time shadowPath changed
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: AuthItemView.cornerRadius
        ).cgPath
        dropShadow()
    }

    private func dropShadow() {
        layer.shadowColor = AuthItemView.shadowColor.cgColor
        layer.shadowOpacity = AuthItemView.shadowOpacity
        layer.shadowOffset = AuthItemView.shadowOffset
        layer.shadowRadius = AuthItemView.shadowRadius
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.masksToBounds = false
    }
}

