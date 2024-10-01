import Foundation
import UIKit
import SnapKit
import Nuke

final class DetailPlaceCalendarTableViewCell: UITableViewCell, ViewReusable {
    private lazy var scheduleLabel: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textAlignment = .left
        label.textColor = .halfBlackColor
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .left
        label.textColor = .white
        return label
    }()
    
    private lazy var onlineRegistrationLabel: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = .clear
        label.text = LS.localize("OnlineRegistrationNeeded")
        return label
    }()
    
    private lazy var onlineRegistrationView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor(red: 0.843, green: 0.078, blue: 0.251, alpha: 0.6)
        return view
    }()
    
    private lazy var topView: UIView = {
        var view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var eventCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 5
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15);
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = false
        collectionView.register(cellClass: DetailEventCalendarCollectionViewCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var emptyView: UIView = {
        var view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    private lazy var emptyViewLabel: UILabel = {
        var label = UILabel()
        label.textColor = .halfBlackColor
        label.text = LS.localize("NoEventsForDate")
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var nearestDateButton: UIButton = {
        var button = UIButton()
        button.setTitleColor(.mfBlueColor, for: .normal)
        button.setTitle(LS.localize("ToSignIn"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(nearestDateButtonPressed), for: .touchUpInside)
        return button
    }()

    private var viewModel: DetailDateListViewModel?
    private var selectedDayIndex: Int = 0
    var onRegistrationClicked: ((DetailDateListViewModel.EventItem) -> Void)?
    var onNearestDateClicked: ((Int) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with viewModel: DetailDateListViewModel, dayIndex: Int) {
        self.viewModel = viewModel
        self.selectedDayIndex = dayIndex
        self.titleLabel.text = viewModel.title
        self.backgroundImageView.backgroundColor = .mfBlueColor
        self.eventCollectionView.reloadData()
        if let event = viewModel.events.first?.first, event.isOnlineRegistration == true {
            self.onlineRegistrationView.isHidden = false
        } else {
            self.onlineRegistrationView.isHidden = true
        }
        if let imageUrl = viewModel.imageUrl, let url = URL(string: imageUrl) {
            Nuke.loadImage(with: url, into: self.backgroundImageView)
        }
        self.nearestDateButton.setTitle(viewModel.nearestDateString, for: .normal)
    }
    
    func setupView() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.contentView.layer.borderColor = UIColor.blueBackgroundColor.cgColor
        self.contentView.layer.borderWidth = 1
        self.contentView.setRoundedCorners(radius: 10)
        self.onlineRegistrationView.setRoundedCorners(radius: 10)
        self.scheduleLabel.text = LS.localize("EventSchedule")
    }

    func addSubviews() {
        [
            self.backgroundImageView,
            self.titleLabel,
            self.onlineRegistrationView
        ].forEach(self.topView.addSubview)
        self.onlineRegistrationView.addSubview(self.onlineRegistrationLabel)
        [
            self.emptyViewLabel,
            self.nearestDateButton
        ].forEach(self.emptyView.addSubview)
        [
            self.topView,
            self.scheduleLabel,
            self.eventCollectionView,
            self.emptyView
        ].forEach(self.contentView.addSubview)
    }

    func makeConstraints() {
        self.backgroundImageView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(self.backgroundImageView.snp.width).multipliedBy(0.35)
            make.bottom.equalToSuperview()
        }
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(10)
        }
        self.onlineRegistrationView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(15)
        }
        self.onlineRegistrationLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)
            make.top.bottom.equalToSuperview().inset(3)
        }
        self.topView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
        self.scheduleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalTo(self.topView.snp.bottom).offset(12)
        }
        self.eventCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.scheduleLabel.snp.bottom).offset(20)
            make.height.equalTo(130)
            make.bottom.equalToSuperview().inset(10)
        }
        self.emptyViewLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(25)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(15)
        }
        self.nearestDateButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.emptyViewLabel.snp.bottom).offset(5)
        }
        self.emptyView.snp.makeConstraints { make in
            make.edges.equalTo(self.eventCollectionView.snp.edges)
        }
        self.contentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
        }
    }
    
    @objc
    func nearestDateButtonPressed() {
        guard let viewModel = viewModel else { return }
        self.onNearestDateClicked?(viewModel.firstDateIndex)
    }
    
    private func getEventItemsForSelectedDay() -> [DetailDateListViewModel.EventItem] {
        guard let viewModel = viewModel,
              let eventItems = viewModel.events[safe: selectedDayIndex] else {
            fatalError("Cell's count > 0, but empty viewModel")
        }

        return eventItems
    }
}

extension DetailPlaceCalendarTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = viewModel,
              !viewModel.events[selectedDayIndex].isEmpty else {
            self.emptyView.isHidden = false
            return 0
        }
        self.emptyView.isHidden = true
        return viewModel.events[selectedDayIndex].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: DetailEventCalendarCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        let eventItems = getEventItemsForSelectedDay()
        cell.setup(with: eventItems[indexPath.row])
        cell.onRegistrationClicked = { [weak self] in
            guard let eventItems = self?.getEventItemsForSelectedDay() else {
                return
            }
            self?.onRegistrationClicked?(eventItems[indexPath.row])
        }
        return cell
    }
}
