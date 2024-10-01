import Foundation

class OnboardingService {
    private let didShowOnboardingKey = "didShowOnboardingKey"
    private let defaults = UserDefaults.standard

    private var didShowOnboarding: Bool {
        get {
            return defaults.value(forKey: didShowOnboardingKey) as? Bool ?? false
        }
        set {
            defaults.set(newValue, forKey: didShowOnboardingKey)
        }
    }

    func showOnboardingIfNeeded() {
        if !didShowOnboarding {
            showOnboarding()
            didShowOnboarding = true
        }
    }

    private func showOnboarding() {
        let onboardingModule = OnboardingAssembly().buildModule()
        let onboardingRouter = ModalRouter(source: nil, destination: onboardingModule)
        onboardingRouter.route()
    }
}
