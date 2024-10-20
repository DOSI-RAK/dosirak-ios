//
//  LoginReactor.swift
//  Dosirak
//
//  Created by 권민재 on 10/17/24.
//

import ReactorKit
import RxSwift
import Moya

class LoginReactor: Reactor {
    enum Action {
        case login(provider: String, accessToken: String)
    }

    enum Mutation {
        case setUserInfo(User)
        case setError(String)
    }

    struct State {
        var userInfo: User?
        var errorMessage: String?
    }

    let initialState: State = State()
    private let userRepository: UserRepository

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .login(provider, accessToken):
            guard !accessToken.isEmpty else {
                return Observable.just(.setError(UserError.invalidAccessToken.localizedDescription))
            }

            return userRepository.regist(provider: provider, accessToken: accessToken)
                .map { user in
                    return .setUserInfo(user)
                }
                .catch { error in
                    let userError: UserError
                    
                    if let moyaError = error as? MoyaError {
                        userError = .networkError(moyaError)
                    } else {
                        userError = .parsingError
                    }
                    
                    return Observable.just(.setError(userError.localizedDescription))
                }
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setUserInfo(user):
            newState.userInfo = user
            newState.errorMessage = nil
        case let .setError(error):
            newState.errorMessage = error
        }
        
        return newState
    }
}
