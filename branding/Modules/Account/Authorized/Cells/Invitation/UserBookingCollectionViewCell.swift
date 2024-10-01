import Foundation
import UIKit
import SnapKit
import Nuke

final class UserBookingCollectionViewCell: UICollectionViewCell, ViewReusable {
    
    lazy var timeLabel: UILabel = {
        var label = UILabel()
        label.textColor = .subtitleGrayColor
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        return label
    }()
    
    lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 3
        return label
    }()
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var gradientView = GradientView { (view: GradientView) in
        view.gradientLayer.colors = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.7).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        ]
        view.gradientLayer.locations = [0, 1]
        view.gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        view.gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        view.gradientLayer.transform = CATransform3DMakeAffineTransform(
            CGAffineTransform(a: 1, b: 0, c: 0, d: 5.74, tx: 0, ty: -2.37)
        )
    }
    
    private lazy var statusView = InvitationStatusView()
    
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
            self.backgroundImageView,
            self.gradientView,
            self.timeLabel,
            self.titleLabel,
            self.statusView
        ].forEach(self.contentView.addSubview)
        self.contentView.setRoundedCorners(radius: 10)
        
        self.timeLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(10)
            make.top.equalToSuperview().inset(120)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.width.equalTo(300)
            make.trailing.equalToSuperview().inset(30)
            make.bottom.equalTo(self.timeLabel.snp.top).offset(-5)
        }
        self.backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.statusView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(10)
        }
        self.contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setup(with viewModel: BookingViewModel) {
        self.titleLabel.text = viewModel.title
        self.timeLabel.text = viewModel.timeSlot
        if let url = URL(string: viewModel.backgroundImage) {
            Nuke.loadImage(with: url, into: self.backgroundImageView)
        }
        self.statusView.setup(with: viewModel.status, isVisited: viewModel.isVisited)
    }
}
