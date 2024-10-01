import UIKit

class OnboardingPage2ViewController: UIViewController {
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var screenshotImageView: UIImageView!

    var showNextBlock: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
    }

    func localize() {
        nextButton.setTitle(LS.localize("Next"), for: .normal)
        textLabel.text = LS.localize("OnboardingText2").uppercased()
        screenshotImageView.image = UIImage(named: LS.localize("OnboardingImage2"))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsEvents.Onboarding.toSecond.send()
    }

    @IBAction func nextPressed(_ sender: Any) {
        showNextBlock?()
    }
}
