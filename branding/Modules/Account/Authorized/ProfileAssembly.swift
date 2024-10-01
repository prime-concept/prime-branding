import Foundation
import UIKit

class ProfileAssembly: UIViewControllerAssemblyProtocol {
    private var user: User
    private var primeLoyaltyScanned: Bool
    init(user: User, primeLoyaltyScanned: Bool = false) {
        self.user = user
        self.primeLoyaltyScanned = primeLoyaltyScanned
    }

    func buildModule() -> UIViewController {
        let profileVC = ProfileViewController()
        profileVC.presenter = ProfilePresenter(
            view: profileVC,
            user: user,
            favoritesAPI: FavoritesAPI(),
            loyaltyAPI: LoyaltyAPI(),
            ticketAPI: TicketAPI(),
            primeLoyaltyScanned: primeLoyaltyScanned,
            authApi: AuthAPI(),
            achievementApi: AchievementAPI(),
            bookingAPI: BookingAPI()
        )
        return profileVC
    }
}
