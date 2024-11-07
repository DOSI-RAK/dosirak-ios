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
    case fetchCategory(query: String)
    case fetchNearMyLocation(mapX: Double, mayY: Double)
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
        case .fetchCategory:
            return "/api/guide/stores/filter"
        case .fetchNearMyLocation:
            return "/api/guide/stores/nearby"
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

        case .fetchCategory(let query):
            return .requestParameters(parameters: ["storeCategory" : query], encoding: URLEncoding.queryString)
        case .fetchNearMyLocation(let mapX, let mapY):
            return .requestParameters(parameters: ["currentMapX": mapX, "currentMapY": mapY], encoding: URLEncoding.default)
        }
        
    }
    
    var headers: [String: String]? {
        switch self {
        case .fetchAllStores, .fetchCategory, .fetchNearMyLocation:
            return nil
            
        case .fetchStoreDetail(let accessToken, _),
             .searchStore(let accessToken, _):
            return ["Authorization": "Bearer \(accessToken)", "Content-Type": "application/json"]
        }
    }
}
