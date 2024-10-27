//
//  LoginReactor.swift
//  Dosirak
//
//  Created by 권민재 on 10/17/24.
//

import ReactorKit
import RxSwift

import ReactorKit
import RxSwift

class LoginReactor: Reactor {
    enum Action {
        case tapKakaoLogin
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setLoginSuccess(Bool)
    }
    
    struct State {
        var isLoading: Bool = false
        var isLoginSuccess: Bool = false
    }
    
    let initialState: State = State()
    
    private let loginManager: LoginManager
    
    init(loginManager: LoginManager) {
        self.loginManager = loginManager
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapKakaoLogin:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                
                self.loginManager.loginWithKakao()
                    .flatMap { accessToken in
                            return self.loginManager.registerUser(accessToken: accessToken, nickName: nil)
                    }
                    .map { success in
                        Mutation.setLoginSuccess(success)
                    },
                
                Observable.just(Mutation.setLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
        case let .setLoginSuccess(isLoginSuccess):
            newState.isLoginSuccess = isLoginSuccess
        }
        return newState
    }
}
