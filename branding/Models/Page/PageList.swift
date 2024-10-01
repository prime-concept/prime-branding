import Foundation

final class PageList {
    var pages: [Page] = []
    var url = ""
    var mainPage: Page

    init(url: String, pages: [Page], mainPage: Page) {
        self.pages = pages
        self.url = url
        self.mainPage = mainPage
    }
}
