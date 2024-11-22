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
        case loadStoresByCategory(String)
        case loadStoresNearMyLocation(Double, Double)
        case searchStores(String) // 검색 액션 추가
    }
    
    // Mutation 정의
    enum Mutation {
        case setStores([Store])
        case setStoreDetail(StoreDetail)
        case setCategoryStores([Store])
        case setNearbyStores([Store])
        case setSearchResults([Store]) // 검색 결과 추가
        case setLoading(Bool)
        case setSelectedCategory(String)
    }
    
    // State 정의
    struct State {
        var stores: [Store] = []
        var storeDetail: StoreDetail?
        var categoryStores: [Store] = []
        var searchResults: [Store] = [] // 검색 결과 추가
        var isLoading: Bool = false
        var selectedCategory: String = "전체"
        var nearbyStores: [Store] = []
        var filteredStores: [Store] {
                return searchResults.isEmpty ? stores : searchResults
            }
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
            if category == "전체" {
                return Observable.concat([
                    Observable.just(Mutation.setSelectedCategory(category)),
                    mutate(action: .loadAllStores) // 전체 API 호출
                ])
            } else {
                return Observable.concat([
                    Observable.just(Mutation.setLoading(true)),
                    Observable.just(Mutation.setSelectedCategory(category)),
                    useCase.getCategoryStoreList(category: category)
                        .asObservable()
                        .map { Mutation.setCategoryStores($0) },
                    Observable.just(Mutation.setLoading(false))
                ])
            }
            
        case .loadStoresNearMyLocation(let mapX, let mapY):
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                useCase.getNearbyStores(mapX: mapX, mapY: mapY)
                    .asObservable()
                    .do(onNext: { stores in
                        print("Nearby stores fetched: \(stores)") // 디버깅용
                    })
                    .map { Mutation.setNearbyStores($0) },
                Observable.just(Mutation.setLoading(false))
            ])
            
        case .searchStores(let query): // 검색 로직 추가
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                useCase.searchStores(query: query)
                    .asObservable()
                    .map { Mutation.setSearchResults($0) },
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
            
        case .setCategoryStores(let categoryStores):
            newState.categoryStores = categoryStores
            
        case .setNearbyStores(let nearbyStores):
            newState.nearbyStores = nearbyStores
            
        case .setSearchResults(let searchResults): // 검색 결과 처리
            newState.searchResults = searchResults
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setSelectedCategory(let category):
            newState.selectedCategory = category
        }
        
        return newState
    }
}
