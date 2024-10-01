import Foundation
import SnapKit
import UIKit

class YoutubeVideoBlockCollectionViewCell: UICollectionViewCell, ViewReusable {
    func setup(view: UIView) {
        self.contentView.subviews.forEach { $0.removeFromSuperview() }
        self.contentView.addSubview(view)
        self.contentView.backgroundColor = .clear
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
