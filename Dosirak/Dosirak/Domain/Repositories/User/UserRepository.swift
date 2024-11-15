//
//  UserRepository.swift
//  Dosirak
//
//  Created by 권민재 on 10/29/24.
//

import RxSwift
import Moya
import RxMoya
import KeychainAccess

enum LoginType {
    case kakao
    case naver
}

class UserRepository: UserRepositoryType {
   
    
    private let kakaoProvider: KakaoProviderType
    private let naverProvider: NaverProviderType
    private let apiProvider: MoyaProvider<UserAPI>
    private let keychain = Keychain(service: "com.dosirak.user")
    
    private var currentLoginType: LoginType? // 현재 로그인한 소셜 타입을 저장
    
    init(kakaoProvider: KakaoProviderType, naverProvider: NaverProviderType, apiProvider: MoyaProvider<UserAPI>) {
        self.kakaoProvider = kakaoProvider
        self.naverProvider = naverProvider
        self.apiProvider = apiProvider
    }

    func loginWithKakao() -> Observable<String?> {
        return kakaoProvider.login()
            .do(onNext: { [weak self] token in
                print("Kakao login token received: \(String(describing: token))")
                self?.currentLoginType = .kakao // 카카오로 로그인한 경우 타입 설정
            }, onError: { error in
                print("Kakao login error: \(error)")
            })
    }

    func loginWithNaver() -> Observable<String?> {
        return naverProvider.login()
            .do(onNext: { [weak self] token in
                print("Naver login token received: \(String(describing: token))")
                self?.currentLoginType = .naver // 네이버로 로그인한 경우 타입 설정
            }, onError: { error in
                print("Naver login error: \(error)")
            })
    }

    func logout() -> Observable<Bool> {
        guard let loginType = currentLoginType else {
            print("No social login type found.")
            return Observable.just(false)
        }
        
        switch loginType {
        case .kakao:
            return kakaoLogout()
        case .naver:
            return naverLogout()
        }
    }
    
    private func kakaoLogout() -> Observable<Bool> {
        return kakaoProvider.refreshAccessTokenIfNeeded()
            .flatMap { [weak self] refreshedAccessToken -> Observable<Bool> in
                guard let self = self, let accessToken = refreshedAccessToken else {
                    print("Failed to refresh token or no access token available for Kakao.")
                    return Observable.just(false)
                }
                
                // 카카오 로그아웃 후 서버 로그아웃 요청
                return self.kakaoProvider.logout()
                    .flatMap { kakaoLogoutSuccess -> Observable<Bool> in
                        if !kakaoLogoutSuccess {
                            print("Kakao logout failed.")
                            return Observable.just(false)
                        }
                        
                        return self.serverLogout(accessToken: accessToken)
                    }
            }
    }
    
    private func naverLogout() -> Observable<Bool> {
        return naverProvider.logout()
            .flatMap { [weak self] naverLogoutSuccess -> Observable<Bool> in
                guard let self = self else { return Observable.just(false) }
                
                if !naverLogoutSuccess {
                    print("Naver logout failed.")
                    return Observable.just(false)
                }
                
                guard let accessToken = try? self.keychain.get("accessToken") else {
                    print("No access token found for Naver server logout.")
                    return Observable.just(false)
                }
                
                return self.serverLogout(accessToken: accessToken)
            }
    }

    private func serverLogout(accessToken: String) -> Observable<Bool> {
        return apiProvider.rx
            .request(.logout(accessToken: accessToken))
            .filterSuccessfulStatusCodes()
            .flatMap { response -> Single<Bool> in
                let isSuccess = response.statusCode == 200
                return .just(isSuccess) // Bool 값을 Single로 래핑
            }
            .do(onSuccess: { [weak self] success in
                if success {
                    print("Server logout successful. Clearing tokens.")
                    self?.clearTokens()
                } else {
                    print("Server logout failed.")
                }
            })
            .asObservable()
    }
    func registerUser(accessToken: String, nickName: String?) -> Observable<Bool> {
        return apiProvider.rx
            .request(.register(accessToken: accessToken, nickName: nickName))
            .do(onSuccess: { response in
                print("Register user response received, status code: \(response.statusCode)")
            }, onError: { error in
                print("Register user error: \(error)")
            })
            .filterSuccessfulStatusCodes()
            .map(APIResponse<TokenData>.self)
            .do(onSuccess: { [weak self] response in
                print("Register user successful with response: \(response)")
                self?.storeToToken(accessToken: response.data.accessToken, refreshToken: response.data.refreshToken)
            })
            .map { $0.status == "SUCCESS" }
            .asObservable()
    }
    
    func registerNickName(accessToken: String, nickName: String) -> Observable<Bool> {
        return apiProvider.rx
            .request(.registerNickName(accessToken: accessToken, nickName: nickName))
            .do(onSuccess: { response in
                print("Register nickname response received, status code: \(response.statusCode)")
            }, onError: { error in
                print("Register nickname error: \(error)")
            })
            .filterSuccessfulStatusCodes()
            .map(APIResponse<String>.self)
            .do(onSuccess: { response in
                print("Register nickname successful with response: \(response)")
            })
            .map { $0.status == "SUCCESS" }
            .asObservable()
    }
    private func storeToToken(accessToken: String, refreshToken: String) {
            do {
                try keychain.set(accessToken, key: "accessToken")
                try keychain.set(refreshToken, key: "refreshToken")
                print("Tokens stored successfully - AccessToken: \(accessToken), RefreshToken: \(refreshToken)")
            } catch let error {
                print("Error storing tokens in Keychain: \(error)")
            }
        }

    // Keychain에서 AccessToken과 RefreshToken 삭제
    private func clearTokens() {
        do {
            try keychain.remove("accessToken")
            try keychain.remove("refreshToken")
            currentLoginType = nil // 로그아웃 시 로그인 타입 초기화
            print("Tokens cleared from Keychain.")
        } catch let error {
            print("Error clearing tokens from Keychain: \(error)")
        }
    }
}
