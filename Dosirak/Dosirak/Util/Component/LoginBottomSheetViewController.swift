//
//  BottomSheetViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/27/24.
//
import UIKit
import PanModal
import SnapKit
import RxSwift
import RxCocoa

class ConfirmAuthViewController: UIViewController, PanModalPresentable {

    // MARK: - PanModal 설정
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(250)
    }
    
    var longFormHeight: PanModalHeight {
        return .contentHeight(250)
    }
    
    var shouldRoundTopCorners: Bool {
        return true
    }
    
    var cornerRadius: CGFloat {
        return 20.0 // 상단 둥글기 조절
    }
    
    var prefersGrabberVisible: Bool {
        return false // 그랩바를 숨김
    }
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .systemRed
        label.textAlignment = .center
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let primaryButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .mainColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let secondaryButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .bgColor
        button.setTitleColor(.darkGray, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let disposeBag = DisposeBag()

    // MARK: - Properties
    private var primaryAction: (() -> Void)?
    private var secondaryAction: (() -> Void)?
    
    // MARK: - Initializer
    init(title: String, message: String, primaryButtonTitle: String, secondaryButtonTitle: String, primaryAction: @escaping () -> Void, secondaryAction: @escaping () -> Void) {
        super.init(nibName: nil, bundle: nil)
        self.titleLabel.text = title
        self.messageLabel.text = message
        self.primaryButton.setTitle(primaryButtonTitle, for: .normal)
        self.secondaryButton.setTitle(secondaryButtonTitle, for: .normal)
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupBindings()
    }
    
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(messageLabel)
        view.addSubview(primaryButton)
        view.addSubview(secondaryButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view).offset(30)
            make.centerX.equalTo(view)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(view).inset(20)
        }
        
        primaryButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(20)
            make.leading.equalTo(view).inset(20)
            make.trailing.equalTo(view).inset(20)
            make.height.equalTo(50)
        }
        
        secondaryButton.snp.makeConstraints { make in
            make.top.equalTo(primaryButton.snp.bottom).offset(10)
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).inset(20)
            make.height.equalTo(50)
        }
    }
    
    private func setupBindings() {
        primaryButton.rx.tap
            .bind { [weak self] in
                self?.primaryAction?()
                self?.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        secondaryButton.rx.tap
            .bind { [weak self] in
                self?.secondaryAction?()
                self?.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }
}
