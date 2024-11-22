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
    func fetchStoreDetail(storeID: Int, accessToken: String) -> Single<StoreDetail>
    func fetchCategoryStoreList(category: String) -> Single<[Store]>
    func fetchNearbyStores(latitude: Double, longitude: Double) -> Single<[Store]>
    func searchStores(query: String) -> Single<[Store]> // 검색 메서드 추가
}

final class GuideRepository: GuideRepositoryType {
    
    private let provider: MoyaProvider<GuideAPI>
    
    init(provider: MoyaProvider<GuideAPI> = MoyaProvider<GuideAPI>()) {
        self.provider = provider
    }
    
    func fetchAllStores() -> Single<[Store]> {
        return provider.rx.request(.fetchAllStores)
            .filterSuccessfulStatusCodes()
            .map { response in
                let decodedResponse = try JSONDecoder().decode(APIResponse<[Store]>.self, from: response.data)
                guard decodedResponse.status == "SUCCESS" else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch all stores"])
                }
                return decodedResponse.data
            }
    }
    
    func fetchStoreDetail(storeID: Int, accessToken: String) -> Single<StoreDetail> {
        return provider.rx.request(.fetchStoreDetail(accessToken: accessToken, storeID: storeID))
            .filterSuccessfulStatusCodes()
            .map { response in
                let decodedResponse = try JSONDecoder().decode(APIResponse<StoreDetail>.self, from: response.data)
                guard decodedResponse.status == "SUCCESS" else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch store details"])
                }
                return decodedResponse.data
            }
    }
    
    func fetchCategoryStoreList(category: String) -> Single<[Store]> {
        return provider.rx.request(.fetchCategory(query: category))
            .filterSuccessfulStatusCodes()
            .map { response in
                let decodedResponse = try JSONDecoder().decode(APIResponse<[Store]>.self, from: response.data)
                guard decodedResponse.status == "SUCCESS" else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch category stores"])
                }
                return decodedResponse.data
            }
    }
    
    func fetchNearbyStores(latitude mapX: Double, longitude mapY: Double) -> Single<[Store]> {
        return provider.rx.request(.fetchNearMyLocation(mapX: mapX, mapY: mapY))
            .filterSuccessfulStatusCodes()
            .map { response in
                let decodedResponse = try JSONDecoder().decode(APIResponse<[Store]>.self, from: response.data)
                guard decodedResponse.status == "SUCCESS" else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch nearby stores"])
                }
                return decodedResponse.data
            }
    }
    
    func searchStores(query: String) -> Single<[Store]> {
        return provider.rx.request(.searchStore(query: query))
            .filterSuccessfulStatusCodes()
            .do(onSuccess: { response in
                print("Search Stores - Raw Response: \(String(data: response.data, encoding: .utf8) ?? "No data")")
            })
            .map { response in
                do {
                    let decodedResponse = try JSONDecoder().decode(APIResponse<[Store]>.self, from: response.data)
                    if decodedResponse.status == "SUCCESS" {
                        print("Search Stores - Parsed Response: \(decodedResponse.data)")
                        return decodedResponse.data
                    } else {
                        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Search failed with status: \(decodedResponse.status)"])
                    }
                } catch {
                    print("Search Stores - Decoding Error: \(error)")
                    throw error
                }
            }
            .do(onError: { error in
                print("Search Stores - Error: \(error.localizedDescription)")
            })
    }
}
