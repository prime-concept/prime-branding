import UIKit

class BaseEmailAuthViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomCostraint: NSLayoutConstraint?

    var tableModels: [EmailLoginViewModel] {
        return []
    }
    var values = [String]()
    var errors = [String?]()

    init() {
        super.init(nibName: "BaseEmailAuthViewController", bundle: .main)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupValues()
        setupErrors()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onKeyboardToggle),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onKeyboardToggle),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc
    private func onKeyboardToggle(notification: Notification) {
        let keyboardInfo = notification.userInfo

        let optionalDuration = keyboardInfo?[
            UIResponder.keyboardAnimationDurationUserInfoKey
        ] as? TimeInterval

        let optionalKeyboardFrame = keyboardInfo?[
            UIResponder.keyboardFrameEndUserInfoKey
        ] as? CGRect

        guard let duration = optionalDuration,
            let keyboardFrame = optionalKeyboardFrame
        else {
            return
        }

        let isShowing = (notification.name == UIResponder.keyboardWillShowNotification)

        UIView.animate(withDuration: duration) {
            if isShowing {
                var bottomInset: CGFloat = 0
                if #available(iOS 11.0, *) {
                    bottomInset = self.view.safeAreaInsets.bottom
                }
                self.bottomCostraint?.constant = keyboardFrame.size.height - bottomInset
            } else {
                self.bottomCostraint?.constant = 0
            }
            self.view.layoutIfNeeded()
        }
    }

    func setupTableView() {
        tableView.register(cellClass: LogoTableViewCell.self)
        tableView.register(cellClass: InputTableViewCell.self)

        tableView.delegate = self
        tableView.dataSource = self
    }

    private func setupValues() {
        values = tableModels.map {
            switch $0 {
            case .email(let value),
                 .password(let value),
                 .name(let value):
                return value
            default:
                return ""
            }
        }
    }

    private func setupErrors() {
        errors = tableModels.map {_ in
            nil
        }
    }

    func getEditedRowViewModels() -> [EmailLoginViewModel] {
        return tableModels.enumerated().map {
            switch $0.element {
            case .logo:
                return .logo
            case .email:
                return .email(values[$0.offset])
            case .password:
                return .password(values[$0.offset])
            case .name:
                return .name(values[$0.offset])
            case .privacyPolicy:
                return .privacyPolicy
            case .loginButtons:
                return .loginButtons
            case .actionButton:
                return .actionButton
            }
        }
    }

    func show(error: String, for row: Int) {
        //  we use CATransactionBlock to reset errors only after table view will finish reloading
        setupErrors()
        errors[row] = error
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            self?.setupErrors()
        }
        tableView.reloadData()
        CATransaction.commit()
    }

    func dismiss() {
        navigationController?.popViewController(animated: true)
    }

    func set(validationErrors: [String?]) {
        self.errors = validationErrors
        tableView.reloadData()
    }
}

extension BaseEmailAuthViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return tableModels.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        preconditionFailure("Should be overriden in subclasses")
    }
}

extension BaseEmailAuthViewController: UITableViewDelegate {
}
