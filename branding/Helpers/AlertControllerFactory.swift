import UIKit

enum AlertContollerFactory {
    static func makeDestructionAlert(
        with message: String,
        destructTitle: String,
        destruct:  @escaping () -> Void,
        cancelTitle: String = LS.localize("Cancel"),
        cancel: (() -> Void)? = nil
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        let descructAction = UIAlertAction(title: destructTitle, style: .destructive, handler: { _ in
            destruct()
        })
        alert.addAction(descructAction)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: { _ in
            cancel?()
        })
        alert.addAction(cancelAction)
        return alert
    }
}

