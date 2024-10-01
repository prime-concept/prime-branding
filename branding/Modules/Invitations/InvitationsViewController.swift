import Foundation
import SnapKit

protocol InvitationsViewControllerProtocol: class {
    func reloadCollection(bookings: [BookingViewModel])
}

final class InvitationsViewController: UIViewController {
    var presenter: InvitationsPresenterProtocol?
    private var viewModel: [BookingViewModel] = []
    
    private lazy var bookingCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 15
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = false
        collectionView.register(cellClass: UserBookingCollectionViewCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        title = LS.localize("UserBooking")
        self.makeConstraints()
        self.view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter?.viewDidAppear()
    }
    
    private func setupUI() {
        self.view.addSubview(self.bookingCollectionView)
    }
    
    private func makeConstraints() {
        self.bookingCollectionView.snp.makeConstraints { make in
            make.trailing.leading.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(40)
        }
    }
}

extension InvitationsViewController: InvitationsViewControllerProtocol {
    func reloadCollection(bookings: [BookingViewModel]) {
        self.viewModel.append(contentsOf: bookings)
        self.bookingCollectionView.reloadData()
    }
}

extension InvitationsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UserBookingCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.setup(with: viewModel[indexPath.row])
        return cell
    }
}
