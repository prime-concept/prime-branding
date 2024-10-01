import SnapKit
import UIKit

protocol VideosHorizontalListViewProtocol: class {
    func update(viewModel: VideosHorizontalListViewModel)
    func updateVideos(viewModel: VideosHorizontalListViewModel)
}

final class VideosHorizontalListViewController: UIViewController, VideosHorizontalListViewProtocol {
    var presenter: VideosHorizontalListPresenter?
    var viewModel: VideosHorizontalListViewModel?

    private var currentBlocks: [VideosHorizontalBlockModule] = []
    private var pageIndex = 0 {
        didSet {
            if pageIndex != oldValue {
                updatePlayStatus()
            }
        }
    }

    private lazy var collectionView: UICollectionView = {
        let layout = YoutubeVideosFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 6
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width - 30, height: 300)

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        collectionView.isPagingEnabled = false
        collectionView.clipsToBounds = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear

        collectionView.register(cellClass: YoutubeVideoBlockCollectionViewCell.self)

        collectionView.dataSource = self

        return collectionView
    }()

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        [
            self.collectionView
        ].forEach(view.addSubview)

        self.collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }
        self.view = view
    }

    var blocks: [UIView] = []

    func reload(blocks: [VideosHorizontalBlockModule]) {
        let views: [UIView] = blocks.map { block in
            switch block {
            case .view(let view):
                return view
            case .viewController(let viewController):
                addChild(viewController)
                return viewController.view
            }
        }

        self.blocks = views
        collectionView.reloadData()
    }

    func updateVideos(viewModel: VideosHorizontalListViewModel) {
        self.viewModel = viewModel
        let youtubeSubviewViewModels = viewModel.subviews.compactMap { $0 as? YoutubeVideoBlockViewModel }
        let youtubeSubviews = currentBlocks.compactMap { block -> YoutubeVideoBlockViewController? in
            switch block {
            case .view:
                return nil
            case .viewController(let viewController):
                return viewController as? YoutubeVideoBlockViewController
            }
        }
        for subview in youtubeSubviews {
            if
                let id = subview.viewModel?.id,
                let viewModel = youtubeSubviewViewModels.first(where: { $0.id == id }) {
                subview.viewModel = viewModel
            }
        }
        collectionView.reloadData()
    }

    func update(viewModel: VideosHorizontalListViewModel) {
        self.viewModel = viewModel

        reload(
            blocks: viewModel.subviews.compactMap {
                $0.makeModule()
            }
        )
    }

    private func updatePlayStatus() {
        let youtubeSubviews = currentBlocks.enumerated().compactMap {
            index, block -> (index: Int, controller: YoutubeVideoBlockViewController)? in
            switch block {
            case .view:
                return nil
            case .viewController(let viewController):
                if let viewController = viewController as? YoutubeVideoBlockViewController {
                    return (index, viewController)
                } else {
                    return nil
                }
            }
        }

        for subview in youtubeSubviews {
            if pageIndex == subview.index {
                subview.controller.playVideo()
            } else {
                subview.controller.pauseVideo()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let viewModel = self.viewModel {
            self.update(viewModel: viewModel)
            self.updateVideos(viewModel: viewModel)
        } else {
            presenter?.reload()
        }
    }
}

enum VideosHorizontalBlockModule {
    case view(UIView)
    case viewController(UIViewController)
}

extension VideosHorizontalListViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageIndex = scrollView.currentPage
    }
}

extension UIScrollView {
    var currentPage: Int {
        return Int((self.contentOffset.x + (0.5 * self.frame.size.width)) / self.frame.width)
    }
}

extension UIStackView {
    func removeAllArrangedSubviews() {
        self.subviews.forEach { subview in
            self.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }
}

extension VideosHorizontalListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return blocks.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: YoutubeVideoBlockCollectionViewCell = collectionView.dequeueReusableCell(
            for: indexPath
        )

        let block = blocks[indexPath.item]
        cell.setup(view: block)
        return cell
    }
}

private class YoutubeVideosFlowLayout: UICollectionViewFlowLayout {
    override func targetContentOffset(
        forProposedContentOffset proposedContentOffset: CGPoint,
        withScrollingVelocity velocity: CGPoint
    ) -> CGPoint {
        let parentOffset = super.targetContentOffset(
            forProposedContentOffset: proposedContentOffset,
            withScrollingVelocity: velocity
        )

        guard let collectionView = self.collectionView else {
            return parentOffset
        }

        //TODO: Somehow guess why do we need this to work correctly
        let magicConstant: CGFloat = 4
        let itemSpace = self.itemSize.width + self.minimumInteritemSpacing + magicConstant
        var currentItemIDx = round((collectionView.contentOffset.x - collectionView.contentInset.left) / itemSpace)

        let velocityX = velocity.x
        if velocityX >= 0.6 {
            currentItemIDx += 1
        } else if velocityX <= -0.6 {
            currentItemIDx -= 1
        }

        let nearestPageOffset = currentItemIDx * itemSpace - collectionView.contentInset.left
        return CGPoint(x: nearestPageOffset, y: parentOffset.y)
    }
}
