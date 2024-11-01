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

class UserRepository: UserRepositoryType {
    private let kakaoProvider: KakaoProviderType
    private let naverProvider: NaverProviderType
    private let apiProvider: MoyaProvider<UserAPI>
    
    private let keychain = Keychain(service: "com.dosirak.user")

    init(kakaoProvider: KakaoProviderType, naverProvider: NaverProviderType, apiProvider: MoyaProvider<UserAPI>) {
        self.kakaoProvider = kakaoProvider
        self.naverProvider = naverProvider
        self.apiProvider = apiProvider
    }

    func loginWithKakao() -> Observable<String?> {
        return kakaoProvider.login()
            .do(onNext: { token in
                print("Kakao login token received: \(String(describing: token))")
            }, onError: { error in
                print("Kakao login error: \(error)")
            })
    }

    func loginWithNaver() -> Observable<String?> {
        return naverProvider.login()
            .do(onNext: { token in
                print("Naver login token received: \(String(describing: token))")
            }, onError: { error in
                print("Naver login error: \(error)")
            })
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
            .map(LoginResponse.self)
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
            .map(LoginResponse.self)
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
}
