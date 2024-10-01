import Branch
import Foundation

protocol SharingServiceProtocol {
    func share(object: DeepLinkRoute)
}

class SharingService: SharingServiceProtocol {
    func share(object: DeepLinkRoute) {
        object.buo.showShareSheet(
            with: object.linkProperties,
            andShareText: ApplicationConfig.StringConstants.mainTitle,
            from: nil,
            completion: nil
        )
    }
}
