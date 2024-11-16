//
//  Untitled.swift
//  Dosirak
//
//  Created by 권민재 on 11/16/24.
//

import RxSwift

protocol GreenClubUseCaseType {
    func getSaleStores(accessToken: String, address: String) -> Single<[SaleStore]>
}

class GreenClubUseCase: GreenClubUseCaseType {
    private let repository: GreenClubRepositoryType
    
    init(repository: GreenClubRepositoryType) {
        self.repository = repository
    }
    
    func getSaleStores(accessToken: String, address: String) -> Single<[SaleStore]> {
        return repository.fetchSaleStores(accessToken: accessToken, address: address)
    }
}
