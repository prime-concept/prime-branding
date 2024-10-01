import UIKit

class RatingStarButton: UIButton {
    private var isInited = false

    private var selectedColor: UIColor = ApplicationConfig.Appearance.firstTintColor
    private var defaultColor = UIColor(red: 0.54, green: 0.54, blue: 0.56, alpha: 1)

    override func layoutSubviews() {
        super.layoutSubviews()

        if !isInited {
            isInited = true
            setTitleColor(.white, for: .normal)
        }

        setImage(UIImage(named: "rating_star")?.withRenderingMode(.alwaysTemplate), for: .normal)

        if state == .normal || state == .highlighted {
            tintColor = defaultColor
        } else if state == .selected {
            self.backgroundColor = .clear
            self.tintColor = selectedColor
        }
    }

    func setup(with selectedColor: UIColor? = nil, defaultColor: UIColor? = nil) {
        if let selectedColor = selectedColor {
            self.selectedColor = selectedColor
        }

        if let defaultColor = defaultColor {
            self.defaultColor = defaultColor
        }
    }
}
