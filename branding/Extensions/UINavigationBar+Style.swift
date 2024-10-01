import UIKit

extension UINavigationBar {
    func applyBrandingStyle() {
        isTranslucent = false
        backgroundColor = .white
        tintColor = .black
        titleTextAttributes = [
            .font: UIFont.navigationBarFont,
            .foregroundColor: ApplicationConfig.Appearance.navigationBarTextColor
        ]
        setBackgroundImage(UIImage(), for: .default)
        shadowImage = UIImage()

        let barButtonAppearance = UIBarButtonItem.appearance(
            whenContainedInInstancesOf: [UINavigationBar.self]
        )
        barButtonAppearance.setTitleTextAttributes(
            [.font: UIFont.navigationBarFont],
            for: .normal
        )
        barButtonAppearance.setTitleTextAttributes(
            [.font: UIFont.navigationBarFont],
            for: .highlighted
        )
    }

    func applyCollectionStyle() {
        setBackgroundImage(UIImage(), for: .default)
        tintColor = .white
        titleTextAttributes = [
            .font: UIFont.navigationBarFont,
            .foregroundColor: UIColor.white
        ]
        backgroundColor = .clear
    }

    func reset() {
        tintColor = .black
        titleTextAttributes = [
            .font: UIFont.navigationBarFont,
            .foregroundColor: ApplicationConfig.Appearance.navigationBarTextColor
        ]
        setBackgroundImage(UIImage(), for: .default)
        backgroundColor = .white
    }
}
