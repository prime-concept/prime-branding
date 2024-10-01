import UIKit
import SnapKit

final class ListHeaderView: UICollectionReusableView, NibLoadable, ViewReusable {
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var typeLabel: UILabel!
    @IBOutlet private weak var imageCarouselView: ImageCarouselView!
    
    @IBOutlet weak var textHeightConstraint: NSLayoutConstraint!
    private let lineSpacing = CGFloat(2)
    private let numberOfVisibleLines = 3
    private var isExpandForbidden = false
    private var isExpanded: Bool = false
    private var gradientLayer: CAGradientLayer?
    var isOnlyExpanded = false

    private var numberOfLinesInTextLabel: Int {
        let maxSize = CGSize(
            width: infoLabel.frame.size.width,
            height: CGFloat(Float.infinity)
        )
        let charSize = infoLabel.font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(
            with: maxSize,
            options: .usesLineFragmentOrigin,
            attributes: [.font: infoLabel.font],
            context: nil
        )
        let lines = Int(textSize.height / charSize)

        return lines
    }
    
    var onExpand: (() -> Void)?
    
    var text: String? {
        didSet {
            infoLabel.text = text
            self.infoLabel.onTap = {
                self.expand()
            }
        }
    }

    var type: String? {
        didSet {
            guard let type = type else {
                return
            }
            typeLabel.isHidden = type.isEmpty
            typeLabel.text = type
        }
    }
    
    func setup(with header: ListHeaderViewModel) {
        text = header.info
        type = header.title
        imageCarouselView.set(gradientImages: header.images)
        self.updateExpandLayout(isExpanded: false)
    }
    
    func expand() {
        isExpanded.toggle()
        updateExpandLayout(isExpanded: isExpanded)
    }
    
    func getTitleSize() -> CGFloat {
        return self.textHeightConstraint.constant
    }

    private func updateExpandLayout(isExpanded: Bool) {
        gradientLayer?.isHidden = isExpanded

        if isExpanded {
            self.textHeightConstraint.constant = self.heightForView(isExpanded: true)
        } else {
            self.textHeightConstraint.constant = self.heightForView(isExpanded: false)
        }
        onExpand?()
    }
    
    private func setupGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.95).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
        gradientLayer.locations = [0.0, 0.5] as [NSNumber]?
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)

        self.layer.insertSublayer(gradientLayer, at: UInt32.max)
        self.gradientLayer = gradientLayer
    }
    
    private func heightForView(isExpanded: Bool) -> CGFloat {
        let label = UILabel(
            frame: CGRect(
                x: 0,
                y: 0,
                width: self.frame.width - 30,
                height: .greatestFiniteMagnitude
            )
        )
        label.numberOfLines = isExpanded ? 0 : self.numberOfVisibleLines
        label.lineBreakMode = .byWordWrapping
        label.font = self.infoLabel.font
        label.text = self.text ?? ""
        label.sizeToFit()
        return label.frame.height
    }
}
