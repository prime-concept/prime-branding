import Foundation

final class CompetitionAssembly: UIViewControllerAssemblyProtocol {
    private var url: String

    init(url: String) {
        self.url = url
    }

    func buildModule() -> UIViewController {
        let controller = CompetitionViewController()
        controller.presenter = CompetitionPresenter(
            view: controller,
            url: url,
            competitionAPI: CompetitionsAPI(),
            favoritesService: FavoritesService(),
            sharingService: SharingService()
        )
        return controller
    }
}
