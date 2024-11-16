//
//  White.swift
//  Dosirak
//
//  Created by 권민재 on 11/9/24.
//


import UIKit
import RxSwift
import SnapKit
import ReactorKit
import RxCocoa

class WhiteLoginViewController: BaseViewController {

    private let disposeBag = DisposeBag()

    // ViewModel 외부에서 설정 (의존성 주입 없이 초기화)
    private var viewModel: LoginViewModel = LoginViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        setupView()
        setupLayout()
        bindViewModel()
    }

    override func setupView() {
        view.backgroundColor = .white
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

    private func bindViewModel() {
           let input = LoginViewModel.Input(
               tapKakaoLogin: kakaoLoginButton.rx.tap.asObservable(),
               tapNaverLogin: naverLoginButton.rx.tap.asObservable()
           )

           let output = viewModel.transform(input: input)

           output.isLoading
               .drive(onNext: { isLoading in
                   print("Loading state: \(isLoading)") // 로딩 상태를 콘솔에 출력
               })
               .disposed(by: disposeBag)

           output.isLoginSuccess
               .drive(onNext: { [weak self] isSuccess in
                   if isSuccess {
                       self?.navigateToHome()
                   }
               })
               .disposed(by: disposeBag)

           output.errorMessage
               .drive(onNext: { message in
                   print("Error: \(message)") // 에러 메시지를 콘솔에 출력
               })
               .disposed(by: disposeBag)
       }

    // MARK: - Navigation
    private func navigateToHome() {
        let tabBarController = TabbarViewController()
        let tabBarCoordinator = TabBarCoordinator(tabBarController: tabBarController)
        tabBarCoordinator.start()
        UIApplication.shared.windows.first?.rootViewController = tabBarController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }

    // MARK: - Error Handling
    private func showErrorMessage() {
        let alert = UIAlertController(title: "Error", message: "Login failed. Please try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - UI Components
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logomint")
        return imageView
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "다회용기 포장의 첫 걸음."
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    let signUpImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "whitebg")
        return imageView
    }()
    
    lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [appleLoginButton, kakaoLoginButton, naverLoginButton])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    let appleLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "apple"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    let kakaoLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "kakao"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    let naverLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "naver"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
}
