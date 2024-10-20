//
//  LoginUseCase.swift
//  Dosirak
//
//  Created by 권민재 on 10/20/24.
//

import RxSwift
import Moya

protocol LoginUseCase {
    func execute(provider: String, accessToken: String) -> Observable<User>
}

class LoginUseCaseImpl: LoginUseCase {
    private let userRepository: UserRepository

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    func execute(provider: String, accessToken: String) -> Observable<User> {
        return userRepository.regist(provider: provider, accessToken: accessToken)
            .catch { error in
                let userError: UserError
                
                if let moyaError = error as? MoyaError {
                    userError = .networkError(moyaError)
                } else {
                    userError = .parsingError
                }
                
                return Observable.error(userError)
            }
    }
}
