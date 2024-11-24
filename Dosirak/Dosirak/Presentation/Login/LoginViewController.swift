//
//  LoginViewController.swift
//  Dosirak
//
//  Created by 권민재 on 10/17/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class LoginViewController: BaseViewController {

    private let disposeBag = DisposeBag()

    // ViewModel 외부에서 설정 (의존성 주입 없이 초기화)
    private var viewModel: LoginViewModel = LoginViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        bindViewModel()
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

    private func bindViewModel() {
        let input = LoginViewModel.Input(
            tapKakaoLogin: kakaoLoginButton.rx.tap.asObservable(),
            tapNaverLogin: naverLoginButton.rx.tap.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.isLoading
            .drive(onNext: { isLoading in
                print("Loading state: \(isLoading)")
            })
            .disposed(by: disposeBag)

        output.isLoginSuccess
            .drive(onNext: { [weak self] isSuccess in
                guard let self = self else { return }
                if isSuccess {
                    let isNicknameSet = UserDefaults.standard.bool(forKey: "isNickname")
                    if !isNicknameSet {
                        // 닉네임 전송 API 호출
                        self.sendNicknameToServer(nickname: nil)
                            .subscribe(onNext: { result in
                                switch result {
                                case .success:
                                    print("Nickname successfully sent to the server.")
                                    // 닉네임 설정 완료 플래그 업데이트
                                    UserDefaults.standard.set(true, forKey: "isNickname")
                                    self.navigateToHome()
                                case .failure(let error):
                                    print("Failed to send nickname: \(error.localizedDescription)")
                                    self.showErrorMessage()
                                }
                            })
                            .disposed(by: self.disposeBag)
                    } else {
                        // 닉네임이 이미 설정된 경우 바로 홈으로 이동
                        self.navigateToHome()
                    }
                }
            })
            .disposed(by: disposeBag)

        output.errorMessage
            .drive(onNext: { message in
                print("Error: \(message)")
            })
            .disposed(by: disposeBag)
    }
    
    private func sendNicknameToServer(nickname: String?) -> Observable<Result<Void, Error>> {
        return Observable<Result<Void, Error>>.create { observer in
    
            

            // API URL 설정
            guard let url = URL(string: "http://dosirak.store/api/user/nickName") else {
                observer.onNext(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                observer.onCompleted()
                return Disposables.create()
            }

            // HTTP 요청 생성
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Authorization 헤더 추가
            if let token = UserDefaults.standard.string(forKey: "accessToken") {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }

            // 요청 바디에 닉네임 데이터 추가
            let body: [String: Any] = ["nickName": nickname]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

            // URLSession 데이터 작업
            let task = URLSession.shared.dataTask(with: request) { _, response, error in
                // 로딩 상태 종료
                

                if let error = error {
                    observer.onNext(.failure(error)) // 에러 발생
                } else if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    observer.onNext(.success(())) // 성공
                } else {
                    observer.onNext(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected response"])))
                }
                observer.onCompleted()
            }
            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }
    }
    // MARK: - Navigation
    private func navigateToHome() {
        print("Navigating to home screen...")
        // AppCoordinator 없이 직접 홈으로 이동
        let homeVC = HomeViewController()
        let navigationController = UINavigationController(rootViewController: homeVC)
        UIApplication.shared.windows.first?.rootViewController = navigationController
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
