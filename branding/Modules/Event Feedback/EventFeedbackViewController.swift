import Foundation
import SnapKit

protocol EventFeedbackViewControllerProtocol: class {
    func set(viewModel: [StarViewModel])
    func setupInfo(info: EventFeedbackInfo)
    func showGratitudeView()
}

final class EventFeedbackViewController: UIViewController {
    var presenter: EventFeedbackPresenterProtocol?

    var viewModel: [StarViewModel] = []
    private lazy var feedbackView = UIView()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.numberOfLines = 0
        label.text = LS.localize("EventAlertTitle")
        label.textAlignment = .center
        label.textColor = .gray
        return label
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGrayColor
        return view
    }()
    
    private lazy var timeLabel: UILabel  = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private lazy var eventLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private lazy var feedbackTextField: UITextField = {
        var textfield = UITextField()
        textfield.clipsToBounds = true
        textfield.backgroundColor = .tagsBackgroundColor
        textfield.layer.cornerRadius = 10
        textfield.placeholder = LS.localize("ShareImpressions")
        textfield.delegate = self
        return textfield
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .tagsBackgroundColor
        button.setTitleColor(.mfBlueColor, for: .normal)
        button.setTitle(LS.localize("CloseAlert"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        return button
    }()
    
    private lazy var applyButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.backgroundColor = .mfBlueColor
        button.setTitle(LS.localize("ApplyAlert"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(apply), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var starsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 7
        layout.itemSize = .init(width: 48, height: 65)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.register(cellClass: StarCollectionViewCell.self)
        return collectionView
    }()
    
    private lazy var gratitudeView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isHidden = true
        return view
    }()
    
    private lazy var gratitudeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "gratitude_icon")
        return imageView
    }()
    
    private lazy var gratitudeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 2
        label.text = LS.localize("EventGratitudeTitle")
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupConstraints()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter?.viewWillAppear()
    }
   
    private func setupView() {
        [
            self.titleLabel,
            self.separatorView,
            self.titleLabel,
            self.timeLabel,
            self.eventLabel,
            self.starsCollectionView,
            self.feedbackTextField,
            self.applyButton,
            self.closeButton
        ].forEach(self.feedbackView.addSubview)
        [
            self.gratitudeImageView,
            self.gratitudeLabel
        ].forEach(self.gratitudeView.addSubview)
        self.feedbackView.addSubview(self.gratitudeView)
        [
            self.feedbackView
        ].forEach(self.view.addSubview)

        self.feedbackView.layer.cornerRadius = 10
        self.feedbackView.backgroundColor = .white
        self.gratitudeView.layer.cornerRadius = 10
        self.view.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.9)
        self.feedbackTextField.setLeftPaddingPoints(15)
    }
    
    private func setupConstraints() {
        self.feedbackView.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.width.equalTo(300)
        }

        self.separatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(18)
        }
        
        self.timeLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(separatorView.snp.bottom).offset(24)
        }
        
        self.eventLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(timeLabel.snp.bottom).offset(2)
        }
        
        self.starsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(eventLabel.snp.bottom).offset(20)
            make.size.equalTo(CGSize(width: 280, height: 65))
            make.centerX.equalToSuperview()
        }
        
        self.feedbackTextField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(starsCollectionView.snp.bottom).offset(20)
            make.height.equalTo(52)
        }
        
        self.closeButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
            make.top.equalTo(feedbackTextField.snp.bottom).offset(15)
            make.bottom.equalToSuperview().inset(15)
        }
        
        self.gratitudeView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalTo(closeButton.snp.top)
        }
        
        self.gratitudeImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(80)
            make.size.equalTo(CGSize(width: 85, height: 95))
            make.centerX.equalToSuperview()
        }
        
        self.gratitudeLabel.snp.makeConstraints { make in
            make.top.equalTo(gratitudeImageView.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    private func addApplyButton() {
        self.applyButton.isHidden = false
        self.applyButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
            make.top.equalTo(feedbackTextField.snp.bottom).offset(15)
        }
        self.closeButton.snp.remakeConstraints { make in
            make.top.equalTo(applyButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().inset(15)
        }
    }
    
    func updateViewModel(index: Int) {
        self.viewModel.indices.forEach {
            self.viewModel[$0].isSelected = ($0 <= index)
        }
        self.starsCollectionView.reloadData()
    }
    
    @objc
    func close() {
        let mainPageRouter = TabBarRouter(tab: 0)
        mainPageRouter.route()
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func apply() {
        self.presenter?.sendFeedback()
    }
}

extension EventFeedbackViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: StarCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.setup(with: self.viewModel[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.applyButton.isHidden {
            self.addApplyButton()
        }
        self.presenter?.updateViewModel(index: indexPath.row)
    }
}

extension EventFeedbackViewController: EventFeedbackViewControllerProtocol {
    func setupInfo(info: EventFeedbackInfo) {
        self.timeLabel.text = info.timeSlot
        self.eventLabel.text = info.title
    }
    
    func set(viewModel: [StarViewModel]) {
        self.viewModel = viewModel
        self.starsCollectionView.reloadData()
    }
    
    func showGratitudeView() {
        self.gratitudeView.isHidden = false
    }
}

extension EventFeedbackViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.presenter?.updateFeedback(feedback: textField.text ?? "")
        return true
    }
}
