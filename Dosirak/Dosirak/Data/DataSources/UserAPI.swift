//
//  UserAPI.swift
//  Dosirak
//
//  Created by 권민재 on 10/20/24.
//

import Moya
import Foundation

//baseURL:  http://dosirak.store:80
//naver_redirectionURL:  http://dosirak.store:80/login/oauth2/code/naver
//kakao_redirectionURL:  http://dosirak.store:80/login/oauth2/code/kakao
//api: /api/user/register



//enum UserError: Error {
//    case invalidAccessToken
//    case userNotFound
//    case parsingError
//    case networkError(Error)
//
//    var localizedDescription: String {
//        switch self {
//        case .invalidAccessToken:
//            return "Invalid access token."
//        case .userNotFound:
//            return "User not found."
//        case .parsingError:
//            return "Failed to parse user information."
//        case .networkError(let error):
//            return error.localizedDescription
//        }
//    }
//}
//
//enum UserAPI {
//    case regist(provider: String, accessToken: String)
//    case regenerateAccessToken(provider: String, refreshToken: String)
//    case checkNickname(nickName: String)
//}
//
//extension UserAPI: TargetType {
//    var baseURL: URL {
//        return URL(string: "https://dosirak.store/user")!
//    }
//
//    var path: String {
//        switch self {
//        case .regist:
//            return "/regist"
//        case .checkNickname:
//            return "/check-nickname"
//        case .regenerateAccessToken:
//            return "/access-token"
//        }
//    }
//
//    var method: Moya.Method {
//        switch self {
//        case .regist:
//            return .post
//        case .regenerateAccessToken,.checkNickname:
//            return .get
//        }
//    }
//
//    var task: Task {
//            switch self {
//            case .regist(let provider, let accessToken):
//                let parameters = ["provider": provider, "access_token": accessToken]
//                return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
//            case .checkNickName(let nickName):
//                return .requestParameters(parameters: ["nickName": nickName], encoding: URLEncoding.queryString)
//            case .regenerateAccessToken(let refreshToken):
//                let parameters = ["refresh_token": refreshToken]
//                return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
//            }
//        }
//
//
//    var headers: [String: String]? {
//        return ["Content-Type": "application/json"]
//    }
//
//    var validationType: ValidationType {
//        return .successCodes
//    }
//
//    var sampleData: Data {
//        return Data()
//    }
//}
