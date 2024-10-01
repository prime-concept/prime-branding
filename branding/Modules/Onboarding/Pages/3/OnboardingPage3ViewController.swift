import UIKit
import AppTrackingTransparency

class OnboardingPage3ViewController: UIViewController {
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var openProfileButton: UIButton!
    @IBOutlet weak var screenshotImageView: UIImageView!
	@IBOutlet weak var doneButton: UIButton!

    var openProfileBlock: (() -> Void)?
	var doneBlock: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
    }

    func localize() {
        openProfileButton.setTitle(LS.localize("LogInButton"), for: .normal)
        textLabel.text = LS.localize("OnboardingText3").uppercased()
        screenshotImageView.image = UIImage(named: LS.localize("OnboardingImage3"))
		doneButton.setTitle(NSLocalizedString("Close", comment: ""), for: .normal)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsEvents.Onboarding.toThird.send()
    }

    @IBAction func openProfileButtonPressed(_ sender: Any) {
        requestAppTrackingThen(completion: openProfileBlock)
    }

	@IBAction func doneButtonPressed(_ sender: Any) {
		requestAppTrackingThen(completion: doneBlock)
	}

	private func requestAppTrackingThen(completion: (() -> Void)?) {
		if #available(iOS 14.5, *) {
			ATTrackingManager.requestTrackingAuthorization { _ in
				onMain {
					completion?()
				}
			}
		} else {
			onMain {
				completion?()
			}
		}
	}
}
