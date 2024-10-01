import Foundation

final class HomeHeaderView: UICollectionReusableView, ViewReusable, NibLoadable {
    static let backgroundColor = ApplicationConfig.Appearance.firstTintColor

    private var isInit = false
    private var timer = Timer()

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var timerLabel: UILabel!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet weak var storyContainerView: UIView!
    @IBOutlet weak var storyContainerViewHeight: NSLayoutConstraint!

    @IBOutlet private var horizontalConstraints: [NSLayoutConstraint]!

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var sourceDate: Date? {
        didSet {
            scheduleTimer()
            updateTimer()
        }
    }

    var textFieldDelegate: UITextFieldDelegate? {
        get {
            return searchTextField.delegate
        }
        set {
            searchTextField.delegate = newValue
        }
    }

    weak var parent: UIViewController?
    weak var storiesHeightUpdateDelegate: StoriesHeightUpdateDelegate?
    var storiesViewController: UIViewController?

    override func layoutSubviews() {
        super.layoutSubviews()

        if !isInit {
            isInit = true

            backgroundColor = HomeHeaderView.backgroundColor

            let iconSize = CGSize(width: 14, height: 14)
            let iconInsets = UIEdgeInsets(top: 11, left: 10, bottom: 11, right: 2)

            let iconContainerView = UIView(
                frame: CGRect(
                    x: 0,
                    y: 0,
                    width: Int(iconSize.width + iconInsets.left + iconInsets.right),
                    height: Int(iconSize.height + iconInsets.top + iconInsets.bottom)
                )
            )
            let iconView = UIImageView(
                frame: CGRect(
                    x: iconInsets.left,
                    y: iconInsets.top,
                    width: iconSize.width,
                    height: iconSize.height
                )
            )
            iconView.image = UIImage(named: "search_home_field")
            iconView.tintColor = .white
            iconContainerView.addSubview(iconView)

            searchTextField.attributedPlaceholder = NSAttributedString(
                string: LS.localize("SearchPlaceholder"),
                attributes: [
                    .foregroundColor: UIColor.white,
                    .font: UIFont.systemFont(ofSize: 15)
                ]
            )
            searchTextField.leftViewMode = .always
            searchTextField.leftView = iconContainerView

            let storiesAssembly = StoriesAssembly(
                output: self
            )
            storiesViewController = storiesAssembly.makeModule()
            if let storiesViewController = storiesViewController {
                parent?.addChild(storiesViewController)
                storyContainerView.addSubview(storiesViewController.view)
                storiesViewController.view.attachEdges(to: storyContainerView)
            }

            horizontalConstraints.forEach {
                $0.constant = UIDevice.current.getDeviceName() == nil ? 16.0 : 20.0
            }
        }
    }

    func update(viewModel: HomeItemViewModel) {
        title = viewModel.title
        if case .counter(let date) = viewModel.type {
            sourceDate = date
        }
    }

    private func scheduleTimer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(updateTimer),
            userInfo: nil,
            repeats: true
        )
    }

    @objc
    private func updateTimer() {
		timerLabel.text = self.getTimeString(sourceDate: self.sourceDate)
		timerLabel.isHidden = (timerLabel.text ?? "").count == 0
    }

    private func getTimeString(sourceDate: Date?) -> String? {
		guard let sourceDate = sourceDate else {
			return nil
		}

        let currentDate = Date()

        guard sourceDate > currentDate else {
            return nil
        }

        let diff = Calendar.current.dateComponents(
            [.day, .hour, .minute, .second],
            from: currentDate,
            to: sourceDate
        )

		let components: [String] = [diff.hour, diff.minute, diff.second].map { component in
			let result = "\(component ?? 0)"
			if result.count > 1 {
				return result
			}

			return "0\(result)"
		}

		let time = components.joined(separator: ":")
		let all = "\(diff.day ?? 0):\(time)"

		return all
    }
}

extension HomeHeaderView: StoriesOutputProtocol {
    func hideStories() {
        storyContainerViewHeight.constant = 0
        storiesViewController?.removeFromParent()
        storyContainerView.isHidden = true
        storiesHeightUpdateDelegate?.hideStories()
    }
}

protocol StoriesHeightUpdateDelegate: class {
    func hideStories()
}
