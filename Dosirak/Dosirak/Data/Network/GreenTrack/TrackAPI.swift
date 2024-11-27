//
//  TrackAPI.swift
//  Dosirak
//
//  Created by 권민재 on 11/27/24.
//

import Moya
import UIKit

enum TrackAPI {
    case fetchBicycle( latitude: Double,longitude: Double)
    case recordTrackData(accessToken: String, shortestDistance: Double, moveDistance: Double)
}


extension TrackAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: "http://dosirak.store")!
    }
    
    var path: String {
        switch self {
        case .fetchBicycle:
            return "/api/seoul-bike-info"
        case .recordTrackData:
            return "/api/users/rank/my"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchBicycle:
            return .get
        case .recordTrackData:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .fetchBicycle(let latitude, let longitude):
            return .requestParameters(parameters: ["myLatitude":latitude, "myLongitude": longitude], encoding: URLEncoding.queryString)
        case .recordTrackData(_,let shortestDistance, let moveDistance):
            let parameters: [String: Double] = [
                "shortestDistance": shortestDistance,
                "moveDistance": moveDistance
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .fetchBicycle(_, _):
            return ["Content-Type": "application/json"]
        case .recordTrackData(let accessToken,_,_):
            return ["Authorization": "Bearer \(accessToken)", "Content-Type": "application/json"]
        }
    }
}
