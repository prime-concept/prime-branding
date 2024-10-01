import Foundation
import UIKit
import SnapKit

final class ProfileAchievementTableCell: UITableViewCell, ViewReusable {
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fillEqually
        view.spacing = 6
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubviews()
        self.makeConstraints()
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(with viewModel: [Achievement], registrationsCount: Int) {
        stackView.removeAllArrangedSubviews()
        viewModel.sorted {
            $0.sort < $1.sort
        }.forEach { model in
            let view = AchievementView()
            view.setup(with: AchievementModel(achievement: model, registrationsCount: registrationsCount))
            self.stackView.addArrangedSubview(view)
        }
    }

    func addSubviews() {
        self.contentView.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.stackView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(25)
            make.leading.trailing.equalToSuperview().inset(15)
        }
    }
    
}
