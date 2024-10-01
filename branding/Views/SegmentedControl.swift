// swiftlint:disable all
// Original source https://github.com/yemeksepeti/YSSegmentedControl
import UIKit
fileprivate extension CGFloat {
    static let onePixel = 1 / UIScreen.main.scale
}

// MARK: - Appearance

struct SegmentedControlAppearance {
    var backgroundColor: UIColor
    var selectedBackgroundColor: UIColor
    var textColor: UIColor
    var font: UIFont
    var selectedTextColor: UIColor
    var selectedFont: UIFont
    var bottomLineColor: UIColor
    var selectorColor: UIColor
    var bottomLineHeight: CGFloat
    var selectorHeight: CGFloat
}


// MARK: - Control Item

typealias SegmentedControlItemAction = (_ item: SegmentedControlItem) -> Void

class SegmentedControlItem: UIControl {

    // MARK: Properties

    private var willTap: SegmentedControlItemAction?
    private var didTap: SegmentedControlItemAction?
    var label: UILabel!

    // MARK: Init

    init(
        frame: CGRect,
        text: String,
        appearance: SegmentedControlAppearance,
        willTap: SegmentedControlItemAction?,
        didTap: SegmentedControlItemAction?
    ) {
        super.init(frame: frame)

        self.willTap = willTap
        self.didTap = didTap

        addLabel(
            appearance: appearance,
            text: text
        )
    }

    func addLabel(appearance: SegmentedControlAppearance, text: String) {
        label = UILabel(
            frame: CGRect(
                x: 0,
                y: 0,
                width: frame.size.width,
                height: frame.size.height
            )
        )
        label.textColor = appearance.textColor
        label.font = appearance.font
        label.textAlignment = .center
        label.text = text

        addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    // MARK: Events

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        willTap?(self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        didTap?(self)
    }
}


// MARK: - Control

@objc protocol SegmentedControlDelegate {
    @objc
    optional func segmentedControl(
        _ segmentedControl: SegmentedControl,
        willTapItemAtIndex index: Int
    )

    @objc
    optional func segmentedControl(
        _ segmentedControl: SegmentedControl,
        didTapItemAtIndex index: Int
    )
}

typealias SegmentedControlAction = (_ segmentedControl: SegmentedControl, _ index: Int) -> Void

public class SegmentedControl: UICollectionReusableView, ViewReusable {

    // MARK: Properties

    weak var delegate: SegmentedControlDelegate?
    var action: SegmentedControlAction?

    var appearance: SegmentedControlAppearance! {
        didSet {
            self.draw()
        }
    }

    var titles = [String]() {
        didSet {
            self.draw()
        }
    }
    var items = [SegmentedControlItem]()
    var selectorView: UIView!

    // MARK: Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        defaultAppearance()
    }

    init(frame: CGRect, titles: [String], action: SegmentedControlAction? = nil) {
        super.init(frame: frame)
        self.action = action
        self.titles = titles
        defaultAppearance()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        defaultAppearance()
    }

    // MARK: Draw

    private func reset() {
        for sub in subviews {
            let view = sub
            view.removeFromSuperview()
        }
        items = []
    }

    private func draw() {
        guard !titles.isEmpty else {
            return
        }
        reset()
        backgroundColor = appearance.backgroundColor
        var currentX: CGFloat = 0
        for title in titles {
            let width = self.width(for: title)
            let item = SegmentedControlItem(
                frame: CGRect(
                    x: currentX,
                    y: 0,
                    width: width,
                    height: frame.size.height
                ),
                text: title,
                appearance: appearance,
                willTap: { segmentedControlItem in
                    let index = self.items.index(of: segmentedControlItem)!
                    self.delegate?.segmentedControl?(self, willTapItemAtIndex: index)
                },
                didTap: { segmentedControlItem in
                    let index = self.items.index(of: segmentedControlItem)!
                    self.selectedItemIndex = index
                    self.action?(self, index)
                    self.delegate?.segmentedControl?(self, didTapItemAtIndex: index)
                }
            )
            addSubview(item)
            items.append(item)
            currentX += width
        }

        // To draw correct bottom line
        frame.size.width = currentX
        drawBottomLine()
        drawSelector()

        selectedItemIndex = shouldSelectItemIndex ?? 0
    }



    // MARK: Util
    override public func layoutSubviews() {
        super.layoutSubviews()
        frame.size = contentSize
    }

    private func drawBottomLine() {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(
            x: 0,
            y: frame.size.height - appearance.bottomLineHeight,
            width: frame.size.width,
            height: appearance.bottomLineHeight
        )
        bottomLine.backgroundColor = appearance.bottomLineColor.cgColor
        layer.addSublayer(bottomLine)
    }

    private func drawSelector() {
        selectorView = UIView(
            frame: CGRect(
                x: 0,
                y: frame.size.height - appearance.selectorHeight,
                width: width(forIndex: 0),
                height: appearance.selectorHeight
            )
        )
        selectorView.backgroundColor = appearance.selectorColor
        addSubview(selectorView)
    }

    private func defaultAppearance() {
        appearance = SegmentedControlAppearance(
            backgroundColor: .clear,
            selectedBackgroundColor: .clear,
            textColor: .halfBlackColor,
            font: .systemFont(ofSize: 15),
            selectedTextColor: .black,
            selectedFont: .systemFont(ofSize: 15),
            bottomLineColor: .separatorGrayColor,
            selectorColor: .black,
            bottomLineHeight: .onePixel,
            selectorHeight: .onePixel
        )
    }

    // MARK: Util
    func width(for title: String) -> CGFloat {
        return (title as NSString).size(
            withAttributes: [.font: appearance.font]
        ).width + 30
    }

    private func width(forIndex index: Int) -> CGFloat {
        return width(for: titles[index])
    }

    var contentSize: CGSize {
        var totalWidth: CGFloat = 0
        for index in 0..<items.count {
            totalWidth += width(forIndex: index)
        }

        return CGSize(width: totalWidth, height: frame.height)
    }


    // MARK: Select
    var shouldSelectItemIndex: Int?

    var selectedItemIndex: Int = 0 {
        didSet {
            shouldSelectItemIndex = selectedItemIndex
            moveSelectorView(to: selectedItemIndex)
            updateItemsAppearence()
        }
    }

    private func updateItemsAppearence() {
        for item in items {
            if item == items[selectedItemIndex] {
                item.label.textColor = appearance.selectedTextColor
                item.label.font = appearance.selectedFont
                item.backgroundColor = appearance.selectedBackgroundColor
            } else {
                item.label.textColor = appearance.textColor
                item.label.font = appearance.font
                item.backgroundColor = appearance.backgroundColor
            }
        }
    }

    private func moveSelectorView(to index: Int) {
        let targetWidth = width(forIndex: index)
        let targetX = items[items.startIndex..<index].reduce(0) { $0 + $1.frame.width }

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [],
            animations: { [unowned self] in
                self.selectorView.frame.origin.x = targetX
                self.selectorView.frame.size.width = targetWidth
            },
            completion: nil
        )
    }
}
// swiftlint:enable all
