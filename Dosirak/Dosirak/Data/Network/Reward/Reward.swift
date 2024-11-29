//
//  Reward.swift
//  Dosirak
//
//  Created by 권민재 on 11/29/24.
//

import Foundation
import Moya

enum RewardAPI {
    case saveTrack(distance: Double)
    case saveDosirak
}

extension RewardAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://dosirak.store")!
    }
    
    var path: String {
        switch self {
        case .saveTrack:
            return "api/rewards/track"
        case .saveDosirak:
            return "api/rewards/dosirak"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .saveDosirak, .saveTrack:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .saveTrack(let distance):
            return .requestParameters(parameters: ["distance": distance], encoding: URLEncoding.queryString)
        case .saveDosirak:
            return .requestPlain
        
        }
    
    }
    
    var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(AppSettings.accessToken ?? "")"
        ]
    }
    
}

final class GreenRewardAPIManager {
    static let shared = GreenRewardAPIManager()

    private let provider: MoyaProvider<RewardAPI>

    private init(provider: MoyaProvider<RewardAPI> = MoyaProvider<RewardAPI>()) {
        self.provider = provider
    }

    func saveTrack(distance: Double, completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.saveTrack(distance: distance)) { result in
            switch result {
            case .success(let response):
                if (200...299).contains(response.statusCode) {
                    print("✅ [GreenAuthAPI] Track reward saved successfully.")
                    completion(.success(()))
                } else {
                    print("❌ [GreenAuthAPI] Failed to save track reward. Status code: \(response.statusCode)")
                    let error = NSError(
                        domain: "GreenAuthAPI",
                        code: response.statusCode,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Failed to save track reward. Status code: \(response.statusCode)"
                        ]
                    )
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ [GreenAuthAPI] Request failed with error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    /// Save dosirak reward
    func saveDosirak(completion: @escaping (Result<Void, Error>) -> Void) {
        provider.request(.saveDosirak) { result in
            switch result {
            case .success(let response):
                if (200...299).contains(response.statusCode) {
                    print("✅ [GreenAuthAPI] Dosirak reward saved successfully.")
                    completion(.success(()))
                } else {
                    print("❌ [GreenAuthAPI] Failed to save dosirak reward. Status code: \(response.statusCode)")
                    let error = NSError(
                        domain: "GreenAuthAPI",
                        code: response.statusCode,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Failed to save dosirak reward. Status code: \(response.statusCode)"
                        ]
                    )
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ [GreenAuthAPI] Request failed with error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}

