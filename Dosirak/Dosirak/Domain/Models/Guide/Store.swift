//
//  Store.swift
//  Dosirak
//
//  Created by 권민재 on 11/3/24.
//

struct StoreListResponse: Decodable {
    let status: String
    let message: String
    let data: [Store]?
}

struct Store: Decodable {
    let storeId: Int
    let storeName: String
    let storeCategory: String
    let storeImg: String
    let ifValid: String
    let ifReward: String
    let operationTime: String
    let mapX: Double
    let mapY: Double
}
