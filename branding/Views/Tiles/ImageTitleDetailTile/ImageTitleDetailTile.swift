import Nuke
import UIKit

class ImageTitleDetailTile: UIView {
    // MARK: - Private properties
    private lazy var textLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 16, weight: .semibold)
        view.text = ""
        view.numberOfLines = 0

        return view
    }()

    private lazy var subTitleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 12, weight: .semibold)
        view.text = ""
        view.numberOfLines = 0
        view.textColor = UIColor(white: 0.5, alpha: 1)

        return view
    }()

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()

    // MARK: - Public properties
    var text: String? {
        didSet {
            textLabel.text = text
        }
    }

    var subText: String? {
        didSet {
            subTitleLabel.text = subText
        }
    }

    var imageURL: URL? {
        didSet {
            if let url = imageURL {
                loadImage(from: url)
            }
        }
    }

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeBlockView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeBlockView()
    }

    // MARK: - Private methods
    private func makeBlockView() {
        let contentView = UIView()
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }

        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.equalTo(70)
            make.height.equalTo(70)
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }

        contentView.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(20)
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }

        contentView.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(textLabel.snp.bottom).offset(5)
            make.left.equalTo(imageView.snp.right).offset(20)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    private func loadImage(from url: URL) {
        Nuke.loadImage(
            with: url,
            options: ImageLoadingOptions.cacheOptions,
            into: imageView,
            completion: nil
        )
    }
}
