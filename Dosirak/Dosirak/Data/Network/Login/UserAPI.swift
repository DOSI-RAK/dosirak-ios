//
//  UserAPI.swift
//  Dosirak
//
//  Created by 권민재 on 10/29/24.
//

import Moya
import Foundation

enum UserAPI {
    case register(accessToken: String, nickName: String?)
    case registerNickName(accessToken: String, nickName: String)
    case isValidToken(accessToken: String)
    case reissueToken(refreshToken: String)
    case withdraw(accessToken: String)
    case logout(accessToken: String)
}

extension UserAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://dosirak.store:80/api")!
    }
    
    var path: String {
        switch self {
        case .register:
            return "/user/register"
        case .registerNickName:
            return "/user/nickName"
        case .isValidToken:
            return "valid-token"
        case .reissueToken:
            return "/token/reissue/access-token"
        case .withdraw:
            return "/user/withdraw"
        case .logout:
            return "/user/logout"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .register:
            return .post
        case .registerNickName:
            return .post
        case .isValidToken:
            return .get
        case .reissueToken:
            return .get
        case .withdraw:
            return .post
        case .logout:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .register(_, let nickName):
            let parameters: [String: Any?] = [
                "nickName": nickName
            ]
            return .requestParameters(parameters: parameters.compactMapValues { $0 }, encoding: JSONEncoding.default)
        case .registerNickName(_, let nickName):
            let parameters: [String: Any?] = [
                "nickName": nickName
            ]
            return .requestParameters(parameters: parameters.compactMapValues { $0 }, encoding: JSONEncoding.default)
        case .isValidToken(accessToken: _):
            return .requestPlain
        case .reissueToken(refreshToken: _):
            return .requestPlain
        case .withdraw, .logout:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .register(let accessToken, _):
            return ["Authorization": "Bearer \(accessToken)", "Content-Type": "application/json"]
        case .registerNickName(let accessToken,_):
            return ["Authorization": "Bearer \(accessToken)", "Content-Type": "application/json"]
        case .isValidToken(let accessToken):
            return ["Authorization": "Bearer \(accessToken)", "Content-Type": "application/json"]
        case .reissueToken(let refreshToken):
            return ["Authorization": "Bearer \(refreshToken)", "Content-Type": "application/json"]
        case .withdraw(let accessToken):
            return ["Authorization": "Bearer \(accessToken)", "Content-Type": "application/json"]
        case .logout(let accessToken):
            return ["Authorization": "Bearer \(accessToken)", "Content-Type": "application/json"]
            
        }
    }
}
