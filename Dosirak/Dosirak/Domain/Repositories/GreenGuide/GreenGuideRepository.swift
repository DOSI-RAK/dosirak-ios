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
    
}

final class GuideRepository: GuideRepositoryType {
    private let provider: MoyaProvider<GuideAPI>
    
    init(provider: MoyaProvider<GuideAPI> = MoyaProvider<GuideAPI>()) {
        self.provider = provider
    }
    
    func fetchAllStores() -> Single<[Store]> {
        return provider.rx.request(.fetchAllStores)
            .filterSuccessfulStatusCodes()
            .do(onSuccess: { response in
                print("fetchAllStores - Raw Response: \(response)")
            })
            .map { response in
                do {
                    let decodedResponse = try JSONDecoder().decode(APIResponse<[Store]>.self, from: response.data)
                    if decodedResponse.status == "SUCCESS" {
                        print("=======>\(decodedResponse.status)")
                        print("Fetched storelist Response:", decodedResponse.data) // 디버그용 출력
                        return decodedResponse.data
                    } else {
                        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch chat room summary"])
                    }
                } catch {
                    print("Decoding error:", error)
                    throw error
                }
            }.do(onSuccess: { summaries in
                print("Decoded My storelist Summary:", summaries) // 디코딩 확인용
            })
        
    }
    
    func fetchStoreDetail(storeID: Int, accessToken: String) -> Single<StoreDetail> {
        return provider.rx.request(.fetchStoreDetail(accessToken: accessToken, storeID: storeID))
            .filterSuccessfulStatusCodes()
            .do(onSuccess: { response in
                print("fetchStoreDetail - Raw Response for StoreID \(storeID): \(response)")
            })
            .map { response in
                do {
                    let decodedResponse = try JSONDecoder().decode(APIResponse<StoreDetail>.self, from: response.data)
                    if decodedResponse.status == "SUCCESS" {
                        print("=======>\(decodedResponse.status)")
                        print("Fetched storelist Response:", decodedResponse.data) // 디버그용 출력
                        return decodedResponse.data
                    } else {
                        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch chat room summary"])
                    }
                } catch {
                    print("Decoding error:", error)
                    throw error
                }
            }
            .do(onSuccess: { store in
                print("fetchStoreDetail - Mapped Store: \(store)")
            })
            .debug("fetchStoreDetail Debug", trimOutput: true)
    }
    
    func fetchCategoryStoreList(category: String) -> Single<[Store]> {
        return provider.rx.request(.fetchCategory(query: category))
            .filterSuccessfulStatusCodes()
            .map { response in
                do {
                    let decodedResponse = try JSONDecoder().decode(APIResponse<[Store]>.self, from: response.data)
                    if decodedResponse.status == "SUCCESS" {
                        print("======>\(decodedResponse.data)")
                        return decodedResponse.data
                    } else {
                        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch chat room summary"])
                    }
                } catch {
                    print("Decoding error:", error)
                    throw error
                }
            }
    }
}
