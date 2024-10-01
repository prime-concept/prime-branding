import UIKit

class AppWindow: UIWindow {
	override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		 self.presentDebugMenuIfNeeded(for: motion)
	}

	private func presentDebugMenuIfNeeded(for motion: UIEvent.EventSubtype) {
		guard ApplicationConfig.isDebugEnabled, motion == .motionShake else {
			return
		}

		guard let topVC = self.rootViewController?.topmostPresentedOrSelf else {
			return
		}

		if topVC is DebugMenuViewController {
			return
		}

		let debugMenu = DebugMenuViewController()
		topVC.present(debugMenu, animated: true, completion: nil)
	}
}
