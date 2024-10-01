import UIKit
import AdSupport

final class DebugMenuViewController: UIViewController {
	private lazy var vStack = UIStackView(.vertical)

	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.backgroundColor = .white
		self.view.addSubview(self.vStack)

		self.vStack.spacing = 5
		self.vStack.make(.edges, .equal, to: self.view.safeAreaLayoutGuide, [0, 20, 0, -20])

		self.addGrabberView()

		let switchProdView = with(UIView()) { view in
			let label = UILabel()
			label.text = "ПРОД включен: "
			view.addSubview(label)

			let pSwitch = UISwitch()
			pSwitch.isOn = !ApplicationConfig.isStageEnabled
			pSwitch.setEventHandler(for: .valueChanged) { [weak self] in
				self?.prodSwitchValueChanged(pSwitch)
			}
			view.addSubview(pSwitch)

			label.make([.leading, .centerY], .equalToSuperview)
			pSwitch.make([.trailing, .centerY], .equalToSuperview)
			view.make(.height, .equal, 44)
		}

		let fcmTokenLabel = self.makeShareableLabel(
			title: "🔑 FCM TOKEN (firebase): ",
			text: UserDefaults[string: "FCM_TOKEN"] ?? "НЕДОСТУПЕН"
		)

		let idfv = UIDevice.current.identifierForVendor?.uuidString ?? "IDFV Недоступен"
		let idfvLabel = self.makeShareableLabel(title: "🔑 IDFV (vendor): ", text: idfv)

		let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
		let idfaLabel = self.makeShareableLabel(title: "🔑 IDFA (ad, реклама): ", text: idfa)

		self.vStack.addArrangedSpacer(22)
		self.vStack.addArrangedSubview(switchProdView)
		self.vStack.addArrangedSubview(fcmTokenLabel)
		self.vStack.addArrangedSubview(idfvLabel)
		self.vStack.addArrangedSubview(idfaLabel)
		self.vStack.addArrangedSpacer(growable: 0)
	}

	@objc
	private func prodSwitchValueChanged(_ prodSwitch: UISwitch) {
		let alert = UIAlertController(title: "Смена параметров",
									  message: "Приложение будет закрыто для применения новых параметров",
									  preferredStyle: .alert)
		alert.addAction(.init(title: "Отмена", style: .cancel, handler: { _ in
			prodSwitch.isOn = !prodSwitch.isOn
		}))
		alert.addAction(.init(title: "Закрыть", style: .destructive) { _ in
			ApplicationConfig.isStageEnabled = !prodSwitch.isOn
			LocalAuthService.shared.logout()
			RealmPersistenceService.shared.deleteAll()
			delay(1) {
				exit(1)
			}
		})
		self.present(alert, animated: true, completion: nil)
	}

	private func addGrabberView() {
		let grabberView = UIView()
		grabberView.layer.cornerRadius = 2
		grabberView.backgroundColor = .gray
		self.view.addSubview(grabberView)
		grabberView.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.size.equalTo(CGSize(width: 36, height: 4))
			make.top.equalToSuperview().offset(10)
		}
	}

	private func makeShareableLabel(title: String, text: String) -> UILabel {
		UILabel { (label: UILabel) in
			label.textColor = .black
			label.textAlignment = .left
			label.lineBreakMode = .byWordWrapping
			label.numberOfLines = 0
			label.text = title + text
			label.isUserInteractionEnabled = true
			label.onTap = {
				Self.shareText(text)
			}
		}
	}
}

extension DebugMenuViewController {
	static func shareText(_ text: String, completion: (() -> Void)? = nil) {
		onMain {
			let activityItems = [text]

			let activity = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
			activity.excludedActivityTypes = [.assignToContact, .postToTwitter]
			activity.completionWithItemsHandler = { _, _, _, _ in
				completion?()
			}

			let rootVC = UIApplication.shared.keyWindow?
				.rootViewController?
				.topmostPresentedOrSelf
			rootVC?.present(activity, animated: true)
		}
	}
}

private class LogViewer: UIViewController {
	private(set) lazy var textView = UITextView()

	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.backgroundColor = .white

		self.view.addSubview(self.textView)

		if #available(iOS 13.0, *) {
			self.textView.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
		}

		self.textView.isEditable = false
		self.textView.make(.edges, .equal, to: self.view.safeAreaLayoutGuide, [0, 10, 0, -10])
	}

	func scrollToBottom() {
		let range = NSMakeRange(self.textView.text.lengthOfBytes(using: .utf8), 0);
		self.textView.scrollRangeToVisible(range);
	}
}
