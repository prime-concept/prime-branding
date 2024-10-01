import Foundation
import YandexMobileAds

protocol AdServiceDelegate: class {
    func adService(_ service: AdService, didLoad ad: YMANativeImageAd)
}
protocol AdServiceProtocol: class {
    var delegate: AdServiceDelegate? { get set }

    func request()
}
// swiftlint:disable implicitly_unwrapped_optional
final class AdService: NSObject, AdServiceProtocol {
    weak var delegate: AdServiceDelegate?

    private lazy var loader: YMANativeAdLoader = {
        let configuration = YMANativeAdLoaderConfiguration(
            blockID: ApplicationConfig.Ad.blockID,
            loadImagesAutomatically: true
        )
        let adLoader = YMANativeAdLoader(configuration: configuration)
        adLoader.delegate = self
        return adLoader
    }()

    func request() {
        let adRequest = YMAAdRequest(
            location: nil,
            contextQuery: nil,
            contextTags: nil,
            parameters: ApplicationConfig.Ad.parameters
        )

        loader.loadAd(with: adRequest)
    }
}

extension AdService: YMANativeAdLoaderDelegate {
    func nativeAdLoader(_ loader: YMANativeAdLoader!, didLoad ad: YMANativeImageAd) {
        delegate?.adService(self, didLoad: ad)
    }

    func nativeAdLoader(_ loader: YMANativeAdLoader!, didFailLoadingWithError error: Error) {
        print("ad service error: error")
    }
}
// swiftlint:enable implicitly_unwrapped_optional
