//
//  SafeStore.swift
//  Dosirak
//
//  Created by 권민재 on 11/16/24.
//



struct SaleStore: Decodable {
    let saleStoreId: Int
    let saleStoreName: String
    let saleStoreImg: String
    let saleStoreAddress: String
    let saleMapX: String
    let saleMapY: String
    let saleOperationTime: String
    let saleDiscount: String
    var distance: Double? = nil
    
    private enum CodingKeys: String, CodingKey {
        case saleStoreId, saleStoreName, saleStoreImg, saleStoreAddress
        case saleMapX, saleMapY, saleOperationTime
        case saleDiscount = "saleDiscount"
    }
}
