import Foundation
import UIKit
import SnapKit

final class InvitationStatusView: UIView {
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .heavy)
        label.textColor = .white
        return label
    }()
    
    private lazy var statusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var status: BookingStatus = .active
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.setupSubviews()
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with status: BookingStatus, isVisited: Bool) {
        self.status = status
        if isVisited {
            self.backgroundColor = .halfBlackColor
            self.statusLabel.text = LS.localize("BookingVisited").uppercased()
            self.statusImageView.isHidden = true
        } else {
            self.statusLabel.text = status.localization.uppercased()
            self.statusImageView.isHidden = false
            self.statusImageView.image = status.titleImage
            self.backgroundColor = status.titleBackground
        }
        self.makeConstraints(isImageHidden: isVisited)
    }
    
    func setupSubviews() {
        [
            self.statusLabel,
            self.statusImageView
        ].forEach(self.addSubview)
        self.statusImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 8.5, height: 8.5))
            make.leading.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        self.layer.cornerRadius = 10
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    }

    func makeConstraints(isImageHidden: Bool) {
        self.statusLabel.snp.removeConstraints()
        self.statusLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview().inset(4)
            isImageHidden ? make.leading.equalToSuperview().inset(10) : make.leading.equalTo(self.statusImageView.snp.trailing).offset(4)
        }
    }
}
