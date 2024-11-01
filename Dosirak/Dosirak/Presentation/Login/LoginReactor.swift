//
//  LoginReactor.swift
//  Dosirak
//
//  Created by 권민재 on 10/17/24.
//

import ReactorKit
import RxSwift

class LoginReactor: Reactor {
    enum Action {
        case tapKakaoLogin
        case tapNaverLogin
    }

    enum Mutation {
        case setLoading(Bool)
        case setLoginSuccess(Bool)
    }

    struct State {
        var isLoading: Bool = false
        var isLoginSuccess: Bool = false
    }

    let initialState = State()
    private let useCase: LoginUseCaseType

    init(useCase: LoginUseCaseType) {
        self.useCase = useCase
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapKakaoLogin:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true))
                    .do(onNext: { _ in print("Kakao login started") }),
                
                useCase.loginWithKakao()
                    .do(onNext: { accessToken in print("Received Kakao access token: \(accessToken)") })
                    .flatMap { accessToken in
                        self.useCase.registerUser(accessToken: accessToken, nickName: nil)
                    }
                    .map { success in
                        print("Kakao login success:", success)
                        return Mutation.setLoginSuccess(success)
                    },
                
                Observable.just(Mutation.setLoading(false))
                    .do(onNext: { _ in print("Kakao login finished") })
            ])

        case .tapNaverLogin:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true))
                    .do(onNext: { _ in print("Naver login started") }),
                
                useCase.loginWithNaver()
                    .do(onNext: { accessToken in print("Received Naver access token: \(accessToken)") })
                    .flatMap { accessToken in
                        self.useCase.registerUser(accessToken: accessToken, nickName: nil)
                    }
                    .map { success in
                        print("Naver login success:", success)
                        return Mutation.setLoginSuccess(success)
                    },
                
                Observable.just(Mutation.setLoading(false))
                    .do(onNext: { _ in print("Naver login finished") })
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
