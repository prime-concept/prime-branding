import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )

        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc
    func dismissKeyboard() {
        view.endEditing(true)
    }

    func updateNavigationBarStyle(_ bar: UINavigationBar) {
        // Common style
        bar.applyBrandingStyle()

        // Remove hairline
        bar.shadowImage = UIImage()

        // NB: we can't use just isTranslucent property
        // cause we want to get white background
        bar.isTranslucent = true

        bar.setBackgroundImage(
            UIImage.from(color: UIColor.white.withAlphaComponent(0.75)),
            for: .default
        )
        bar.barStyle = .default
        bar.backgroundColor = .clear

        let visualEffectView = makeBlurView()

        var navBarFrame = bar.bounds
        navBarFrame = navBarFrame.offsetBy(
            dx: 0,
            dy: -UIApplication.shared.statusBarFrame.height
        )
        navBarFrame.size.height += UIApplication.shared.statusBarFrame.height
        visualEffectView.frame = navBarFrame

        bar.addSubview(visualEffectView)
        visualEffectView.layer.zPosition = -1
    }

    func makeBlurView() -> UIVisualEffectView {
        let visualEffectView = UIVisualEffectView(
            effect: UIBlurEffect(style: .light)
        )
        if !FeatureFlags.shouldBlurTabBar {
            visualEffectView.backgroundColor = .white
        }
        visualEffectView.isUserInteractionEnabled = false
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        return visualEffectView
    }

	var topmostPresentedOrSelf: UIViewController {
		var result = self
		while let presented = result.presentedViewController {
			result = presented
		}
		return result
	}
}
