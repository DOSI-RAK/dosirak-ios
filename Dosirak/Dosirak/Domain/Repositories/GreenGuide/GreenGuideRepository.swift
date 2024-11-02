//
//  GreenGuideRepository.swift
//  Dosirak
//
//  Created by 권민재 on 11/3/24.
//

import Moya
import RxSwift
import Foundation

protocol GuideRepositoryType {
    func fetchAllStores() -> Single<[Store]>
    func fetchStoreDetail(storeID: Int, accessToken: String) -> Single<Store>
}

// Repository 구현
final class GuideRepository: GuideRepositoryType {
    private let provider: MoyaProvider<GuideAPI>
    
    init(provider: MoyaProvider<GuideAPI> = MoyaProvider<GuideAPI>()) {
        self.provider = provider
    }
    
    func fetchAllStores() -> Single<[Store]> {
        return provider.rx.request(.fetchAllStores)
            .filterSuccessfulStatusCodes()
            .map(StoreListResponse.self)
            .flatMap { response in
                // data가 nil인 경우 에러 반환
                guard let stores = response.data else {
                    return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data available"]))
                }
                return Single.just(stores)
            }
    }
    
    func fetchStoreDetail(storeID: Int, accessToken: String) -> Single<Store> {
        return provider.rx.request(.fetchStoreDetail(accessToken: accessToken, storeID: storeID))
            .filterSuccessfulStatusCodes()
            .map(Store.self)
    }
}
