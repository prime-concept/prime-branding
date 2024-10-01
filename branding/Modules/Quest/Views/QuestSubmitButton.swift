import UIKit

final class QuestSubmitButton: UIButton {
    private static let defaultBackgroundColor = UIColor(
        red: 0.95,
        green: 0.95,
        blue: 0.95,
        alpha: 1
    )
    private static let enabledBackgroundColor = UIColor(red: 0.84, green: 0.08, blue: 0.25, alpha: 1)
    private static let defaultTextColor = UIColor.black
    private static let enabledTextColor = UIColor.white

    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled
                ? QuestSubmitButton.enabledBackgroundColor
                : QuestSubmitButton.defaultBackgroundColor
            tintColor = isEnabled
                ? QuestSubmitButton.enabledTextColor
                : QuestSubmitButton.defaultTextColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = QuestSubmitButton.defaultBackgroundColor
        tintColor = QuestSubmitButton.defaultTextColor
    }
}
