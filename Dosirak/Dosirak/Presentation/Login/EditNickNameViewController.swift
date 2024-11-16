//
//  EditNickNameViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/16/24.
//

import UIKit
import SnapKit
import RxSwift

class EditNickNameViewController: BaseViewController {
    
    private let viewModel = EditNicknameViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "닉네임 설정"
        view.backgroundColor = .bgColor

        // Do any additional setup after loading the view.
    }
    
    override func setupView() {
        view.addSubview(titleLabel)
        view.addSubview(nickNameTextField)
        view.addSubview(validationLabel)
        view.addSubview(saveButton)
    }
    
    override func setupLayout() {
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(40)
            $0.leading.equalToSuperview().inset(20)
        }
        nickNameTextField.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(53)
        }
        
        saveButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(53)
        }
    }
    
    override func bindRX() {
        nickNameTextField.rx.text
            .orEmpty
            .bind(to: viewModel.nicknameInput)
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .bind(to: viewModel.submitTapped)
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                print("Save button tapped")
                self?.navigateToUserInfoSetting() // 바로 UserInfoSettingViewController로 이동
            })
            .disposed(by: disposeBag)

        viewModel.nicknameValidationMessage
            .bind(to: validationLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.isSaveButtonEnabled
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.successMessage
            .subscribe(onNext: { message in
                print("Success: \(message)")
            })
            .disposed(by: disposeBag)

        viewModel.errorMessage
            .subscribe(onNext: { error in
                print("Error: \(error)")
            })
            .disposed(by: disposeBag)
    }
    private func navigateToUserInfoSetting() {
        let userInfoVC = UserInfoSettingViewController()
        navigationController?.pushViewController(userInfoVC, animated: true)
    }
    

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        return label
    }()
    
    let nickNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "친환경물범"
        textField.backgroundColor = .white
        return textField
    }()
    
    let validationLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("계정 생성하기", for: .normal)
        button.backgroundColor = .mainColor
        button.layer.cornerRadius = 13
        return button
    }()

}
