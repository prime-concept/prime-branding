import Foundation
import UIKit

final class StarCollectionViewCell: UICollectionViewCell, ViewReusable {
    
    lazy var starImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "Star")?.withRenderingMode(.alwaysTemplate)
        return view
    }()
    
    private lazy var descriptionLabel: UILabel  = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        label.textColor = .gray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupView()
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.contentView.backgroundColor = .clear
        [
            self.starImage,
            self.descriptionLabel
        ].forEach(self.contentView.addSubview)
        self.starImage.snp.makeConstraints { make in
            make.width.height.equalTo(48)
            make.top.leading.trailing.equalToSuperview()
        }
        self.descriptionLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(self.starImage.snp.bottom).offset(2)
        }
        self.contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setup(with viewModel: StarViewModel) {
        if viewModel.isSelected {
            self.starImage.tintColor = .mfRedColor
        } else {
            self.starImage.tintColor = .tintgray
        }
        self.descriptionLabel.text = LS.localize(viewModel.position.rawValue)
    }
}

struct StarViewModel {
    var position: StarPosition
    var isSelected: Bool
}

enum StarPosition: String {
    case first = "StarPositionFirst"
    case last = "StarPositionLast"
    case average = ""
}
