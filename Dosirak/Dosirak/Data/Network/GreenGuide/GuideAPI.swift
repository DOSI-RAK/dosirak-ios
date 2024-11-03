//
//  GuideAPI.swift
//  Dosirak
//
//  Created by 권민재 on 11/2/24.
//
import Moya
import UIKit

enum GuideAPI {
    case fetchAllStores
    case fetchStoreDetail(accessToken: String, storeID: Int)
    
}

extension GuideAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://dosirak.store")!
    }
    
    var path: String {
        switch self {
        case .fetchAllStores:
            return "/api/guide/stores/all"
        case .fetchStoreDetail(accessToken: _, storeID: let storeID):
            return "/api/guide/stores/\(storeID)"
        }
    }
    var method: Moya.Method {
        switch self {
        case .fetchAllStores, .fetchStoreDetail:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .fetchAllStores,.fetchStoreDetail:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .fetchAllStores:
            return .none
                
        case .fetchStoreDetail(let accessToken,_):
            return ["Authorization": "Bearer \(accessToken)", "Content-Type": "application/json"]
        }
    }
    
    
}
