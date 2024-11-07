//
//  CommitAPI.swift
//  Dosirak
//
//  Created by 권민재 on 11/6/24.
//
import Moya
import UIKit
enum CommitAPI {
    case fetchMonthlyCommits(accessToken: String, month: String)
    case fetchTodayCommit(accessToken: String)
    case fetchDayCommit(accessToken: String, date: String)
    case fetchFirstDayCommit(accessToken: String, month: String)
    
}


extension CommitAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://dosirak.store")!
    }
    
    var path: String {
        switch self {
        case .fetchMonthlyCommits:
            return "/api/user-activity/monthly"
        case .fetchTodayCommit:
            return "/api/activity-logs/today"
        case .fetchDayCommit(_, let date):
            return "/api/activity-logs/daily/\(date)"
        case .fetchFirstDayCommit(_, let month):
            return "/api/activity-logs/first-day/\(month)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchMonthlyCommits, .fetchTodayCommit, .fetchDayCommit,.fetchFirstDayCommit:
                .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .fetchMonthlyCommits(_, let month):
            return .requestParameters(parameters: ["month": month], encoding: URLEncoding.queryString)
        case .fetchTodayCommit,.fetchDayCommit, .fetchFirstDayCommit:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .fetchMonthlyCommits(let accessToken,_), .fetchTodayCommit(let accessToken),.fetchDayCommit(let accessToken,_), .fetchFirstDayCommit(let accessToken,_):
            return ["Authorization": "Bearer \(accessToken)", "Content-Type": "application/json"]
        }
    }
    
    
}
