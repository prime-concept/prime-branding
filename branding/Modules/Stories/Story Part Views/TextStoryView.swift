import Foundation
import Nuke
import SnapKit
import UIKit

class TextStoryView: UIView, UIStoryPartViewProtocol {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    var completion: (() -> Void)?
    weak var urlNavigationDelegate: StoryURLNavigationDelegate?

    private var elementsStackView: UIStackView?
    private var imagePath: String = ""
    private var storyPart: TextStoryPart?

    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.isHidden = true
    }

    func setup(storyPart: TextStoryPart, urlNavigationDelegate: StoryURLNavigationDelegate?) {
        self.imagePath = storyPart.imagePath
        self.urlNavigationDelegate = urlNavigationDelegate

        var storyContentViews: [UIView] = []
        if let button = storyPart.button {
            storyContentViews += [buildButtonView(button: button)]
        }
        let stackView = UIStackView(arrangedSubviews: storyContentViews)
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 16
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leadingMargin.trailingMargin.equalTo(self)
            make.bottomMargin.equalTo(self).offset(-12)
        }
        elementsStackView = stackView
        elementsStackView?.isHidden = true

        if let text = storyPart.text {
            let textView = createHeaderTextView(text: text)
            addSubview(textView)
            textView.snp.makeConstraints { make in
                make.left.equalTo(self).offset(20)
                make.right.equalTo(self).offset(-64)
                if #available(iOS 11.0, *) {
                    make.top.equalTo(self.safeAreaLayoutGuide.snp.topMargin).offset(32)
                } else {
                    make.top.equalTo(self).offset(32)
                }
            }
        }

        self.storyPart = storyPart
    }

    private func createHeaderTextView(text textModel: TextStoryPart.Text) -> UILabel {
        let label = UILabel()
        label.text = (textModel.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        label.textColor = textModel.textColor
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 0
        return label
    }

    private func buildButtonView(button buttonModel: TextStoryPart.Button) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.clear
        let storyButton = UIButton(type: .system)
        storyButton.backgroundColor = buttonModel.backgroundColor
        storyButton.setTitleColor(buttonModel.titleColor, for: .normal)
        storyButton.setTitle(buttonModel.title, for: .normal)
        storyButton.layer.cornerRadius = 24
        containerView.addSubview(storyButton)
        storyButton.snp.makeConstraints { make in
            make.bottom.top.equalTo(containerView)
            make.centerX.equalTo(containerView)
            make.width.equalTo(180)
            make.height.equalTo(48)
        }
        storyButton.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        return containerView
    }

    func startLoad() {
        if activityIndicator.isHidden != false {
            activityIndicator.isHidden = false
            elementsStackView?.isHidden = true
            activityIndicator.startAnimating()
        }
        guard let url = URL(string: imagePath) else {
            return
        }

        Nuke.loadImage(with: url, options: .shared, into: imageView) { [weak self] _, _ in
            self?.activityIndicator.stopAnimating()
            self?.activityIndicator.isHidden = true
            self?.elementsStackView?.isHidden = false
            self?.completion?()
        }
    }

    @objc
    func buttonClicked() {
        guard
            let part = storyPart,
            let path = part.button?.urlPath,
            let url = URL(string: path)
            else {
                return
        }
        urlNavigationDelegate?.open(url: url)
    }
}

protocol StoryURLNavigationDelegate: class {
    func open(url: URL)
}

protocol UIStoryPartViewProtocol {
    var completion: (() -> Void)? { get set }
    func startLoad()
}
