//
//  HeroAPI.swift
//  Dosirak
//
//  Created by 권민재 on 11/15/24.
//
import Moya
import Foundation
import UIKit

enum HeroAPI {
    case fetchTotalRank(accessToken: String)
    case fetchMyRank(accessToken: String)
}

extension HeroAPI: TargetType {
    
    var baseURL: URL { .init(string: "https://api.dosirak.com")! }
    var path: String {
        switch self {
        case .fetchTotalRank: return "/api/users/rank"
        case .fetchMyRank: return "/api/users/rank/my"
        }
    }
    var method: Moya.Method {
        switch self {
        case .fetchMyRank, .fetchTotalRank:
            return .get
        }
    }
    
    
    var task: Moya.Task {
        switch self {
        case .fetchMyRank, .fetchTotalRank:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .fetchMyRank(let accessToken), .fetchTotalRank(let accessToken):
            return ["Authorization": "Bearer \(accessToken)", "Content-Type": "application/json"]
            
        }
    }
}
