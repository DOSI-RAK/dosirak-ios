//
//  Store.swift
//  Dosirak
//
//  Created by 권민재 on 11/3/24.
//
import Foundation

struct APIResponse<T: Decodable>: Decodable {
    let status: String
    let message: String
    let data: T
}


struct Store: Decodable {
    let storeId: Int
    let storeName: String
    let storeCategory: String?
    let storeImg: String
    let ifValid: String
    let ifReward: String
    let operationTime: String
    let mapX: Double
    let mapY: Double
}


struct StoreDetail: Decodable {
    let storeId: Int
    let storeName: String
    let storeCategory: String?
    let storeImg: String
    let ifValid: String
    let ifReward: String
    let operationTime: String
    let mapX: Double
    let mapY: Double
    let meduId: Int
    let menuName: String
    let menuImg: String
    let menuPrice: Int
    let menuPackSize: String
}

struct NearMyStore: Decodable {
    let storeId: Int
    let storeName: String
    let telNumber: String
    let address: String
    let operationTime: String
    let storeCategory: String
    let storeImg: String
    let mapX: Double
    let mapY: Double
    let ifValid: String
    let ifReward: String
}
