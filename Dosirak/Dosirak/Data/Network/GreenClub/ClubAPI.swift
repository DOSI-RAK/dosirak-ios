//
//  ClubAPI.swift
//  Dosirak
//
//  Created by 권민재 on 11/15/24.
//

import Moya
import Foundation
import UIKit

enum ClubAPI {
    case fetchSaleStores(accessToken: String, address: String)
}

extension ClubAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://dosirak.store")!
    }
    
    var path: String {
        switch self {
        case .fetchSaleStores:
            return "/api/club/saleStores"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchSaleStores:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .fetchSaleStores(_, let address):
            return .requestParameters(parameters: ["saleStoreAddress": address], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .fetchSaleStores(let accessToken, _):
            return ["Authorization": "Bearer \(accessToken)", "Content-Type": "application/json"]
        }
    }
    
    
}
