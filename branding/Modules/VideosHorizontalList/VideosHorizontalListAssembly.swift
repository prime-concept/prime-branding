import Foundation

final class VideosHorizontalListAssembly: UIViewControllerAssemblyProtocol {
    private weak var delegate: YoutubeBlockDelegate?
    private var viewModel: VideosHorizontalListViewModel?

    init(delegate: YoutubeBlockDelegate?, viewModel: VideosHorizontalListViewModel? = nil) {
        self.delegate = delegate
        self.viewModel = viewModel
    }

    func buildModule() -> UIViewController {
        let controller = VideosHorizontalListViewController()
        let presenter = VideosHorizontalListPresenter(view: controller, delegate: self.delegate)
        controller.presenter = presenter
        controller.viewModel = viewModel
        return controller
    }
}
