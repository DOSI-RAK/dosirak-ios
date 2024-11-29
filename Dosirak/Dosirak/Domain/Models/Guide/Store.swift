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
    let exception: APIException?
}
struct APIException: Decodable {
    let errorCode: String?
    let errorMessage: String?
}

struct Empty: Decodable {}

struct Store: Decodable {
    let storeId: Int
    let storeName: String
    let storeCategory: String?
    let storeImg: String
    let ifValid: String
    let ifReward: String
    let mapX: Double
    let mapY: Double
    let operating: Bool
}


struct StoreDetail: Decodable {
    let storeId: Int
    let storeName: String
    let storeCategory: String?
    let storeImg: String
    let mapX: Double
    let mapY: Double
    let telNumber: String
    let ifValid: String
    let ifReward: String
    let menus: [Menu]
    let operationTime: String
}
struct OperatingTime: Decodable {
    let day: String
    let hours: String
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let keyValue = try container.decode([String: String].self)
        guard let (day, hours) = keyValue.first else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid operation time format.")
        }
        self.day = day
        self.hours = hours
    }
}

// 메뉴에 대한 모델
struct Menu: Codable {
    let menuId: Int
    let menuName: String
    let menuImg: String
    let menuPrice: Int
    let menuPackSize: String?
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
