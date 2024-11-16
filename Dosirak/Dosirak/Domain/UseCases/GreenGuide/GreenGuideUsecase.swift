//
//  GreenGuideUsecase.swift
//  Dosirak
//
//  Created by 권민재 on 11/3/24.
//

import RxSwift


protocol GuideUseCaseType {
    func getAllStores() -> Single<[Store]>
    func getStoreDetail(storeID: Int, accessToken: String) -> Single<StoreDetail>
    func getCategoryStoreList(category: String) -> Single<[Store]>
    func getNearbyStores(mapX: Double, mapY: Double) -> Single<[Store]>
}


final class GuideUseCase: GuideUseCaseType {
    private let repository: GuideRepositoryType
    
    init(repository: GuideRepositoryType) {
        self.repository = repository
    }
    
    func getAllStores() -> Single<[Store]> {
        return repository.fetchAllStores()
    }
    
    func getStoreDetail(storeID: Int, accessToken: String) -> Single<StoreDetail> {
        return repository.fetchStoreDetail(storeID: storeID, accessToken: accessToken)
    }
    func getCategoryStoreList(category: String) -> Single<[Store]> {
        return repository.fetchCategoryStoreList(category: category)
    }
    func getNearbyStores(mapX: Double, mapY: Double) -> Single<[Store]> {
        return repository.fetchNearbyStores(latitude: mapX, longitude: mapY)
    }
}
