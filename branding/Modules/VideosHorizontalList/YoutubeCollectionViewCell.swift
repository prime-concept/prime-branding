import UIKit

final class YoutubeCollectionViewCell: UICollectionViewCell, ViewReusable {
    override func prepareForReuse() {
        super.prepareForReuse()
        self.contentView.subviews.forEach { $0.removeFromSuperview() }
    }

    func setup(module: UIViewController) {
        guard let view = module.view else {
            return
        }
        self.contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(-7.5)
            make.trailing.equalToSuperview().offset(7.5)
        }
    }
}
