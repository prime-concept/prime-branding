import UIKit

class OnboardingPage1ViewController: UIViewController {
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var screenshotImageView: UIImageView!

    var showNextBlock: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
    }

    func localize() {
        nextButton.setTitle(LS.localize("Next"), for: .normal)
		textLabel.text = LS.localize("OnboardingText1").uppercased()
        logoImageView.image = UIImage(named: LS.localize("ms-logo-image"))
        screenshotImageView.image = UIImage(named: LS.localize("OnboardingImage1"))
    }

    @IBAction func nextPressed(_ sender: Any) {
        showNextBlock?()
    }
}
