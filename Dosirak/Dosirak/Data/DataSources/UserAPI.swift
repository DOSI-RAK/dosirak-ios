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

//소셜로그인 /api/user/register
//토크재발급 /api/token/reissue/access-token
//토큰 유혀성검사 /api/valid-token

enum UserError: Error {
    case invalidAccessToken
    case userNotFound
    case parsingError
    case networkError(Error)

    var localizedDescription: String {
        switch self {
        case .invalidAccessToken:
            return "Invalid access token."
        case .userNotFound:
            return "User not found."
        case .parsingError:
            return "Failed to parse user information."
        case .networkError(let error):
            return error.localizedDescription
        }
    }
}

enum UserAPI {
    case regist(provider: String, accessToken: String, nickName: String?)
    case regenerateAccessToken(refreshToken: String)
    case checkValidToken(accessToken: String)
}

extension UserAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://dosirak.store:80")!
    }

    var path: String {
        switch self {
        case .regist:
            return "/api/user/register"
        case .regenerateAccessToken:
            return "/api/token/reissue/access-token"
        case .checkValidToken:
            return "/api/valid-token"
        }
    }

    var method: Moya.Method {
        switch self {
        case .regist:
            return .post
        case .regenerateAccessToken, .checkValidToken:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .regist(let provider, let accessToken, let nickName):
            // Prepare the request body for registration
            var parameters: [String: Any] = ["provider": provider]
            if let nickName = nickName {
                parameters["nickName"] = nickName
            } else {
                parameters["nickName"] = NSNull()  // Handle null nickName
            }
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)

        case .regenerateAccessToken(let refreshToken):
            let parameters = ["refresh_token": refreshToken]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)

        case .checkValidToken(let accessToken):
            let parameters = ["access_token": accessToken]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        switch self {
        case .regist(_, let accessToken, _):
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(accessToken)"  // Add access token in Authorization header
            ]
        default:
            return ["Content-Type": "application/json"]
        }
    }

    var validationType: ValidationType {
        return .successCodes
    }

    var sampleData: Data {
        return Data()
    }
}
