import UIKit

class FirstTintSpinnerView: SpinnerView {
    private let appearanceStorage = Appearance(
        lineWidthRatio: 0.12,
        colorSpinner: ApplicationConfig.Appearance.firstTintColor,
        colorBackground: UIColor(white: 0.95, alpha: 1)
    )

    override var appearance: SpinnerView.Appearance {
        get {
            return appearanceStorage
        } set { }
    }
}
