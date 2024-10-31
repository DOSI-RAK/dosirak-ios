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
}

class NaverProvider: NaverProviderType {
    private let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()

    func login() -> Observable<String?> {
        return Observable.create { observer in
            self.loginInstance?.requestThirdPartyLogin()
            
            NotificationCenter.default.addObserver(forName: Notification.Name("NaverLoginSuccess"), object: nil, queue: .main) { _ in
                if let accessToken = self.loginInstance?.accessToken {
                    observer.onNext(accessToken)
                    observer.onCompleted()
                } else {
                    observer.onError(NSError(domain: "NaverLoginError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get access token"]))
                }
            }
            
            NotificationCenter.default.addObserver(forName: Notification.Name("NaverLoginFailed"), object: nil, queue: .main) { _ in
                observer.onError(NSError(domain: "NaverLoginError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Naver login failed"]))
            }
            
            return Disposables.create {
                NotificationCenter.default.removeObserver(self)
            }
        }
    }
}
