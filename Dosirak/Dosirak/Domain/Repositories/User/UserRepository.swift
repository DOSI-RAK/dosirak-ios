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
    }

    func loginWithNaver() -> Observable<String?> {
        return naverProvider.login()
    }

    func registerUser(accessToken: String, nickName: String?) -> Observable<Bool> {
        return apiProvider.rx
            .request(.register(accessToken: accessToken, nickName: nickName))
            .filterSuccessfulStatusCodes()
            .map(LoginResponse.self)
            .do(onSuccess: { [weak self] response in
                self?.storeToToken(accessToken: response.data.accessToken, refreshToken: response.data.refreshToken)
            })
            .map { $0.status == "SUCCESS" }
            .asObservable()
    }
    func registerNickName(accessToken: String, nickName: String) -> Observable<Bool> {
        return apiProvider.rx
            .request(.registerNickName(accessToken: accessToken, nickName: nickName))
            .filterSuccessfulStatusCodes()
            .map(LoginResponse.self)
            .map { $0.status == "SUCCESS" }
            .asObservable()
            
    }
    
    private func storeToToken(accessToken: String, refreshToken: String) {
        do {
            try keychain.set(accessToken, key: "accessToken")
            try keychain.set(refreshToken, key: "refreshToken")
            print("==========>엑세스토큰\(accessToken), 리프레쉬토큰===========>\(refreshToken)")
        } catch let error {
            print("Error storing token in keyChain: \(error)")
        }
    }
}
