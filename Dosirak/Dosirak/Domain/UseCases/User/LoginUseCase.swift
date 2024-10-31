//
//  LoginUseCase.swift
//  Dosirak
//
//  Created by 권민재 on 10/29/24.
//

import RxSwift

protocol LoginUseCaseType {
    func loginWithKakao() -> Observable<String?>
    func loginWithNaver() -> Observable<String?>
    func registerUser(accessToken: String?, nickName: String?) -> Observable<Bool>
    func registerNickName(accessToken: String?, nickName: String) -> Observable<Bool>
}

class LoginUseCase: LoginUseCaseType {
    private let userRepository: UserRepositoryType

    init(userRepository: UserRepositoryType) {
        self.userRepository = userRepository
    }

    func loginWithKakao() -> Observable<String?> {
        return userRepository.loginWithKakao()
    }

    func loginWithNaver() -> Observable<String?> {
        return userRepository.loginWithNaver()
    }

    func registerUser(accessToken: String?, nickName: String?) -> Observable<Bool> {
        guard let accessToken = accessToken else {
            return Observable.just(false)
        }
        return userRepository.registerUser(accessToken: accessToken, nickName: nickName)
    }
    
    func registerNickName(accessToken: String?, nickName: String) -> Observable<Bool> {
        guard let accessToken = accessToken else {
            return Observable.just(false)
        }
        return userRepository.registerNickName(accessToken: accessToken, nickName: nickName)
    }
    
    
}
