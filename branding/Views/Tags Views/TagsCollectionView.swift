import Foundation
import UIKit
import SnapKit

final class TagsCollectionView: UIView, NamedViewProtocol {
    private lazy var titleLabel = with(UILabel()) { label in
        label.text = LS.localize("WhatToDo")
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .lightGray
        label.isHidden = (label.text ?? "").isEmpty
    }

    private lazy var firstStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = 5
        return view
    }()
    
    private lazy var secondStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = 5
        return view
    }()

    private lazy var scrollView = UIScrollView()
    private lazy var tagView = UIView()
	private lazy var contentView = UIView()
    
    var onLayoutUpdate: (() -> Void)?
    var name: String {
        return "tagsRow"
    }

	var contentInset: UIEdgeInsets = .zero {
		didSet {
			self.contentView.removeFromSuperview()
			self.addSubview(self.contentView)
			
			self.contentView.make(.edges, .equalToSuperview, [
				contentInset.top,
				contentInset.left,
				-contentInset.bottom,
				-contentInset.right]
			)
		}
	}
    
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
		self.addSubview(self.contentView)

        if !titleLabel.isHidden {
            self.contentView.addSubview(titleLabel)
        }
		self.contentView.addSubview(self.scrollView)

		self.scrollView.showsHorizontalScrollIndicator = false
		self.scrollView.addSubview(tagView)
		self.scrollView.contentInset.right = 15
    }
    
    private func setupConstraints() {
		self.contentView.make(.edges, .equalToSuperview)

		let stackOfStacks = UIStackView(.vertical)
		stackOfStacks.alignment = .leading
		stackOfStacks.spacing = 5
		stackOfStacks.addArrangedSubviews(self.firstStackView, self.secondStackView)

		self.tagView.addSubview(stackOfStacks)
		stackOfStacks.make(.edges, .equalToSuperview)

        self.tagView.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalToSuperview().inset(15)
        }

        if !titleLabel.isHidden {
            self.titleLabel.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().inset(15)
            }
        }

        self.scrollView.snp.makeConstraints { make in
            if self.titleLabel.isHidden {
                make.top.equalToSuperview()
            } else {
                make.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            }
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.tagView.snp.height)
        }
        self.onLayoutUpdate?()
    }
    
    func setup(with viewModel: DetailTagTitlesViewModel) {
        let rowLength = viewModel.tags.map{ $0.title.count }.reduce(0, +) / 2
        var rowLengthSum = 0
        for item in viewModel.tags {
            rowLengthSum += item.title.count
            let tagView = EventTagView()
            tagView.setup(with: item)
            rowLengthSum < rowLength ? (self.firstStackView.addArrangedSubview(tagView)) : (self.secondStackView.addArrangedSubview(tagView))
        }

		self.firstStackView.isHidden = self.firstStackView.arrangedSubviews.isEmpty
		self.secondStackView.isHidden = self.secondStackView.arrangedSubviews.isEmpty
    }
}
