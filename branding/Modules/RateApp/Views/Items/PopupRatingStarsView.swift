import UIKit

final class PopupRatingStarsView: UIView {
    @IBOutlet var buttonStars: [RatingStarButton]!

    var onStarSelect: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        for button in buttonStars {
            button.addTarget(
                self,
                action: #selector(onButtonTouched(_:)),
                for: .touchUpInside
            )
        }
    }

    @objc
    func onButtonTouched(_ button: UIButton) {
        let tappedIndex = button.tag
        for button in buttonStars.reversed() {
            button.isSelected = button.tag <= tappedIndex
            button.isUserInteractionEnabled = false
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.2,
            execute: { [weak self] in
                self?.onStarSelect?(tappedIndex + 1)
            }
        )
    }

    func setup(with selectedColor: UIColor? = nil, defaultColor: UIColor? = nil) {
        for button in buttonStars {
            button.setup(with: selectedColor, defaultColor: defaultColor)
        }
    }

    func updateValue(value: Int) {
        for button in buttonStars.reversed() {
            button.isSelected = button.tag < value
        }
    }
}
