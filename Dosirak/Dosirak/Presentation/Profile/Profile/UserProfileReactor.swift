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
    
    enum Action {
        case setNickName(String)
        case saveNickName
    }
    
  
    enum Mutation {
        case setNickName(String)
        case setSaveSuccess(Bool)
    }
    
 
    struct State {
        var nickName: String = ""
        var isSaveSuccess: Bool?
    }
    
    let initialState = State()
    private let useCase: LoginUseCaseType
    private let keychain = AppSettings.accessToken
    
    init(useCase: LoginUseCaseType) {
        self.useCase = useCase
    }
    
 
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setNickName(let nickName):
            UserInfo.nickName = nickName
            return Observable.just(.setNickName(nickName))
            
        case .saveNickName:
            guard let accessToken = AppSettings.accessToken else {
                return Observable.just(.setSaveSuccess(false))
            }
            print("====>\(accessToken)")
            return useCase.registerNickName(accessToken: accessToken, nickName: currentState.nickName)
                .map { success in
                    return .setSaveSuccess(success)
                }
        }
    }
    
   
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
