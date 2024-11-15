//
//  NaverProvider.swift
//  Dosirak
//
//  Created by 권민재 on 10/29/24.
//

import RxSwift
import NaverThirdPartyLogin

protocol NaverProviderType {
    func login() -> Observable<String?>
    func logout() -> Observable<Bool>
}

class NaverProvider: NaverProviderType {
    private let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()

    func login() -> Observable<String?> {
        return Observable.create { observer in
            self.loginInstance?.requestThirdPartyLogin()
            
            // Success Notification Observer
            let successObserver = NotificationCenter.default.addObserver(forName: Notification.Name("NaverLoginSuccess"), object: nil, queue: .main) { _ in
                if let accessToken = self.loginInstance?.accessToken {
                    observer.onNext(accessToken)
                    observer.onCompleted()
                } else {
                    observer.onError(NSError(domain: "NaverLoginError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get access token"]))
                }
            }
            
            // Failure Notification Observer
            let failureObserver = NotificationCenter.default.addObserver(forName: Notification.Name("NaverLoginFailed"), object: nil, queue: .main) { _ in
                observer.onError(NSError(domain: "NaverLoginError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Naver login failed"]))
            }
            
            // Dispose logic to remove observers
            return Disposables.create {
                NotificationCenter.default.removeObserver(successObserver)
                NotificationCenter.default.removeObserver(failureObserver)
            }
        }
    }

    func logout() -> Observable<Bool> {
        return Observable.create { observer in
            self.loginInstance?.requestDeleteToken()
            
            // Success Notification Observer for logout
            let successObserver = NotificationCenter.default.addObserver(forName: Notification.Name("NaverLogoutSuccess"), object: nil, queue: .main) { _ in
                observer.onNext(true)
                observer.onCompleted()
            }
            
            // Failure Notification Observer for logout
            let failureObserver = NotificationCenter.default.addObserver(forName: Notification.Name("NaverLogoutFailed"), object: nil, queue: .main) { _ in
                observer.onError(NSError(domain: "NaverLogoutError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Naver logout failed"]))
            }
            
            // Dispose logic to remove observers for logout
            return Disposables.create {
                NotificationCenter.default.removeObserver(successObserver)
                NotificationCenter.default.removeObserver(failureObserver)
            }
        }
    }
}
