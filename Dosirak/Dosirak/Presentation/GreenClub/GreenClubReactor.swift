//
//  GreenClubReactor.swift
//  Dosirak
//
//  Created by 권민재 on 11/16/24.
//

import RxSwift
import ReactorKit

class GreenClubReactor: Reactor {
    
    // MARK: - Actions
    enum Action {
        case fetchStores(accessToken: String, address: String)
    }
    
    // MARK: - Mutations
    enum Mutation {
        case setStores([SaleStore])
        case setLoading(Bool)
        case setError(String?)
    }
    
    // MARK: - State
    struct State {
        var stores: [SaleStore] = []
        var isLoading: Bool = false
        var errorMessage: String? = nil
    }
    
    // MARK: - Properties
    let initialState = State()
    private let useCase: GreenClubUseCaseType
    
    // MARK: - Initializer
    init(useCase: GreenClubUseCaseType) {
        self.useCase = useCase
    }
    
    // MARK: - Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchStores(let accessToken, let address):
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                
                useCase.getSaleStores(accessToken: accessToken, address: address)
                    .asObservable()
                    .map { Mutation.setStores($0) }
                    .catch { error in
                        return .just(Mutation.setError(error.localizedDescription))
                    },
                
                Observable.just(Mutation.setLoading(false))
            ])
        }
    }
    
    // MARK: - Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setStores(let stores):
            newState.stores = stores
            newState.errorMessage = nil
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setError(let message):
            newState.errorMessage = message
            newState.stores = []
        }
        
        return newState
    }
}
