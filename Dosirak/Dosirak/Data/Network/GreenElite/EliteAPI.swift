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
    case recordAnswer(accessToken: String, problemId: Int, isCorrect: Bool)
}

extension EliteAPI: TargetType {
    var baseURL: URL { .init(string: "http://dosirak.store")! }
    
    var path: String {
        switch self {
        case .fetchUserInfo: return "/api/elite-info/user"
        case .fetchTodayProblem: return "/api/problems/random"
        case .fetchCorrect: return "/api/elite-history/user/correct"
        case .fetchIncorrect: return "/api/elite-history/user/incorrect"
        case .fetchProblemDetail(let problemId): return "/api/problems/\(problemId)"
        case .recordAnswer: return "/api/elite-history/record" // 쿼리 파라미터는 제외
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchUserInfo, .fetchTodayProblem, .fetchCorrect, .fetchIncorrect, .fetchProblemDetail:
            return .get
        case .recordAnswer:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .fetchUserInfo, .fetchTodayProblem, .fetchCorrect, .fetchIncorrect, .fetchProblemDetail:
            return .requestPlain
        case .recordAnswer(_, let problemId, let isCorrect):
            // 쿼리 파라미터를 분리하여 처리
            let parameters: [String: Any] = [
                "problemId": problemId,
                "isCorrect": isCorrect
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .fetchUserInfo(let accessToken),
             .fetchTodayProblem(let accessToken),
             .fetchCorrect(let accessToken),
             .fetchIncorrect(let accessToken),
             .recordAnswer(let accessToken, _, _):
            return ["Authorization": "Bearer \(accessToken)", "Content-Type": "application/json"]
        case .fetchProblemDetail:
            return ["Content-Type": "application/json"]
        }
    }
}
