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

extension String {
    func toFormattedDateString(from inputFormat: String, to outputFormat: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = inputFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // 정확한 날짜 파싱을 위해 설정
        
     
        guard let date = dateFormatter.date(from: self) else { return nil }
        
        
        dateFormatter.dateFormat = outputFormat
        return dateFormatter.string(from: date)
    }
}

class EditProfileViewController: BaseViewController, View {
    var disposeBag = DisposeBag()
    var reactor: UserProfileReactor?
    
    var userProfileData: UserProfileData?
    
    // 의존성 주입을 위한 초기화 메서드
    init(reactor: UserProfileReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        bind(reactor: reactor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            view.endEditing(true)
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "프로필 수정"
        view.backgroundColor = .bgColor
        emailLabel.text = userProfileData?.email
        nameLabel.text = userProfileData?.name
        let dateString = userProfileData?.createdAt
        if let trimmedDateString = dateString?.split(separator: "T").first {
            print(trimmedDateString) 
            dateLabel.text = String(trimmedDateString)
        }
    }
    
    override func setupView() {
        view.addSubview(profileImageView)
        view.addSubview(completeButton)
        view.addSubview(nickNameLabel)
        view.addSubview(nickNameTextField)
        view.addSubview(infoView)
        
        infoView.addSubview(emailLabel)
        infoView.addSubview(emailNameLabel)
        
        infoView.addSubview(nameNameLabel)
        infoView.addSubview(nameLabel)
        
        infoView.addSubview(dateNameLabel)
        infoView.addSubview(dateLabel)
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
            $0.top.equalTo(nickNameLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(nickNameLabel)
            $0.height.equalTo(52)
        }
        
        infoView.snp.makeConstraints {
            $0.top.equalTo(nickNameTextField.snp.bottom).offset(40)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.width.equalTo(353)
            $0.height.equalTo(220)
        }
        emailNameLabel.snp.makeConstraints {
            $0.leading.equalTo(nickNameLabel.snp.leading)
            $0.trailing.equalTo(nickNameLabel.snp.trailing)
            $0.top.equalTo(infoView.snp.top).inset(10)
            
        }
        emailLabel.snp.makeConstraints {
            $0.leading.equalTo(nickNameLabel.snp.leading)
            $0.trailing.equalTo(nickNameLabel.snp.trailing)
            $0.top.equalTo(emailNameLabel.snp.bottom).offset(10)
        }
        nameNameLabel.snp.makeConstraints {
            $0.leading.equalTo(nickNameLabel.snp.leading)
            $0.trailing.equalTo(nickNameLabel.snp.trailing)
            $0.top.equalTo(emailLabel.snp.bottom).offset(20)
            
        }
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(nickNameLabel.snp.leading)
            $0.trailing.equalTo(nickNameLabel.snp.trailing)
            $0.top.equalTo(nameNameLabel.snp.bottom).offset(10)
            
        }
        dateNameLabel.snp.makeConstraints {
            $0.leading.equalTo(nickNameLabel.snp.leading)
            $0.trailing.equalTo(nickNameLabel.snp.trailing)
            $0.top.equalTo(nameLabel.snp.bottom).offset(20)
        }
        dateLabel.snp.makeConstraints {
            $0.leading.equalTo(nickNameLabel.snp.leading)
            $0.trailing.equalTo(nickNameLabel.snp.trailing)
            $0.top.equalTo(dateNameLabel.snp.bottom).offset(10)
            
        }
        
        completeButton.snp.makeConstraints {
            $0.bottom.equalTo(view).inset(50)
            $0.leading.equalTo(20)
            $0.trailing.equalTo(-20)
            $0.height.equalTo(52)
        }
    }
    

    func bind(reactor: UserProfileReactor) {
        completeButton.rx.tap
            .map { Reactor.Action.setNickName(self.nickNameTextField.text ?? "") }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        completeButton.rx.tap
            .map { Reactor.Action.saveNickName }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        completeButton.rx.tap
            .bind(onNext:  {
                let vc = UserProfileViewController()
                vc.userNameLabel.text = self.nickNameTextField.text
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        
      
        
    }

    
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    
    
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
        textField.layer.masksToBounds = true
        return textField
    }()
    
    lazy var completeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .mainColor
        button.setTitle("저장하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        return button
    }()
    
    lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    lazy var emailNameLabel: UILabel = {
        let label = UILabel()
        label.text = "이메일"
        label.textAlignment = .left
        label.textColor = .gray
        return label
    }()
    lazy var nameNameLabel: UILabel = {
        let label = UILabel()
        label.text = "이름"
        label.textAlignment = .left
        label.textColor = .gray
        return label
    }()
    lazy var dateNameLabel: UILabel = {
        let label = UILabel()
        label.text = "가입일자"
        label.textAlignment = .left
        label.textColor = .gray
        return label
    }()
    lazy var emailLabel: UILabel = {
        let label = UILabel()
        //label.text = "dr8766@naver.com"
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        //label.text = "권민재"
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "2024-10-27"
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
}
