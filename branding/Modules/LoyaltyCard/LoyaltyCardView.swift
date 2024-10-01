import Foundation
import UIKit
import SnapKit

fileprivate extension UIColor {
    static let customRedColor = UIColor(red: 0.84, green: 0.08, blue: 0.25, alpha: 1.0)
}

final class LoyaltyCardView: UIView, LoyaltyViewProtocol {
    private lazy var balanceCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        label.text = "0"
        return label
    }()
    
    private lazy var barCodeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var patternImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "card_background")
        return imageView
    }()
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "logo_loyalty")
        return imageView
    }()
    private lazy var logoBalanceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "loyalty_balance_icon")
        return imageView
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.setup(with: nil)
        self.addSubviews()
        self.makeConstraints()
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var card: String? {
        didSet {
            guard let barcodeSource = card else {
                return
            }
            guard let image = generateBarCode(from: barcodeSource) else {
                return
            }
            defer {
                barCodeImageView.image = image
            }
            guard barcodeSource.count < 9 else {
                infoLabel.text = barcodeSource
                return
            }
            var extraBarcode = ""
            for (index, character) in barcodeSource.enumerated() {
                if index != 0 && index % 4 == 0 {
                    extraBarcode.append(" ")
                }
                extraBarcode.append(String(character))
            }
            infoLabel.text = extraBarcode
            
        }
    }
    
    func setup(with card: String?) {
        self.card = card
    }
    
    func addSubviews() {
        [
            self.patternImageView,
            self.balanceCountLabel,
            self.logoBalanceImageView,
            self.logoImageView,
            self.infoLabel,
            self.barCodeImageView
        ].forEach(self.addSubview)
    }

    func makeConstraints() {
        self.logoImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(18)
            make.top.equalToSuperview().offset(18)
            make.width.equalToSuperview().multipliedBy(0.55)
            make.height.equalTo(self.logoImageView.snp.width).multipliedBy(0.26)
        }
        self.patternImageView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        self.balanceCountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(18)
            make.top.equalToSuperview().inset(23)
        }
        self.logoBalanceImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 22, height: 18))
            make.trailing.equalTo(self.balanceCountLabel.snp.leading).offset(-5)
            make.centerY.equalTo(self.balanceCountLabel.snp.centerY)
        }
        self.infoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(28)
        }
        self.barCodeImageView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.4)
            make.height.equalTo(self.barCodeImageView.snp.width).multipliedBy(0.4)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.infoLabel.snp.top).offset(-10)
        }
        self.balanceCountLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
}
