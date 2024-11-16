//
//  GreenClubRepository.swift
//  Dosirak
//
//  Created by 권민재 on 11/16/24.
//

import RxSwift
import Moya
import Foundation

protocol GreenClubRepositoryType {
    func fetchSaleStores(address: String) -> Single<[SaleStore]>
}

class GreenClubRepository: GreenClubRepositoryType {
    private let apiProvider: MoyaProvider<ClubAPI>
    private let accessToken: String

    
    init(apiProvider: MoyaProvider<ClubAPI>, accessToken: String) {
            self.apiProvider = apiProvider
            self.accessToken = accessToken
        }
    
    func fetchSaleStores(address: String) -> Single<[SaleStore]> {
        return apiProvider.rx
            .request(.fetchSaleStores(accessToken: accessToken, address: address))
            .filterSuccessfulStatusCodes()
            .map(APIResponse<[SaleStore]>.self)
            .flatMap { response in
                if response.status == "success" {
                    return .just(response.data)
                } else {
                    return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch chat room summary"]))
                }
            }
    }
}
