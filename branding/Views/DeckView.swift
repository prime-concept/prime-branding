import UIKit

final class DeckView: UIView {
    static let cornerRadius: CGFloat = 10

    override func layoutSubviews() {
        super.layoutSubviews()
        self.roundCorners(
            corners: [.topLeft, .topRight],
            radius: DeckView.cornerRadius
        )
    }
}
