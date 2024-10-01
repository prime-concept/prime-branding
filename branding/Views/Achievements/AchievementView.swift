import Foundation
import SnapKit

final class AchievementView: UIView {
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private lazy var countLabel: UILabel  = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .lightGray
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .red
        self.setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with viewModel: AchievementModel) {
        self.title.text = viewModel.achievement.title
        if viewModel.registrationsCount >= viewModel.achievement.minimalRegCount {
            self.imageView.image = UIImage(named: "achievement_active_\(viewModel.achievement.sort)")
            self.countLabel.text = "\(viewModel.achievement.minimalRegCount) посещений"
        } else {
            self.imageView.image = UIImage(named: "achievement_blocked_\(viewModel.achievement.sort)")
            self.countLabel.text = "\(viewModel.registrationsCount)/\(viewModel.achievement.minimalRegCount) посещений"
        }
    }
    
    private func setupConstraints() {
        [
            self.imageView,
            self.title,
            self.countLabel
        ].forEach { self.addSubview($0) }
        
        self.layer.cornerRadius = 10
        self.backgroundColor = .white
        self.dropShadow(
			y: 3,
            radius: 15,
            color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.08),
            opacity: 1
        )
        self.imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-15)
            make.centerX.equalToSuperview()
            make.width.equalTo(self.snp.width).multipliedBy(0.5)
            make.height.equalTo(self.imageView.snp.width).multipliedBy(1.25)
        }

        self.countLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(14)
            make.centerX.equalToSuperview()
        }

        self.title.snp.makeConstraints { make in
            make.bottom.equalTo(self.countLabel.snp.top).offset(-3)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.imageView.snp.bottom).offset(10)
        }
    }
}

struct AchievementModel {
    let achievement: Achievement
    let registrationsCount: Int
}
