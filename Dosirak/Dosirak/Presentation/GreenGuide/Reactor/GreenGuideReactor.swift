//
//  GreenGuideReactor.swift
//  Dosirak
//
//  Created by 권민재 on 11/3/24.
//
import ReactorKit
import RxSwift

class GreenGuideReactor: Reactor {
    // Action 정의
    enum Action {
        case loadAllStores
        case loadStoreDetail(Int)
        case loadStoresByCategory(String) // 새로운 액션 추가
    }
    
    // Mutation 정의
    enum Mutation {
        case setStores([Store])
        case setStoreDetail(StoreDetail)
        case setCategoryStores([Store])
        case setLoading(Bool)
        case setSelectedCategory(String)
    }
    
    // State 정의
    struct State {
        var stores: [Store] = []
        var storeDetail: StoreDetail?
        var categoryStores: [Store] = []
        var isLoading: Bool = false
        var selectedCategory: String = "전체" // 기본 카테고리
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
            
        case .loadStoresByCategory(let category):
            // 전체 카테고리인 경우 loadAllStores를 호출
            if category == "전체" {
                return Observable.concat([
                    Observable.just(Mutation.setSelectedCategory(category)),
                    mutate(action: .loadAllStores) // 전체 API를 호출
                ])
            } else {
                // 다른 카테고리를 선택한 경우
                return Observable.concat([
                    Observable.just(Mutation.setLoading(true)),
                    Observable.just(Mutation.setSelectedCategory(category)),
                    useCase.getCategoryStoreList(category: category)
                        .asObservable()
                        .map { Mutation.setCategoryStores($0) },
                    Observable.just(Mutation.setLoading(false))
                ])
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setStores(let stores):
            newState.stores = stores
            
        case .setStoreDetail(let storeDetail):
            newState.storeDetail = storeDetail
            
        case .setCategoryStores(let categoryStores):
            newState.categoryStores = categoryStores
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setSelectedCategory(let category):
            newState.selectedCategory = category
        }
        
        return newState
    }
}
