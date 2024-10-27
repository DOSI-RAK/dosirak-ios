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
                
                // JSON 디코딩
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

    
    // 사용자 등록
//    func registerUser(accessToken: String?, nickName: String?) -> Observable<Bool> {
//        return Observable.create { observer in
//            guard let accessToken = accessToken else {
//                let error = NSError(domain: "UserRegistrationError",
//                                    code: -1,
//                                    userInfo: [NSLocalizedDescriptionKey: "Access token is required."])
//                observer.onError(error)
//                return Disposables.create()
//            }
//
//            let url = "http://dosirak.store/api/user/register"
//            var parameters: [String: Any] = [:]
//            parameters["nickName"] = nickName ?? NSNull() // nil일 경우 NSNull 사용
//
//            let headers: HTTPHeaders = [
//                
//                "Authorization": "Bearer \(accessToken)"
//            ]
//
//            AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
//                .responseData { response in
//                    switch response.result {
//                    case .success(let data):
//                        do {
//                            let decoder = JSONDecoder()
//                            let registrationResponse = try decoder.decode(UserRegistrationResponse.self, from: data)
//                            if registrationResponse.status == "SUCCESS" {
//                                observer.onNext(true)
//                            } else {
//                                observer.onNext(false)
//                            }
//                            observer.onCompleted()
//                        } catch {
//                            print("Decoding error: \(error)")
//                            observer.onError(error)
//                        }
//                    case .failure(let error):
//                        print("Network error: \(error.localizedDescription)")
//                        observer.onError(error)
//                    }
//                }
//
//            return Disposables.create()
//        }
//    }
    
    // 토큰 유효성 검사
    func validateToken(accessToken: String?) -> Observable<Bool> {
        return Observable.create { observer in
            guard let accessToken = accessToken else {
                let error = NSError(domain: "TokenValidationError",
                                    code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: "Access token is required for validation."])
                observer.onError(error)
                return Disposables.create()
            }

            let url = "http://dosirak.store/api/valid-token"
            let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]

            AF.request(url, method: .get, headers: headers)
                .response { response in
                    if let statusCode = response.response?.statusCode {
                        print("Status Code: \(statusCode)")
                        if statusCode == 200 {
                            observer.onNext(true) // 토큰이 유효함
                        } else {
                            observer.onNext(false) // 토큰이 유효하지 않음
                        }
                    } else {
                        observer.onError(NSError(domain: "TokenValidationError",
                                                 code: -1,
                                                 userInfo: [NSLocalizedDescriptionKey: "Failed to validate token."]))
                    }
                }

            return Disposables.create()
        }
    }
    
    // 토큰 재발급
    func reissueAccessToken(refreshToken: String) -> Observable<String?> {
        return Observable.create { observer in
            let url = "http://dosirak.store/api/token/reissue/access-token"
            let parameters: [String: Any] = [
                "refreshToken": refreshToken
            ]
            let headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]

            AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            // JSON 디코딩 예제. 실제 응답에 맞게 수정 필요
                            let responseString = String(data: data, encoding: .utf8)
                            print("Response: \(responseString ?? "")")
                            // 이곳에서 토큰 재발급에 성공한 경우 적절한 로직 추가 필요
                            // 예를 들어, 새로운 access token 반환
                            observer.onNext(nil) // 여기에 새로운 access token을 넣어 반환
                        } catch {
                            observer.onError(error)
                        }
                    case .failure(let error):
                        print("Network error: \(error.localizedDescription)")
                        observer.onError(error)
                    }
                }

            return Disposables.create()
        }
    }
}
 


//class LoginManager {
//    static let shared = LoginManager()
//    private let disposeBag = DisposeBag()
//    
//    // Kakao 로그인
//    func loginWithKakao() -> Observable<Void> {
//        return Observable.create { observer in
//            print("Kakao 로그인 시작...")
//            
//            if UserApi.isKakaoTalkLoginAvailable() {
//                UserApi.shared.rx.loginWithKakaoTalk()
//                    .subscribe(onNext: { oauthToken in
//                        print("KakaoTalk 로그인 성공: \(oauthToken.accessToken)")
//                        observer.onNext(()) // 로그인 성공 시 Void 반환
//                        observer.onCompleted()
//                    }, onError: { error in
//                        print("KakaoTalk 로그인 오류: \(error.localizedDescription)")
//                        observer.onError(error)
//                    })
//                    .disposed(by: self.disposeBag)
//            } else {
//                UserApi.shared.rx.loginWithKakaoAccount()
//                    .subscribe(onNext: { oauthToken in
//                        print("Kakao 계정 로그인 성공: \(oauthToken.accessToken)")
//                        observer.onNext(()) // 로그인 성공 시 Void 반환
//                        observer.onCompleted()
//                    }, onError: { error in
//                        print("Kakao 계정 로그인 오류: \(error.localizedDescription)")
//                        observer.onError(error)
//                    })
//                    .disposed(by: self.disposeBag)
//            }
//            return Disposables.create()
//        }
//    }
//}
