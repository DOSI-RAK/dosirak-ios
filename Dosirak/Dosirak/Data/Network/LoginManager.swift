//
//  LoginManager.swift
//  Dosirak
//
//  Created by 권민재 on 10/24/24.
//

import Alamofire
import RxSwift
import KakaoSDKAuth
import RxKakaoSDKUser
import KakaoSDKUser
import UIKit
import NaverThirdPartyLogin

struct LoginResponse: Codable {
    let status: String
    let message: String
    let data: TokenData
    let exception: String?
}

struct TokenData: Codable {
    let accessToken: String
    let refreshToken: String
}

class LoginManager {
    static let shared = LoginManager()
    private let naverLoginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
    private let disposeBag = DisposeBag()
    
    // Kakao 로그인
    func loginWithKakao() -> Observable<String?> {
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            print("Checking if KakaoTalk login is available...")
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.rx.loginWithKakaoTalk()
                    .subscribe(onNext: { oauthToken in
                        print("KakaoTalk login successful. Access Token: \(oauthToken.accessToken)")
                        observer.onNext(oauthToken.accessToken) // 성공 시 accessToken 반환
                        observer.onCompleted()
                    }, onError: { error in
                        print("Kakao Talk login error: \(error.localizedDescription)")
                        observer.onNext(nil)
                        observer.onCompleted()
                    })
                    .disposed(by: self.disposeBag)
            } else {
                print("KakaoTalk login not available. Trying Kakao Account login...")
                UserApi.shared.rx.loginWithKakaoAccount()
                    .subscribe(onNext: { oauthToken in
                        print("Kakao Account login successful. Access Token: \(oauthToken.accessToken)")
                        observer.onNext(oauthToken.accessToken) // 성공 시 accessToken 반환
                        observer.onCompleted()
                    }, onError: { error in
                        print("Kakao Account login error: \(error.localizedDescription)")
                        observer.onNext(nil)
                        observer.onCompleted()
                    })
                    .disposed(by: self.disposeBag)
            }
            return Disposables.create()
        }
    }
    
    // Naver 로그인
    func loginWithNaver() -> Observable<String> {
        return Observable.create { observer in
            self.naverLoginInstance?.requestThirdPartyLogin()
            
            NotificationCenter.default.addObserver(forName: Notification.Name("NaverLoginSuccess"),
                                                   object: nil, queue: .main) { notification in
                if let accessToken = self.naverLoginInstance?.accessToken {
                    observer.onNext(accessToken)
                    observer.onCompleted()
                } else {
                    observer.onError(NSError(domain: "NaverLoginError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get access token"]))
                }
            }
            
            NotificationCenter.default.addObserver(forName: Notification.Name("NaverLoginFailed"),
                                                   object: nil, queue: .main) { notification in
                observer.onError(NSError(domain: "NaverLoginError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Naver login failed"]))
            }
            
            return Disposables.create {
                NotificationCenter.default.removeObserver(self, name: Notification.Name("NaverLoginSuccess"), object: nil)
                NotificationCenter.default.removeObserver(self, name: Notification.Name("NaverLoginFailed"), object: nil)
            }
        }
    }
    
    
    func registerUser(accessToken: String?, nickName: String?) -> Observable<Bool> {
        return Observable.create { observer in
            guard let accessToken = accessToken else {
                let error = NSError(domain: "UserRegistrationError",
                                    code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: "Access token is required."])
                observer.onError(error)
                return Disposables.create()
            }
            
            let url = URL(string: "http://dosirak.store:80/api/user/register")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            // 요청 바디 설정
            let parameters: [String: Any?] = [
                "nickName": nickName ?? nil
            ]
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                request.httpBody = jsonData
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
            
            // URLSession을 통해 요청을 전송
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    observer.onError(error)
                    return
                }
                
                guard let data = data else {
                    let error = NSError(domain: "UserRegistrationError",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "No data received from server."])
                    observer.onError(error)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let registrationResponse = try decoder.decode(LoginResponse.self, from: data)
                    if registrationResponse.status == "SUCCESS" {
                        print("==============?\(registrationResponse.data.accessToken)")
                        observer.onNext(true)
                    } else {
                        observer.onNext(false)
                    }
                    observer.onCompleted()
                } catch {
                    print("Decoding error: \(error)")
                    observer.onError(error)
                }
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    
    
}
