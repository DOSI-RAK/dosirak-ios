//
//  EditProfileViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/24/24.
//

import UIKit
import SnapKit

class EditProfileViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "프로필 수정"
        view.backgroundColor = .bgColor
        
        

        // Do any additional setup after loading the view.
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
            $0.top.equalTo(self.nickNameLabel).inset(30)
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
    
    
    //MARK: UI
    lazy var profileImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "profile"))
        return view
    }()
    lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.textAlignment = .left
        label.textColor = .lightGray
        label.backgroundColor = .clear
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
