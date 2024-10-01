import UIKit

class ScrollableStack: UIScrollView {
    var axis: NSLayoutConstraint.Axis {
        get { self.stackView.axis }
        set { self.updateAxis(newValue) }
    }

    private(set) var stackView = UIStackView()
    private var widthConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?

    init(_ axis: NSLayoutConstraint.Axis, arrangedSubviews: [UIView] = []) {
        super.init(frame: .zero)

        self.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.stackView)
        self.stackView.make(.edges, .equalToSuperview)

        self.widthConstraint = self.stackView.make(.width, .equalToSuperview)
        self.heightConstraint = self.stackView.make(.height, .equalToSuperview)

        self.updateAxis(axis)
        self.setArrangedSubviews(arrangedSubviews)
    }

    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func addArrangedSubview(_ subview: UIView) {
        self.stackView.addArrangedSubview(subview)
    }

    func addArrangedSubviews(_ subviews: UIView...) {
        self.stackView.addArrangedSubviews(subviews)
    }

    func addArrangedSubviews(_ subviews: [UIView]) {
        self.stackView.addArrangedSubviews(subviews)
    }

    func setArrangedSubviews(_ subviews: UIView...) {
        self.removeArrangedSubviews()
        self.stackView.addArrangedSubviews(subviews)
    }

    func setArrangedSubviews(_ subviews: [UIView]) {
        self.removeArrangedSubviews()
        self.stackView.addArrangedSubviews(subviews)
    }

    func removeArrangedSubviews() {
        self.stackView.arrangedSubviews.forEach {
            self.stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }

    private func updateAxis(_ axis: NSLayoutConstraint.Axis) {
        self.stackView.axis = axis

        self.widthConstraint?.isActive = false
        self.heightConstraint?.isActive = false

        self.widthConstraint?.isActive = axis == .vertical
        self.heightConstraint?.isActive = axis == .horizontal
    }
}
