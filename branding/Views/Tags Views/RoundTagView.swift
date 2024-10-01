import Foundation
import UIKit
import SnapKit
import Nuke
import NukeWebPPlugin


final class RoundTagView: UIView {
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var blurView: BlurView = {
        let view = BlurView()
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        return label
    }()
    
    init() {
        super.init(frame: .zero)

        self.setupView()
        self.setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(text: String) {
        self.countLabel.text = text
        self.countLabel.numberOfLines = 1
        self.countLabel.adjustsFontSizeToFitWidth = true
        self.countLabel.minimumScaleFactor = 0.5
    }
    
    func setup(url: URL) {
        self.addSubview(self.imageView)
        Nuke.loadImage(with: url, into: self.imageView)
    }

    private func setupView() {
        [
            self.blurView,
            self.imageView,
            self.countLabel
        ].forEach(self.addSubview)
        self.setRoundedCorners(radius: 12)
    }
    
    private func setupConstraints() {
        self.blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.countLabel.snp.makeConstraints { make in
            make.height.width.equalTo(24)

        }
        self.imageView.snp.makeConstraints { make in
            make.height.width.equalTo(17)
            make.edges.equalToSuperview().inset(3.5)
        }
    }
}
