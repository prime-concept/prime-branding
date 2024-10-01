import Foundation
import UIKit

final class TicketsCollectionViewCell: TileCollectionViewCell<TicketTileView>, ViewReusable,
UIGestureRecognizerDelegate {
    private static let defaultTileColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
    private static let returnViewColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1)

    var onShareButtonTouch: (() -> Void)?
    var onReturnViewTap: (() -> Void)?

    lazy var returnTicketView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = TicketsCollectionViewCell.returnViewColor

        view.topAnchor.constraint(
            equalTo: contentView.topAnchor,
            constant: 5
            ).isActive = true
        view.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: -10
            ).isActive = true
        view.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor,
            constant: 7.5
            ).isActive = true
        view.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor,
            constant: -7.5
            ).isActive = true

        return view
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        resetTile()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
        setupTap()
        setupPan()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()

        setupTap()
        setupPan()
    }

    override func resetTile() {
        tileView.title = ""
        tileView.subtitle = ""
    }

    @objc
    func onPan(_ pan: UIPanGestureRecognizer) {
        let x = returnTicketView.frame.minX
        let y = returnTicketView.frame.minY
        let mid = returnTicketView.frame.midX
        let width = tileView.frame.width
        let height = tileView.frame.height
        let spaceForTap = width / 5
        let deltaX = returnTicketView.frame.minX + spaceForTap
        let point = pan.translation(in: self)
        if pan.state == .changed {
            if point.x > 0 {
                tileView.frame = CGRect(x: point.x, y: y, width: width, height: height)
            }
            if point.x > mid {
                guard let collectionView = superview as? UICollectionView else {
                    return
                }

                guard let indexPath = collectionView.indexPathForItem(at: center) else {
                    return
                }

                // swiftlint:disable:next force_unwrapping
                collectionView.delegate?.collectionView!(
                    collectionView,
                    performAction: #selector(onPan(_:)),
                    forItemAt: indexPath,
                    withSender: nil
                )
                pan.state = .ended
            }
        }
        if pan.state == .ended {
            if point.x > spaceForTap, point.x < mid {
                UIView.animate(withDuration: 0.2) {
                    self.tileView.frame = CGRect(x: deltaX, y: y, width: width, height: height)
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.tileView.frame = CGRect(x: x, y: y, width: width, height: height)
                }
            }
        }
    }

    private func setupTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(returnTap))
        returnTicketView.addGestureRecognizer(tap)
    }

    @objc
    private func returnTap() {
        onReturnViewTap?()
    }

   private func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }

    private func commonInit() {
        let image = UIImage(named: "returnTicket")
        let imageView = UIImageView(image: image)
        imageView.tintColor = .white
        returnTicketView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -60).isActive = true
        imageView.leadingAnchor.constraint(equalTo: returnTicketView.leadingAnchor, constant: 12).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 44).isActive = true

        let returnLabel = UILabel()
        returnLabel.text = LS.localize("Return")
        returnLabel.font = .boldSystemFont(ofSize: 11)
        returnLabel.textColor = .white
        returnTicketView.addSubview(returnLabel)
        returnLabel.translatesAutoresizingMaskIntoConstraints = false
        returnLabel.leadingAnchor.constraint(equalTo: returnTicketView.leadingAnchor, constant: 10).isActive = true
        returnLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 0).isActive = true
    }

    private func setupPan() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        pan.delegate = self
        tileView.addGestureRecognizer(pan)
    }

    func update(viewModel: TicketViewModel) {
        tileView.title = viewModel.title
        tileView.subtitle = viewModel.subtitle
        tileView.color = TicketsCollectionViewCell.defaultTileColor

        if let url = viewModel.imageUrl {
            tileView.loadImage(from: url)
        }

        tileView.onShare = { [weak self] in
            self?.onShareButtonTouch?()
        }
    }
}
