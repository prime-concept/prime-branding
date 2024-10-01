import Foundation
import UIKit
import SnapKit

final class DetailEventCalendarCollectionViewCell: UICollectionViewCell, ViewReusable {
    
    private lazy var timeLabel: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.textColor = .redColor
        return label
    }()
    
    private lazy var placesLabel: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textAlignment = .center
        label.textColor = .mfBlueColor
        return label
    }()
    
    private lazy var ageLabel: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textAlignment = .center
        label.textColor = .redColor
        return label
    }()
    
    private lazy var ageView: UIView = {
        var view = UIView()
        view.backgroundColor = .redBackgroundColor
        view.setRoundedCorners(radius: 8)
        view.addSubview(self.ageLabel)
        return view
    }()
    
    private lazy var placesView: UIView = {
        var view = UIView()
        view.backgroundColor = .blueBackgroundColor
        view.setRoundedCorners(radius: 8)
        view.addSubview(self.placesLabel)
        return view
    }()
    
    private lazy var tagStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = 5
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textAlignment = .left
        label.textColor = .black
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var registrationButton: UIButton = {
        var button = UIButton()
        button.setTitleColor(.mfBlueColor, for: .normal)
        button.setTitle(LS.localize("ToSignIn"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .blueBackgroundColor
        button.addTarget(self, action: #selector(registrationPressed), for: .touchUpInside)
        return button
    }()
    
    var onRegistrationClicked: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with viewModel: DetailDateListViewModel.EventItem) {
        self.timeLabel.text = viewModel.timeString
        self.titleLabel.text = viewModel.title
        self.ageLabel.text = viewModel.age ?? ""
        self.placesLabel.text = LS.localize("PlacesLeft") + " \(viewModel.count)"
        if !viewModel.isOnlineRegistration {
            self.registrationButton.isHidden = true
            self.placesView.isHidden = true
            self.registrationButton.snp.updateConstraints { make in
                make.top.equalTo(self.titleLabel.snp.bottom)
            }
        } else if viewModel.count == 0 {
            self.placesView.isHidden = true
            self.registrationButton.setTitleColor(.mfBlueColor, for: .normal)
            registrationButton.setTitle(LS.localize("NotAvailable"), for: .normal)
            self.registrationButton.isEnabled = false
            self.registrationButton.snp.updateConstraints { make in
                make.top.equalTo(self.titleLabel.snp.bottom).offset(15)
            }
        } else {
            self.registrationButton.isHidden = false
            self.placesView.isHidden = false
            self.registrationButton.setTitle(LS.localize("ToSignIn"), for: .normal)
            self.registrationButton.backgroundColor = .blueBackgroundColor
            self.registrationButton.isEnabled = true
            self.registrationButton.snp.updateConstraints { make in
                make.top.equalTo(self.titleLabel.snp.bottom).offset(15)
            }
        }
    }
    
    @objc
    func registrationPressed() {
        self.onRegistrationClicked?()
    }
    
    func setupView() {
        self.backgroundColor = .clear
        self.registrationButton.setRoundedCorners(radius: 18)
        self.contentView.layer.borderColor = UIColor.blueBackgroundColor.cgColor
        self.contentView.layer.borderWidth = 1
        self.contentView.setRoundedCorners(radius: 10)
    }

    func addSubviews() {
        [
            self.placesView,
            self.ageView
        ].forEach(self.tagStackView.addArrangedSubview)
        
        [
            self.timeLabel,
            self.titleLabel,
            self.tagStackView,
            self.registrationButton
        ].forEach(self.contentView.addSubview)
    }

    func makeConstraints() {
        self.timeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(10)
        }
        self.ageLabel.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview().inset(6)
            make.top.bottom.equalToSuperview().inset(1)
        }
        self.placesLabel.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview().inset(6)
            make.top.bottom.equalToSuperview().inset(1)
        }
        self.tagStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(13)
            make.trailing.equalToSuperview().inset(15)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalTo(self.timeLabel.snp.bottom).offset(8)
            make.height.equalTo(32)
        }
        self.registrationButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(15)
            make.width.equalTo(250)
            make.bottom.equalToSuperview().inset(10)
        }
        self.contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
