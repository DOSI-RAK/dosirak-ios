//
//  EliteAPI.swift
//  Dosirak
//
//  Created by 권민재 on 11/23/24.
//

import Moya
import UIKit

enum EliteAPI {
    case fetchUserInfo(accessToken: String)
    case fetchTodayProblem(accessToken: String)
    case fetchCorrect(accessToken: String)
    case fetchIncorrect(accessToken: String)
    case fetchProblemDetail(problemId: Int)
}

extension EliteAPI: TargetType {
    var baseURL: URL { .init(string: "https://api.dosirak.com")! }
    var path: String {
        switch self {
        case .fetchUserInfo: return "/api/elite-info/user"
        case .fetchTodayProblem: return "/api/problems/random"
        case .fetchCorrect: return "/api/elite-history/user/correct"
        case .fetchIncorrect: return "/api/elite-history/user/incorrect"
        case .fetchProblemDetail(let problemId): return "/api/problems/\(problemId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchUserInfo, .fetchTodayProblem, .fetchCorrect, .fetchIncorrect, .fetchProblemDetail:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .fetchUserInfo(_), .fetchTodayProblem(_), .fetchCorrect(_), .fetchIncorrect(_), .fetchProblemDetail(_):
            return .requestPlain
        }
    }
    
    
    var headers: [String : String]? {
        switch self {
        case .fetchUserInfo(let accessToken), .fetchTodayProblem(let accessToken), .fetchCorrect(let accessToken), .fetchIncorrect(let accessToken):
            return ["Authorization": "Bearer \(accessToken)", "Content-Type": "application/json"]
        case .fetchProblemDetail(let problemId):
            return ["Content-Type": "application/json"]
        }
    }
    
    
    
}
