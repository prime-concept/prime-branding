import UIKit

fileprivate extension String {
    static let locationAccessErrorTitle = LS.localize("LocationError")
    static let locationAccessErrorMessage = LS.localize("LocationErrorMessage")
    static let locationAccessErrorAllow = LS.localize("Allow")
    static let locationAccessErrorCancel = LS.localize("Cancel")
}

final class LocationErrorAlert {
    static func makeController(
        allowCaseCompletion: @escaping () -> Void
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: .locationAccessErrorTitle,
            message: .locationAccessErrorMessage,
            preferredStyle: .alert
        )

        let allowAction = UIAlertAction(
            title: .locationAccessErrorAllow,
            style: .default
        ) { _ in
            allowCaseCompletion()
        }

        let cancelAction = UIAlertAction(
            title: .locationAccessErrorCancel,
            style: .cancel,
            handler: nil
        )

        alert.addAction(allowAction)
        alert.addAction(cancelAction)

        return alert
    }
}
