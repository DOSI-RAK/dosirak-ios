//
//  LoginViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/17/24.
//

import UIKit
import RxSwift
import SnapKit
import ReactorKit
import RxCocoa

class LoginViewController: BaseViewController {

    private let disposeBag = DisposeBag()
    private let appCoordinator: AppCoordinator
    var reactor: LoginReactor?
    
    
    
    init(reactor: LoginReactor, appCoordinator: AppCoordinator) {
            self.reactor = reactor
            self.appCoordinator = appCoordinator
            super.init(nibName: nil, bundle: nil)
            bind(reactor: reactor)
        }
        
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Home"
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
    
    
      func bind(reactor: LoginReactor) {
          kakaoLoginButton.rx.tap
              .map { LoginReactor.Action.tapKakaoLogin }
              .bind(to: reactor.action)
              .disposed(by: disposeBag)
          
          naverLoginButton.rx.tap
              .map { LoginReactor.Action.tapNaverLogin }
              .bind(to: reactor.action)
              .disposed(by: disposeBag)
          
          reactor.state.map { $0.isLoginSuccess }
              .filter { $0 }
              .take(1)
              .subscribe(onNext: { [weak self] _ in
                  self?.navigateToHome() // 로그인 성공 시 navigateToHome 호출
              })
              .disposed(by: disposeBag)
      }

    // MARK: UI
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
    
    let appleLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "applelogin"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    let kakaoLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "kakaologin"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    let naverLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "naverlogin"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    // 네비게이션 처리
    private func navigateToHome() {
           print("Navigating to home screen...")
           appCoordinator.moveHome(window: UIApplication.shared.windows.first!)
       }

    // 에러 메시지 보여주기
    private func showErrorMessage() {
        let alert = UIAlertController(title: "Error", message: "Login failed. Please try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
