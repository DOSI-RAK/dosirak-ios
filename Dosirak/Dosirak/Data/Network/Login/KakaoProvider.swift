//
//  KakaoProvider.swift
//  Dosirak
//
//  Created by 권민재 on 10/29/24.
//

import RxSwift
import KakaoSDKAuth
import RxKakaoSDKUser
import KakaoSDKUser

protocol KakaoProviderType {
    func login() -> Observable<String?>
}

class KakaoProvider: KakaoProviderType {
    func login() -> Observable<String?> {
        return Observable.create { observer in
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.rx.loginWithKakaoTalk()
                    .subscribe(onNext: { oauthToken in
                        
                        observer.onNext(oauthToken.accessToken)
                        observer.onCompleted()
                    }, onError: { error in
                        observer.onNext(nil)
                        observer.onCompleted()
                    })
            } else {
                UserApi.shared.rx.loginWithKakaoAccount()
                    .subscribe(onNext: { oauthToken in
                        observer.onNext(oauthToken.accessToken)
                        observer.onCompleted()
                    }, onError: { error in
                        observer.onNext(nil)
                        observer.onCompleted()
                    })
            }
            return Disposables.create()
        }
    }
    
}
