//
//  LoginViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/17/24.
//

import UIKit
import RxSwift
import SnapKit


class LoginViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    override func setupView() {
        view.backgroundColor = .mainColor
        view.addSubview(logoImageView)
        view.addSubview(subtitleLabel)
        view.addSubview(signUpImageView)
        view.addSubview(buttonStackView)
        
    }
    
    
    override func setupLayout() {
        logoImageView.snp.makeConstraints {
            $0.centerX.equalTo(self.view)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(25)
            $0.centerX.equalTo(view)
        }
        
        signUpImageView.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.view)
            $0.top.equalTo(self.view).inset(20)
            $0.bottom.equalTo(self.view)
        }
        buttonStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(105)
            $0.height.equalTo(200)
        }
    }
    
    
    
    
    
    //MARK: UI
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Logo")
        return imageView
    }()
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "다회용기 포장의 첫 걸음."
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    let containerView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    
    let signUpImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Signup")
        return imageView
    }()
    
    
    lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [appleLoginButton, kakaoLoginButton, naverLoginButton])
        stackView.axis = .vertical // 버튼들을 세로로 나열
        stackView.spacing = 5
        stackView.alignment = .fill
        stackView.distribution = .fillEqually // 모든 버튼들이 동일한 크기를 가지게 설정
        return stackView
    }()
    
    let appleLoginButton: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "applelogin")
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        let kakaoLoginButton: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "kakaologin")
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        let naverLoginButton: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "naverlogin")
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
    
}
