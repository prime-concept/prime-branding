import UIKit

final class DetailInfoView: UIView, NamedViewProtocol {
    private static let lineSpacing = CGFloat(2)
    private static let numberOfVisibleLines = 5

    @IBOutlet private weak var textLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet private var collapsedHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var bottomTextConstraint: NSLayoutConstraint!

    @IBOutlet weak var sourceNameLabel: UILabel!
    @IBOutlet weak var sourceNameButton: UIButton!

    var onExpand: (() -> Void)?
    var onOpenURL: (() -> Void)?

    var text: String? {
        didSet {
            textLabel.setText(text, lineSpacing: DetailInfoView.lineSpacing)
            updateExpandableLabel()
        }
    }

    var sourceName: String?

    var name: String {
        return "info"
    }

    private var previousTextLabelWidth = CGFloat(0)
    private var isExpandForbidden = false
    private var isExpanded: Bool = false
    private var gradientLayer: CAGradientLayer?
    var isOnlyExpanded = false

    private var numberOfLinesInTextLabel: Int {
        let maxSize = CGSize(
            width: textLabel.frame.size.width,
            height: CGFloat(Float.infinity)
        )
        let charSize = textLabel.font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(
            with: maxSize,
            options: .usesLineFragmentOrigin,
            attributes: [.font: textLabel.font],
            context: nil
        )
        let lines = Int(textSize.height / charSize)

        return lines
    }

    override func awakeFromNib() {
        super.awakeFromNib()

		self.textLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)

        bottomTextConstraint.isActive = false

        sourceNameLabel.text = nil
        sourceNameButton.setTitle(nil, for: .normal)

        [sourceNameLabel, sourceNameButton].forEach { $0?.isHidden = true }

        setupGradient()
    }

    @IBAction func onTap(_ sender: Any) {
        expand()
    }

    @IBAction func openURL(_ sender: UIButton) {
        onOpenURL?()
    }

    func setup(viewModel: DetailInfoViewModel) {
		self.text = viewModel.info
		
		self.descriptionLabel.text = viewModel.description
		self.descriptionLabel.isHidden = (viewModel.description ?? "").isEmpty

        sourceName = viewModel.sourceName
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds

        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            if strongSelf.previousTextLabelWidth != strongSelf.textLabel.bounds.width {
                strongSelf.previousTextLabelWidth = strongSelf.textLabel.bounds.width
                strongSelf.updateExpandableLabel()
            }
        }
    }

    func expand() {
        guard !isExpandForbidden else {
            return
        }

        isExpanded.toggle()
        updateExpandLayout(isExpanded: isExpanded)
    }

    private func updateExpandLayout(isExpanded: Bool) {
        gradientLayer?.isHidden = isExpanded

        if isExpanded {
            collapsedHeightConstraint.isActive = false
            bottomTextConstraint.isActive = true

            if let sourceName = sourceName, !sourceName.isEmpty {
                sourceNameLabel.text = LS.localize("Source") + ": "
                sourceNameButton.setTitle(sourceName, for: .normal)
                [sourceNameLabel, sourceNameButton].forEach { $0?.isHidden = false }
            }
        } else {
            collapsedHeightConstraint.isActive = true
            bottomTextConstraint.isActive = false
            sourceNameLabel.text = nil
            sourceNameButton.setTitle(nil, for: .normal)
            [sourceNameLabel, sourceNameButton].forEach { $0?.isHidden = true }
        }

        onExpand?()
    }

    private func updateExpandableLabel() {
        if !isOnlyExpanded && numberOfLinesInTextLabel > DetailInfoView.numberOfVisibleLines {
            // 15 is top padding for block
            let visibleHeight = 15 +
                textLabel.font.lineHeight * CGFloat(DetailInfoView.numberOfVisibleLines) +
                CGFloat(DetailInfoView.numberOfVisibleLines - 1) * DetailInfoView.lineSpacing
            collapsedHeightConstraint.constant = visibleHeight

            updateExpandLayout(isExpanded: false)
            isExpandForbidden = false
        } else {
            updateExpandLayout(isExpanded: true)
            isExpandForbidden = true
        }
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
}
