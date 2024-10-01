import UIKit

final class LoyaltyProgramAboutCollectionViewCell: UICollectionViewCell, ViewReusable {
    lazy var tileView: ImageTitleDetailTile = {
        let view = ImageTitleDetailTile(frame: .zero)
        contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-7.5)
            make.leading.equalToSuperview().offset(7.5)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        return view
    }()

    func update(with viewModel: LoyaltyProgramAboutViewModel) {
        tileView.text = viewModel.text
        tileView.subText = viewModel.subText
        tileView.imageURL = viewModel.imageURL
    }
}
