import UIKit

final class OnboardingAssembly: UIViewControllerAssemblyProtocol {
    func buildModule() -> UIViewController {
        return OnboardingViewController()
    }
}
