import Foundation
import UIKit

final class ShortcutsService {
    private let authService: LocalAuthService

    init(authService: LocalAuthService = LocalAuthService.shared) {
        self.authService = authService
    }

    func handle(item: UIApplicationShortcutItem) -> Bool {
        guard let type = ShortcutType(shortcutType: item.type) else {
            return false
        }

        switch type {
        case .loyalty:
            handleLoyalty()
        case .tickets:
            handleTickets()
        }

        return true
    }

    private func handleLoyalty() {
        guard let topController = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }

        let loyaltyAssembly = LoyaltyAssembly(loyalty: nil)
        let router = DeckRouter(
            source: topController,
            destination: loyaltyAssembly.buildModule()
        )
        router.route()
    }

    private func handleTickets() {
        let profileRouter = TabBarRouter(tab: 4)
        profileRouter.route()

        guard authService.isAuthorized else {
            return
        }

        guard let topController = UIApplication.shared
            .keyWindow?
            .rootViewController as? UITabBarController else {
                return
        }

        // Tab bar controller -> Navigation controller -> Controller
        let currentController = topController.selectedViewController
        guard let selectedViewController = currentController?.children.first else {
            return
        }

        let ticketsAssembly = TicketsAssembly()
        let pushRouter = PushRouter(
            source: selectedViewController,
            destination: ticketsAssembly.buildModule()
        )

        // waiting for tab bar final state
        DispatchQueue.main.async {
            pushRouter.route()
        }
    }

    // MARK: - Shortcut description

    enum ShortcutType: String {
        case loyalty
        case tickets

        init?(shortcutType: String) {
            guard let type = shortcutType.components(separatedBy: ".").last else {
                return nil
            }

            self.init(rawValue: type)
        }
    }
}
