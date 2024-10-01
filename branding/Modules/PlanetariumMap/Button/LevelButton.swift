import UIKit

class LevelButton: UIButton {
    private var isInit: Bool = false

    private var selectedColor: UIColor = ApplicationConfig.Appearance.firstTintColor
    private var deselectedColor: UIColor = .white

    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? selectedColor : deselectedColor
        }
    }

    var title: String? {
        didSet {
            setTitle(title, for: .normal)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !isInit {
            isInit = true

            tintColor = UIColor.clear
            setTitleColor(selectedColor, for: .normal)
            setTitleColor(deselectedColor, for: .selected)

            titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            layer.cornerRadius = 10.0

            dropShadow()
        }
    }

    private func dropShadow() {
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 7.0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
