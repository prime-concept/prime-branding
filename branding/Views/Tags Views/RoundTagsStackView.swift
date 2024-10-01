import Foundation
import UIKit
import SnapKit
import Nuke
import NukeWebPPlugin

final class RoundTagsStackView: UIView {
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.spacing = 5
        return view
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
    
    private func setupView() {
        self.addSubview(self.stackView)
    }
    
    private func setupConstraints() {
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setup(with viewModel: [String]) {
        self.stackView.removeAllArrangedSubviews()
        let urlViewModel = viewModel.compactMap { URL(string: $0)}
        for (index, item) in urlViewModel.enumerated() where index < 4 {
            let tagView = RoundTagView()
            tagView.setup(url: item)
            self.stackView.addArrangedSubview(tagView)
        }
        if viewModel.count > 4 {
            let tagView = RoundTagView()
            tagView.setup(text: " +\(viewModel.count - 4) ")
            self.stackView.addArrangedSubview(tagView)
        }
    }
}
