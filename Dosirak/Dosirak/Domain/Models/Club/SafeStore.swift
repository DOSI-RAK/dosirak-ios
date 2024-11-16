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
    let saleMapX: Double
    let saleMapY: Double
    let saleOperationTime: String
    let saleDiscount: Int 
}
