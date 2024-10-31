//
//  UserProfileReactor.swift
//  Dosirak
//
//  Created by 권민재 on 10/18/24.
//

import ReactorKit
import RxSwift
import KeychainAccess

class UserProfileReactor: Reactor {
    // Action: View에서 발생하는 사용자 액션을 정의
    enum Action {
        case setNickName(String)
        case saveNickName
    }
    
    // Mutation: Action을 받아 상태(State)를 변경하는 작은 단위의 작업
    enum Mutation {
        case setNickName(String)
        case setSaveSuccess(Bool)
    }
    
    // State: View에서 보여질 상태를 정의
    struct State {
        var nickName: String = ""
        var isSaveSuccess: Bool?
    }
    
    let initialState = State()
    private let useCase: LoginUseCaseType
    private let keychain = Keychain(service: "com.dosirak.user")
    
    init(useCase: LoginUseCaseType) {
        self.useCase = useCase
    }
    
    // Action -> Mutation 변환
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setNickName(let nickName):
            return Observable.just(.setNickName(nickName))
            
        case .saveNickName:
            // Keychain에서 accessToken을 가져옴
            guard let accessToken = keychain["accessToken"] else {
                return Observable.just(.setSaveSuccess(false))
            }
            print("====>\(accessToken)")
            return useCase.registerNickName(accessToken: accessToken, nickName: currentState.nickName)
                .map { success in
                    return .setSaveSuccess(success)
                }
        }
    }
    
    // Mutation -> State 변환
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNickName(let nickName):
            newState.nickName = nickName
            
        case .setSaveSuccess(let isSuccess):
            newState.isSaveSuccess = isSuccess
        }
        return newState
    }
}
