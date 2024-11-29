//
//  Reward.swift
//  Dosirak
//
//  Created by 권민재 on 11/29/24.
//

import Foundation
import Moya

enum RewardAPI {
    case saveReward(distance: Int?)
}

extension RewardAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://dosirak.store")!
    }
    
    var path: String {
        switch self {
        case .saveReward:
            return "/api/dosirak/rewards"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .saveReward:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .saveReward(let distance):
            if let distance = distance {
                return .requestParameters(parameters: ["distance": distance], encoding: URLEncoding.queryString)
            } else {
                return .requestPlain
            }
        }
    }
    
    var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(AppSettings.accessToken ?? "")"
        ]
    }
    
    var sampleData: Data {
        return Data()
    }
}

final class GreenAuthAPIManager {
    static let shared = GreenAuthAPIManager()
    private let provider = MoyaProvider<RewardAPI>()

    private init() {}

    func saveReward(distance: Int?, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.saveReward(distance: distance)) { result in
            switch result {
            case .success(let response):
                if (200...299).contains(response.statusCode) {
                    completion(.success(()))
                } else {
                    completion(.failure(NSError(domain: "GreenAuthAPI", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "API 요청 실패"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
