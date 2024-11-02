//
//  GreenGuideUsecase.swift
//  Dosirak
//
//  Created by 권민재 on 11/3/24.
//

import RxSwift


protocol GuideUseCaseType {
    func getAllStores() -> Single<[Store]>
    func getStoreDetail(storeID: Int, accessToken: String) -> Single<Store>
}

// UseCase 구현
final class GuideUseCase: GuideUseCaseType {
    private let repository: GuideRepositoryType
    
    init(repository: GuideRepositoryType) {
        self.repository = repository
    }
    
    func getAllStores() -> Single<[Store]> {
        return repository.fetchAllStores()
    }
    
    func getStoreDetail(storeID: Int, accessToken: String) -> Single<Store> {
        return repository.fetchStoreDetail(storeID: storeID, accessToken: accessToken)
    }
}
