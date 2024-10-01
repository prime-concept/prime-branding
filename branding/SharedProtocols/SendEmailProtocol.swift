import Foundation
import MessageUI

protocol SendEmailProtocol {
    func emailController(
        to receiverEmail: String,
        subject: String,
        messageBody: String?
    ) -> MFMailComposeViewController?
}

extension SendEmailProtocol {
    func emailController(
        to receiverEmail: String,
        subject: String,
        messageBody: String?
    ) -> MFMailComposeViewController? {
        if MFMailComposeViewController.canSendMail() {
            let mailViewController = MFMailComposeViewController()
            mailViewController.setToRecipients([receiverEmail])
            mailViewController.setSubject(subject)
            if let message = messageBody {
                mailViewController.setMessageBody(message, isHTML: false)
            }
            return mailViewController
        } else {
            let emailUrlString = "mailto:\(receiverEmail)?subject\(subject)"

            guard
                let encodedEmailUrlString =
                emailUrlString.addingPercentEncoding(
                    withAllowedCharacters: .urlQueryAllowed
                ),
                let emailUrl = URL(string: encodedEmailUrlString)
            else {
                return nil
            }

            if UIApplication.shared.canOpenURL(emailUrl) {
                UIApplication.shared.open(emailUrl, options: [:], completionHandler: nil)
            }
            return nil
        }
    }
}
