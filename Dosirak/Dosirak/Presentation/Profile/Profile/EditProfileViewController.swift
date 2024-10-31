//
//  EditProfileViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/24/24.
//

import UIKit
import SnapKit
import RxSwift
import ReactorKit

class EditProfileViewController: BaseViewController, View {
    var disposeBag = DisposeBag()
    
    // Reactor를 non-optional로 선언하여 View 프로토콜의 요구사항을 만족
    var reactor: UserProfileReactor?
    
    // 의존성 주입을 위한 초기화 메서드
    init(reactor: UserProfileReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        bind(reactor: reactor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "프로필 수정"
        view.backgroundColor = .bgColor
        
    }
    
    override func setupView() {
        view.addSubview(profileImageView)
        view.addSubview(completeButton)
        view.addSubview(nickNameLabel)
        view.addSubview(nickNameTextField)
    }
    
    override func setupLayout() {
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(94)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(40)
            $0.centerX.equalTo(view)
        }
        nickNameLabel.snp.makeConstraints {
            $0.leading.equalTo(view).inset(20)
            $0.trailing.equalTo(view).inset(-20)
            $0.top.equalTo(profileImageView.snp.bottom).offset(40)
        }
        nickNameTextField.snp.makeConstraints {
            $0.top.equalTo(self.nickNameLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(nickNameLabel)
            $0.height.equalTo(52)
        }
        completeButton.snp.makeConstraints {
            $0.bottom.equalTo(view).inset(50)
            $0.leading.equalTo(20)
            $0.trailing.equalTo(-20)
            $0.height.equalTo(52)
        }
    }
    
    func bind(reactor: UserProfileReactor) {
        print("Hello")
        // completeButton 클릭 시 닉네임을 읽어와 saveNickName 액션 전달
        completeButton.rx.tap
                .do(onNext: {
                    print("Complete button tapped") // 버튼 탭 확인 로그
                })
                .map { Reactor.Action.setNickName(self.nickNameTextField.text ?? "") }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
            
            completeButton.rx.tap
                .map { Reactor.Action.saveNickName }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        
        // Reactor의 State 변화 구독하여 닉네임 저장 성공 여부를 UI에 반영
        reactor.state.map { $0.isSaveSuccess }
            .distinctUntilChanged()
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] isSuccess in
                let message = isSuccess ? "닉네임이 성공적으로 저장되었습니다." : "닉네임 저장에 실패했습니다."
                self?.showAlert(message: message)
            })
            .disposed(by: disposeBag)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: UI Elements
    lazy var profileImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "profile"))
        return view
    }()
    
    lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.textAlignment = .left
        label.textColor = .lightGray
        return label
    }()
    
    lazy var nickNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "닉네임을 입력해주세요"
        textField.textAlignment = .left
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 20
        return textField
    }()
    
    lazy var completeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .mainColor
        button.setTitle("저장하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        return button
    }()
}
