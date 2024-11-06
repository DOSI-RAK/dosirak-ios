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
    case searchStore(accessToken: String, query: String)
}

extension GuideAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://dosirak.store")!
    }
    
    var path: String {
        switch self {
        case .fetchAllStores:
            return "/api/guide/stores/all"
        case .fetchStoreDetail(_, let storeID):
            return "/api/guide/stores/\(storeID)"
        case .searchStore:
            return "/api/guide/stores/search"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .fetchAllStores, .fetchStoreDetail:
            return .requestPlain
            
        case .searchStore(_, let query):
            return .requestParameters(parameters: ["keyword": query], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .fetchAllStores:
            return nil
            
        case .fetchStoreDetail(let accessToken, _),
             .searchStore(let accessToken, _):
            return ["Authorization": "Bearer \(accessToken)", "Content-Type": "application/json"]
        }
    }
}
