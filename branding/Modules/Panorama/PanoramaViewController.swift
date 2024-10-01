import UIKit

protocol PanoramaViewProtocol: class {
    func setup(with restaurant: Restaurant)
}

final class PanoramaViewController: UIViewController {
   var presenter: PanoramaPresenterProtocol?

    @IBOutlet private weak var headerView: PanoramaHeaderView!
    @IBOutlet private weak var panoramaView: PanoramaView!
    @IBOutlet private weak var titleLabel: UILabel!

    @IBAction func closeButton(_ sender: Any) {
        dismiss()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.updateView()
    }

    private func dismiss() {
        dismiss(animated: true)
    }
}

extension PanoramaViewController: PanoramaViewProtocol {
    func setup(with restaurant: Restaurant) {
        panoramaView.set(gradientImages: restaurant.panoramaImages)
        titleLabel.text = restaurant.title
        panoramaView.addSubview(headerView)
    }
}
