//
//  LoginReactor.swift
//  Dosirak
//
//  Created by 권민재 on 10/17/24.
//

import RxSwift
import RxCocoa
import Moya

class LoginViewModel {
    // MARK: - Input/Output
    struct Input {
        let tapKakaoLogin: Observable<Void>
        let tapNaverLogin: Observable<Void>
        
    }

    struct Output {
        let isLoading: Driver<Bool>
        let isLoginSuccess: Driver<Bool>
        let isLogoutSuccess: Driver<Bool>
        let errorMessage: Driver<String>
    }

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let apiProvider = MoyaProvider<UserAPI>()
    private let kakaoProvider = KakaoProvider() // 기본 의존성 설정
    private let naverProvider = NaverProvider() // 기본 의존성 설정

    private let isLoadingSubject = BehaviorSubject<Bool>(value: false)
    private let isLoginSuccessSubject = PublishSubject<Bool>()
    private let isLogoutSuccessSubject = PublishSubject<Bool>()
    private let errorMessageSubject = PublishSubject<String>()
    private var currentLoginType: LoginType?

    // MARK: - Init
    init() {}

    // MARK: - Transform
    func transform(input: Input) -> Output {
        input.tapKakaoLogin
            .flatMapLatest { [weak self] in
                self?.performKakaoLogin() ?? .empty()
            }
            .bind(to: isLoginSuccessSubject)
            .disposed(by: disposeBag)

        input.tapNaverLogin
            .flatMapLatest { [weak self] in
                self?.performNaverLogin() ?? .empty()
            }
            .bind(to: isLoginSuccessSubject)
            .disposed(by: disposeBag)


        return Output(
            isLoading: isLoadingSubject.asDriver(onErrorJustReturn: false),
            isLoginSuccess: isLoginSuccessSubject.asDriver(onErrorJustReturn: false),
            isLogoutSuccess: isLogoutSuccessSubject.asDriver(onErrorJustReturn: false),
            errorMessage: errorMessageSubject.asDriver(onErrorJustReturn: "")
        )
    }

    // MARK: - Login/Logout Methods
    private func performKakaoLogin() -> Observable<Bool> {
        isLoadingSubject.onNext(true)
        return kakaoProvider.login()
            .flatMap { [weak self] token -> Observable<Bool> in
                guard let self = self else { return .just(false) }
                self.currentLoginType = .kakao
                return self.registerUser(accessToken: token ?? "")
            }
            .do(onNext: { [weak self] success in
                self?.isLoadingSubject.onNext(false)
                if !success {
                    self?.errorMessageSubject.onNext("Kakao login failed")
                }
            }, onError: { [weak self] error in
                self?.isLoadingSubject.onNext(false)
                self?.errorMessageSubject.onNext("Kakao login error: \(error.localizedDescription)")
            })
    }

    private func performNaverLogin() -> Observable<Bool> {
        isLoadingSubject.onNext(true)
        return naverProvider.login()
            .flatMap { [weak self] token -> Observable<Bool> in
                guard let self = self else { return .just(false) }
                self.currentLoginType = .naver
                return self.registerUser(accessToken: token ?? "")
            }
            .do(onNext: { [weak self] success in
                self?.isLoadingSubject.onNext(false)
                if !success {
                    self?.errorMessageSubject.onNext("Naver login failed")
                }
            }, onError: { [weak self] error in
                self?.isLoadingSubject.onNext(false)
                self?.errorMessageSubject.onNext("Naver login error: \(error.localizedDescription)")
            })
    }

    private func performLogout() -> Observable<Bool> {
        guard let loginType = currentLoginType else {
            errorMessageSubject.onNext("No social login type found")
            return .just(false)
        }

        switch loginType {
        case .kakao:
            return kakaoProvider.logout()
                .do(onNext: { [weak self] success in
                    if success {
                        self?.clearTokens()
                    } else {
                        self?.errorMessageSubject.onNext("Kakao logout failed")
                    }
                })
        case .naver:
            return naverProvider.logout()
                .do(onNext: { [weak self] success in
                    if success {
                        self?.clearTokens()
                    } else {
                        self?.errorMessageSubject.onNext("Naver logout failed")
                    }
                })
        }
    }

    private func registerUser(accessToken: String) -> Observable<Bool> {
        return apiProvider.rx
            .request(.register(accessToken: accessToken, nickName: nil))
            .filterSuccessfulStatusCodes()
            .map(APIResponse<TokenData>.self)
            .map { response in
                AppSettings.accessToken = response.data.accessToken
                AppSettings.refreshToken = response.data.refreshToken
                return true
            }
            .catchAndReturn(false)
            .asObservable()
    }

    private func clearTokens() {
        currentLoginType = nil
        print("Tokens cleared")
    }
}
