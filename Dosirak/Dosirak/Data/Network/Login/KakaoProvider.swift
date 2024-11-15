//
//  KakaoProvider.swift
//  Dosirak
//
//  Created by 권민재 on 10/29/24.
//

import RxSwift
import KakaoSDKAuth
import KakaoSDKUser
import KeychainAccess
import RxMoya
import RxKakaoSDKAuth
import RxKakaoSDKUser

protocol KakaoProviderType {
    func login() -> Observable<String?>
    func logout() -> Observable<Bool>
    func withdraw() -> Observable<Void>
    func refreshAccessTokenIfNeeded() -> Observable<String?>
}

class KakaoProvider: KakaoProviderType {
    private let keychain = Keychain(service: "com.dosirak.user")
    
    func login() -> Observable<String?> {
        return Observable.create { observer in
            let loginObservable: Observable<OAuthToken>
            
            if UserApi.isKakaoTalkLoginAvailable() {
                loginObservable = UserApi.shared.rx.loginWithKakaoTalk()
            } else {
                loginObservable = UserApi.shared.rx.loginWithKakaoAccount()
            }
            
            loginObservable
                .subscribe(onNext: { [weak self] oauthToken in
                    guard let self = self else { return }
                    
                    // 토큰 저장
                    self.storeTokens(accessToken: oauthToken.accessToken, refreshToken: oauthToken.refreshToken)
                    
                    observer.onNext(oauthToken.accessToken)
                    observer.onCompleted()
                }, onError: { error in
                    print("Kakao login error: \(error)")
                    observer.onNext(nil)
                    observer.onCompleted()
                })
            
            return Disposables.create()
        }
    }
    
    func logout() -> Observable<Bool> {
        return Observable.create { observer in
            UserApi.shared.logout { error in
                if let error = error {
                    print("Kakao logout failed: \(error)")
                    observer.onError(error)
                } else {
                    print("Kakao logout successful.")
                    observer.onNext(true)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    func withdraw() -> Observable<Void> {
        return Observable.create { observer in
            UserApi.shared.unlink { error in
                if let error = error {
                    print("Kakao unlink (withdraw) failed: \(error)")
                    observer.onError(error)
                } else {
                    print("Kakao unlink (withdraw) successful.")
                    self.clearTokens()
                    observer.onNext(())
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    func refreshAccessTokenIfNeeded() -> Observable<String?> {
        return Observable.create { observer in
            if AuthApi.hasToken() {
                AuthApi.shared.refreshToken { [weak self] (oauthToken, error) in
                    if let error = error {
                        print("Token refresh failed: \(error)")
                        observer.onNext(nil)
                        observer.onCompleted()
                    } else if let oauthToken = oauthToken {
                        print("Token refreshed successfully.")
                        self?.storeTokens(accessToken: oauthToken.accessToken, refreshToken: oauthToken.refreshToken)
                        observer.onNext(oauthToken.accessToken)
                        observer.onCompleted()
                    }
                }
            } else {
                print("No token available to refresh.")
                observer.onNext(nil)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    // Keychain에 AccessToken과 RefreshToken 저장
    private func storeTokens(accessToken: String, refreshToken: String?) {
        do {
            try keychain.set(accessToken, key: "socialAccessToken")
            print("AccessToken 저장 완료")
            
            if let refreshToken = refreshToken {
                try keychain.set(refreshToken, key: "socialRefreshToken")
                print("RefreshToken 저장 완료")
            }
        } catch let error {
            print("Keychain 저장 에러: \(error)")
        }
    }
    
    // Keychain에서 AccessToken과 RefreshToken 삭제
    private func clearTokens() {
        do {
            try keychain.remove("socialAccessToken")
            try keychain.remove("socialRefreshToken")
            print("Tokens cleared from Keychain.")
        } catch let error {
            print("Error clearing tokens from Keychain: \(error)")
        }
    }
}
