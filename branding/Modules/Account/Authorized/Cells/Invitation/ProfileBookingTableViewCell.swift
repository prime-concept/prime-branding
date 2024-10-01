import Foundation
import UIKit
import SnapKit
import Nuke

final class ProfileBookingTableViewCell: UITableViewCell, ViewReusable {
    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .left
        label.text = LS.localize("UserBooking")
        label.textColor = .black
        return label
    }()
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var bookingCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 15
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 50);
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = false
        collectionView.register(cellClass: UserBookingCollectionViewCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var emptyView: UIView = {
        var view = UIView()
        view.backgroundColor = .tagsBackgroundColor
        view.setRoundedCorners(radius: 10)
        view.isHidden = true
        return view
    }()
    
    private lazy var emptyViewLabel: UILabel = {
        var label = UILabel()
        label.textColor = .halfBlackColor
        label.text = LS.localize("EmptyUserBookingView")
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "empty_invitation")
        imageView.clipsToBounds = true
        return imageView
    }()

    private var viewModel: [BookingViewModel] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with viewModel: [BookingViewModel]) {
        self.viewModel = viewModel
        self.backgroundImageView.backgroundColor = .clear
        if viewModel.isEmpty {
            self.emptyView.isHidden = false
        } else {
            self.emptyView.isHidden = true
            self.bookingCollectionView.reloadData()
        }
    }
    
    func setupView() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.contentView.setRoundedCorners(radius: 10)
    }

    func addSubviews() {
        [
            self.emptyViewLabel,
            self.emptyImageView
        ].forEach(self.emptyView.addSubview)
        self.emptyView.addSubview(self.emptyViewLabel)
        [
            self.titleLabel,
            self.bookingCollectionView,
            self.emptyView
        ].forEach(self.contentView.addSubview)
    }

    func makeConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(30)
        }
        self.bookingCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(15)
            make.height.equalTo(145)
            make.bottom.equalToSuperview().inset(10)
        }
        self.emptyImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.size.equalTo(CGSize(width: 100, height: 100))
            make.centerX.equalToSuperview()
        }
        self.emptyViewLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.bottom.equalToSuperview().inset(15)
        }
        self.emptyView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(15)
            make.bottom.equalToSuperview().inset(10)
            make.leading.trailing.equalToSuperview().inset(15)
        }
        self.contentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
    }
}

extension ProfileBookingTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UserBookingCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.setup(with: viewModel[indexPath.row])
        return cell
    }
}
