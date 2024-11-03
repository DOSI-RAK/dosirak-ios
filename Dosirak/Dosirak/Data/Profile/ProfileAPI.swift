//
//  ProfileAPI.swift
//  Dosirak
//
//  Created by 권민재 on 11/3/24.
//
import Moya
import Foundation
import UIKit

enum ProfileAPI {
    case logout(accessToken: String)
    case withdraw(kakaoAccessToken: String)
    case editNickName(accessToken: String, nickName: String?)
    case getUserInfo(accessToken: String)
}


extension ProfileAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://dosirak.store")!
    }
    
    var path: String {
        switch self {
        case .logout: return "/api/user/logout"
        case .withdraw: return "/api/user/withdraw"
        case .editNickName: return "/api/mypage/nickName"
        case .getUserInfo: return "/api/user/mypage/profile"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .logout, .withdraw: return .post
        case .getUserInfo: return .get
        case .editNickName: return .put
        }
    }
    
    var task: Task {
        switch self {
        case .logout,.withdraw,.getUserInfo:
            return .requestPlain
        case .editNickName(_,let nickName):
            let param: [String: Any?] = [
                "nickName": nickName
            ]
            return .requestParameters(parameters: param.compactMapValues {$0}, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getUserInfo(let accessToken),.logout(let accessToken),.editNickName(let accessToken,_):
            return ["Authorization": "Bearer \(accessToken)", "Content-Type": "application/json"]
        case .withdraw(let kakaoAccessToken):
            return ["Authorization": "Bearer \(kakaoAccessToken)", "Content-Type": "application/json"]
            
        }
    }
    
    
    
}
