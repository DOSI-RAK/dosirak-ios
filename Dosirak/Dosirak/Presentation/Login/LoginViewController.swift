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
    
    var reactor: LoginReactor?
    
    init(reactor: LoginReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Home"
        setupView() // UI 설정
        setupLayout() // 레이아웃 설정
        bind(reactor: reactor!) // Rx 바인딩
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
        // 버튼 클릭 액션을 Reactor로 전달

        kakaoLoginButton.rx.tap
            .map { LoginReactor.Action.tapKakaoLogin }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        

        // 로딩 상태 처리
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .subscribe(onNext: { isLoading in
                if isLoading {
                    // 로딩 인디케이터 보여주기
                    print("Loading...")
                } else {
                    // 로딩 인디케이터 숨기기
                    print("Loading completed.")
                }
            })
            .disposed(by: disposeBag)

        // 로그인 성공 여부에 따라 처리
        reactor.state.map { $0.isLoginSuccess }
            .distinctUntilChanged()
            .subscribe(onNext: { isLoginSuccess in
                if isLoginSuccess {
                    print("Login Successful")
                    // 로그인 성공 후 처리 (예: 화면 전환)
                    self.navigateToHome()
                } else {
                    // 로그인 실패 시 처리 (예: 에러 메시지)
                    self.showErrorMessage()
                }
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
        // 홈 화면으로의 전환 로직 구현
        print("Navigating to home screen...")
    }

    // 에러 메시지 보여주기
    private func showErrorMessage() {
        let alert = UIAlertController(title: "Error", message: "Login failed. Please try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
