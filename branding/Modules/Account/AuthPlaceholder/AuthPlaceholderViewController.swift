import UIKit

enum AuthPlaceholderType {
    case favorites

    var image: UIImage? {
        switch self {
        case .favorites:
            return UIImage(named: "add-to-favorite-placeholder")
        }
    }

    var info: String {
        switch self {
        case .favorites:
            return LS.localize("AuthPlaceholderInfo")
        }
    }

    var title: String {
        switch self {
        case .favorites:
            return LS.localize("AuthPlaceholderTitle")
        }
    }

    var buttonTitle: String {
        switch self {
        default:
            return LS.localize("LogInButton")
        }
    }
}

protocol AuthPlaceholderViewProtocol: class {
    func show(for type: AuthPlaceholderType)
}

final class AuthPlaceholderViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var button: UIButton!

    var presenter: AuthPlaceholderPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupAppearance()
        presenter?.reloadData()
    }

    private func setupAppearance() {
        button.layer.cornerRadius = 25.0

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: LS.localize("Cancel"),
            style: .done,
            target: self,
            action: #selector(cancel)
        )
    }

    @objc
    func cancel() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onButtonTouch(_ button: UIButton) {
        dismiss(animated: true) {
            self.presenter?.finish()
        }

        TabBarRouter(tab: 4).route()
    }
}

extension AuthPlaceholderViewController: AuthPlaceholderViewProtocol {
    func show(for type: AuthPlaceholderType) {
        title = type.title

        button.setTitle(type.buttonTitle, for: .normal)
        imageView.image = type.image
        infoLabel.text = type.info
    }
}
