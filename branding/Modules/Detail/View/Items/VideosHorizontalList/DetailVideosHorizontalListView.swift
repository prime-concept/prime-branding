import UIKit

final class DetailVideosHorizontalListView: UIView, NamedViewProtocol {
    var name: String {
        return "youtubeVideos"
    }

    init() {
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(with view: UIView) {
        self.addSubview(view)
        view.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(7.5)
            make.trailing.bottom.equalToSuperview()
        }

        setNeedsLayout()
        layoutIfNeeded()
    }
}
