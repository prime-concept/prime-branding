import Alamofire
import Foundation

class APIEndpoint {
    let manager: Alamofire.SessionManager

    var contentLanguage: String {
        return ApplicationConfig.contentLanguage.apiCode
    }

    var paramsWithContentLanguage: Parameters {
        return ["language": contentLanguage]
    }

    var retrieve: RetrieveRequestMaker
    var create: CreateRequestMaker
    var update: UpdateRequestMaker
    var delete: DeleteRequestMaker
    var download: DownloadRequestMaker

    var providesAuthorizationHeader: Bool
    
    init(
        providesAuthorizationHeader: Bool = true
    ) {
        //These dependencies can be easily moved out, not doing
        //this because this overcomplication is not needed yet
        self.providesAuthorizationHeader = providesAuthorizationHeader
        
        manager = Alamofire.SessionManager(
            configuration: BrandingURLSessionConfiguration.default
        )
        manager.retrier = APIRequestRetrier()
        manager.adapter = APIRequestAdapter(providesAuthorizationHeader: self.providesAuthorizationHeader)
        retrieve = RetrieveRequestMaker()
        create = CreateRequestMaker()
        update = UpdateRequestMaker()
        delete = DeleteRequestMaker()
        download = DownloadRequestMaker()
    }
}
