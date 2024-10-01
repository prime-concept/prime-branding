import UIKit

final class QuestChoiceControl: UIControl {
    private static let defaultBackgroundColor = UIColor(
        red: 0.95,
        green: 0.95,
        blue: 0.95,
        alpha: 1
    )
    private static let selectedBackgroundColor = UIColor(
        red: 0.84,
        green: 0.08,
        blue: 0.25,
        alpha: 1
    )
    private static let defaultTextColor = UIColor.black
    private static let selectedTextColor = UIColor.white

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected
                ? QuestChoiceControl.selectedBackgroundColor
                : QuestChoiceControl.defaultBackgroundColor
            textLabel.textColor = isSelected
                ? QuestChoiceControl.selectedTextColor
                : QuestChoiceControl.defaultTextColor
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: max(50, 16 + textLabel.intrinsicContentSize.height)
        )
    }

    var text: String? {
        didSet {
            textLabel.text = text
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

    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }

    private func commonInit() {
        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.attachEdges(to: self, top: 8, leading: 15, bottom: -8, trailing: -15)

        backgroundColor = QuestChoiceControl.defaultBackgroundColor
        textLabel.textColor = QuestChoiceControl.defaultTextColor

        clipsToBounds = true
        layer.cornerRadius = 8
    }
}
