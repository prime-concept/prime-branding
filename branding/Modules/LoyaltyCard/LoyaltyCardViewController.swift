import Foundation
import SnapKit

protocol LoyaltyCardViewControllerProtocol: class {
    
}

final class LoyaltyCardViewController: UIViewController {
    private lazy var loyaltyView = LoyaltyCardView()

    var presenter: LoyaltyCardPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        title = LS.localize("Loyalty")
        self.makeConstraints()
        self.view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    private func setupUI() {
        self.view.addSubview(self.loyaltyView)
    }
    
    private func makeConstraints() {
        self.loyaltyView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(140)
            make.leading.trailing.equalToSuperview().inset(10)
        }
    }
}

extension LoyaltyCardViewController: LoyaltyCardViewControllerProtocol {
    
}
