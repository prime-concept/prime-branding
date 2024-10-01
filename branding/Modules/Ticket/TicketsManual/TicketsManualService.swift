import Foundation

final class TicketsManualService {
    private let didShowTicketsManualKey = "didShowTicketsManual"
    private let defaults = UserDefaults.standard
    private var view: ModalRouterSourceProtocol?

    init(view: ModalRouterSourceProtocol?) {
        self.view = view
    }

    private var didShowManual: Bool {
        get {
            return defaults.value(forKey: didShowTicketsManualKey) as? Bool ?? false
        }
        set {
            defaults.set(newValue, forKey: didShowTicketsManualKey)
        }
    }

    func showManualIfNeeded() {
        if !didShowManual {
            showManual()
            didShowManual = true
        }
    }

    func showManual() {
        let manualAssembly = TicketsManualAssembly()
        let router = DeckRouter(
            source: view,
            destination: manualAssembly.buildModule()
        )
        router.route()
    }
}

