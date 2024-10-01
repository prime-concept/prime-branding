import Nuke
import UIKit

final class LoyaltyGoodsListEmptyCollectionViewCell: UICollectionViewCell, ViewReusable {
    private lazy var emptyView: EmptyStateView = .fromNib()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.right.left.bottom.top.equalToSuperview()
        }
    }

    func setup(with viewModel: LoyaltyGoodsListEmptyViewModel) {
        emptyView.textLabel.text = viewModel.text
        if let imageURL = viewModel.imageURL {
            loadImage(url: imageURL)
        }
    }

    private func loadImage(url: URL) {
        let request = ImageRequest(
            url: url,
            targetSize: CGSize(width: 95, height: 95),
            contentMode: .aspectFill
        )

        Nuke.loadImage(
            with: request,
            options: ImageLoadingOptions.cacheOptions,
            into: emptyView.imageView
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
