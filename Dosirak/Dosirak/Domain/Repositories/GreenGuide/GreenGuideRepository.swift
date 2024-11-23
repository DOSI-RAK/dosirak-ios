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
            .do(onSuccess: { response in
                print("fetchAllStores - Status Code: \(response.statusCode)")
                print("fetchAllStores - Raw Response: \(String(data: response.data, encoding: .utf8) ?? "No data")")
            }, onError: { error in
                print("fetchAllStores - Error: \(error.localizedDescription)")
            })
            .filterSuccessfulStatusCodes()
            .map { response in
                do {
                    let decodedResponse = try JSONDecoder().decode(APIResponse<[Store]>.self, from: response.data)
                    if decodedResponse.status == "SUCCESS" {
                        print("fetchAllStores - Parsed Response: \(decodedResponse.data)")
                        return decodedResponse.data
                    } else {
                        print("fetchAllStores - Failed with status: \(decodedResponse.status)")
                        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch all stores"])
                    }
                } catch {
                    print("fetchAllStores - Decoding Error: \(error)")
                    throw error
                }
            }
    }
    
    func fetchStoreDetail(storeID: Int, accessToken: String) -> Single<StoreDetail> {
        return provider.rx.request(.fetchStoreDetail(accessToken: accessToken, storeID: storeID))
            .do(onSuccess: { response in
                print("fetchStoreDetail - Status Code: \(response.statusCode)")
                print("fetchStoreDetail - Raw Response: \(String(data: response.data, encoding: .utf8) ?? "No data")")
            }, onError: { error in
                print("fetchStoreDetail - Error: \(error.localizedDescription)")
            })
            .filterSuccessfulStatusCodes()
            .map { response in
                do {
                    let decodedResponse = try JSONDecoder().decode(APIResponse<StoreDetail>.self, from: response.data)
                    if decodedResponse.status == "SUCCESS" {
                        print("fetchStoreDetail - Parsed Response: \(decodedResponse.data)")
                        return decodedResponse.data
                    } else {
                        print("fetchStoreDetail - Failed with status: \(decodedResponse.status)")
                        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch store details"])
                    }
                } catch {
                    print("fetchStoreDetail - Decoding Error: \(error)")
                    throw error
                }
            }
    }
    
    func fetchCategoryStoreList(category: String) -> Single<[Store]> {
        return provider.rx.request(.fetchCategory(query: category))
            .do(onSuccess: { response in
                print("fetchCategoryStoreList - Status Code: \(response.statusCode)")
                print("fetchCategoryStoreList - Raw Response: \(String(data: response.data, encoding: .utf8) ?? "No data")")
            }, onError: { error in
                print("fetchCategoryStoreList - Error: \(error.localizedDescription)")
            })
            .filterSuccessfulStatusCodes()
            .map { response in
                do {
                    let decodedResponse = try JSONDecoder().decode(APIResponse<[Store]>.self, from: response.data)
                    if decodedResponse.status == "SUCCESS" {
                        print("fetchCategoryStoreList - Parsed Response: \(decodedResponse.data)")
                        return decodedResponse.data
                    } else {
                        print("fetchCategoryStoreList - Failed with status: \(decodedResponse.status)")
                        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch category stores"])
                    }
                } catch {
                    print("fetchCategoryStoreList - Decoding Error: \(error)")
                    throw error
                }
            }
    }
    
    func fetchNearbyStores(latitude mapX: Double, longitude mapY: Double) -> Single<[Store]> {
        return provider.rx.request(.fetchNearMyLocation(mapX: mapX, mapY: mapY))
            .do(onSuccess: { response in
                print("fetchNearbyStores - Status Code: \(response.statusCode)")
                print("fetchNearbyStores - Raw Response: \(String(data: response.data, encoding: .utf8) ?? "No data")")
            }, onError: { error in
                print("fetchNearbyStores - Error: \(error.localizedDescription)")
            })
            .filterSuccessfulStatusCodes()
            .map { response in
                do {
                    let decodedResponse = try JSONDecoder().decode(APIResponse<[Store]>.self, from: response.data)
                    if decodedResponse.status == "SUCCESS" {
                        print("fetchNearbyStores - Parsed Response: \(decodedResponse.data)")
                        return decodedResponse.data
                    } else {
                        print("fetchNearbyStores - Failed with status: \(decodedResponse.status)")
                        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch nearby stores"])
                    }
                } catch {
                    print("fetchNearbyStores - Decoding Error: \(error)")
                    throw error
                }
            }
    }
    
    func searchStores(query: String) -> Single<[Store]> {
        return provider.rx.request(.searchStore(query: query))
            .do(onSuccess: { response in
                print("searchStores - Status Code: \(response.statusCode)")
                print("searchStores - Raw Response: \(String(data: response.data, encoding: .utf8) ?? "No data")")
            }, onError: { error in
                print("searchStores - Error: \(error.localizedDescription)")
            })
            .filterSuccessfulStatusCodes()
            .map { response in
                do {
                    let decodedResponse = try JSONDecoder().decode(APIResponse<[Store]>.self, from: response.data)
                    if decodedResponse.status == "SUCCESS" {
                        print("searchStores - Parsed Response: \(decodedResponse.data)")
                        return decodedResponse.data
                    } else {
                        print("searchStores - Failed with status: \(decodedResponse.status)")
                        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Search failed with status: \(decodedResponse.status)"])
                    }
                } catch {
                    print("searchStores - Decoding Error: \(error)")
                    throw error
                }
            }
    }
}
