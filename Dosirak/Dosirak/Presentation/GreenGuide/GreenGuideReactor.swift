//
//  GreenGuideReactor.swift
//  Dosirak
//
//  Created by 권민재 on 11/3/24.
//

import ReactorKit
import RxSwift

class GuideReactor: Reactor {
    // Action 정의
    enum Action {
        case loadAllStores
        case loadStoreDetail(Int)
    }
    
    // Mutation 정의
    enum Mutation {
        case setStores([Store])
        case setStoreDetail(Store)
        case setLoading(Bool)
    }
    
    // State 정의
    struct State {
        var stores: [Store] = []
        var storeDetail: Store?
        var isLoading: Bool = false
    }
    
    let initialState: State
    private let useCase: GuideUseCaseType
    private let accessToken: String
    
    init(useCase: GuideUseCaseType, accessToken: String) {
        self.useCase = useCase
        self.accessToken = accessToken
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadAllStores:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                useCase.getAllStores()
                    .asObservable()
                    .map { Mutation.setStores($0) },
                Observable.just(Mutation.setLoading(false))
            ])
            
        case .loadStoreDetail(let storeID):
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                useCase.getStoreDetail(storeID: storeID, accessToken: accessToken)
                    .asObservable()
                    .map { Mutation.setStoreDetail($0) },
                Observable.just(Mutation.setLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setStores(let stores):
            newState.stores = stores
            
        case .setStoreDetail(let storeDetail):
            newState.storeDetail = storeDetail
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        }
        
        return newState
    }
}
