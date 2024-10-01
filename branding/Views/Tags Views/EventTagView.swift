import Foundation
import UIKit
import SnapKit
import Nuke

final class EventTagView: UIView {
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = .white
        view.backgroundColor = .mfBlueColor
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = ApplicationConfig.Appearance.firstTintColor
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        self.setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.addSubview(title)
        self.backgroundColor = .tagsBackgroundColor
        self.setRoundedCorners(radius: 12)
        self.imageView.setRoundedCorners(radius: 10)
    }
    
    private func setupConstraints(isImageVisible: Bool) {
        if isImageVisible {
            self.addSubview(imageView)
            self.imageView.snp.makeConstraints { make in
                make.leading.top.bottom.equalToSuperview().inset(2)
                make.width.height.equalTo(20)
            }
        }
        self.title.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(3.5)
            make.trailing.equalToSuperview().inset(10)
            isImageVisible ? (make.leading.equalTo(self.imageView.snp.trailing).offset(5)) : (make.leading.equalToSuperview().inset(10))
        }
    }
    
    func setup(with viewModel: DetailTagTitleViewModel) {
        self.title.text = viewModel.title
        if let imageUrl = URL(string: viewModel.tagImageUrl) {
            Nuke.loadImage(with: imageUrl, into: self.imageView)
            self.setupConstraints(isImageVisible: true)
        } else {
            self.setupConstraints(isImageVisible: false)
        }
    }
}
