import UIKit

protocol AccountViewProtocol: class {
    func displayModule(assembly: UIViewControllerAssemblyProtocol)
}

final class AccountViewController: UIViewController {
    var presenter: AccountPresenterProtocol?

    var currentChild: UIViewController?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "settings"), for: .normal)
        button.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    private lazy var sharingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "share"), for: .normal)
        button.addTarget(self, action: #selector(openSharing), for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigation()
        presenter?.updateState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.updateState()
        updateButtons(shouldHide: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateButtons(shouldHide: true)
    }

    private func updateButtons(shouldHide: Bool) {
        sharingButton.isHidden = shouldHide
        sharingButton.isEnabled = !shouldHide
        settingsButton.isHidden = shouldHide
        settingsButton.isEnabled = !shouldHide
    }

    private func setUpNavigation() {
        if #available(iOS 11.0, *) {
            setupNavigationItemAsButton()
        } else {
            navigationItem.setRightBarButton(
                UIBarButtonItem(
                    image: #imageLiteral(resourceName: "settings"),
                    style: .plain,
                    target: self,
                    action: #selector(openSettings)
                ),
                animated: false
            )
            navigationItem.setLeftBarButton(
                UIBarButtonItem(
                    image: #imageLiteral(resourceName: "share"),
                    style: .plain,
                    target: self,
                    action: #selector(openSharing)
                ),
                animated: false
            )
        }
    }

    private func setupNavigationItemAsButton() {
        guard let navigationBar = navigationController?.navigationBar else {
            return
        }
        if #available(iOS 11.0, *) {
            navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .always
        }
        navigationBar.addSubview(sharingButton)
        navigationBar.addSubview(settingsButton)
        sharingButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [
                settingsButton.rightAnchor.constraint(
                    equalTo: navigationBar.rightAnchor,
                    constant: -14
                ),
                settingsButton.bottomAnchor.constraint(
                    equalTo: navigationBar.bottomAnchor,
                    constant: -12
                ),
                sharingButton.rightAnchor.constraint(
                    equalTo: settingsButton.leftAnchor,
                    constant: -30
                ),
                sharingButton.bottomAnchor.constraint(
                    equalTo: navigationBar.bottomAnchor,
                    constant: -12
                )
            ]
        )
    }

    func displayChild(viewController childViewController: UIViewController) {
        addChild(childViewController)
        view.addSubview(childViewController.view)
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        childViewController.view.attachEdges(to: self.view)
        childViewController.didMove(toParent: self)
        currentChild?.view.removeFromSuperview()
        currentChild?.removeFromParent()
        currentChild = childViewController
    }

    @objc
    func openSettings() {
        presenter?.openSettings()
    }

    @objc
    func openSharing() {
        presenter?.share()
    }
}

extension AccountViewController: AccountViewProtocol {
    func displayModule(assembly: UIViewControllerAssemblyProtocol) {
        displayChild(viewController: assembly.buildModule())
    }
}
