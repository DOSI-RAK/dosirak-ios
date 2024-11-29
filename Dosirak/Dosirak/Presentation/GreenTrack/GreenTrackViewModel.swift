//
//  GreenTrackViewModel.swift
//  Dosirak
//
//  Created by 권민재 on 11/27/24.
//

import Foundation
import Moya

class GreenTrackViewModel {
    private let provider: MoyaProvider<TrackAPI>
    
    init(provider: MoyaProvider<TrackAPI> = MoyaProvider<TrackAPI>()) {
        self.provider = provider
    }
    
    func fetchBicycleData(latitude: Double, longitude: Double, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        print("🚀 [TrackAPI.fetchBicycle] Requesting bicycle data...")
        print("📍 Latitude: \(latitude), Longitude: \(longitude)")
        
        provider.request(.fetchBicycle(latitude: latitude, longitude: longitude)) { result in
            switch result {
            case .success(let response):
                do {
                    print("✅ [TrackAPI.fetchBicycle] Response received with status code: \(response.statusCode)")
                    if let json = try response.mapJSON() as? [String: Any] {
                        print("🔍 [TrackAPI.fetchBicycle] Response JSON: \(json)")
                        completion(.success(json))
                    } else {
                        print("⚠️ [TrackAPI.fetchBicycle] Response JSON is empty or invalid.")
                        completion(.success([:]))
                    }
                } catch {
                    print("❌ [TrackAPI.fetchBicycle] Failed to parse JSON: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ [TrackAPI.fetchBicycle] Request failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    /// 이동 데이터를 서버에 기록합니다.
    func recordTrackData(accessToken: String, shortestDistance: Double, moveDistance: Double, storeName: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        print("🚀 [TrackAPI.recordTrackData] Recording track data...")
        print("🔑 Access Token: \(accessToken)")
        print("📏 Shortest Distance: \(shortestDistance), Move Distance: \(moveDistance)")
        
        provider.request(.recordTrackData(accessToken: accessToken, shortestDistance: shortestDistance, moveDistance: moveDistance, storeName: storeName)) { result in
            switch result {
            case .success(let response):
                print("✅ [TrackAPI.recordTrackData] Response received with status code: \(response.statusCode)")
                do {
                    if let json = try response.mapJSON() as? [String: Any] {
                        print("🔍 [TrackAPI.recordTrackData] Response JSON: \(json)")
                    }
                } catch {
                    print("⚠️ [TrackAPI.recordTrackData] Response JSON parsing skipped.")
                }
                if response.statusCode == 200 {
                    print("✅ [TrackAPI.recordTrackData] Track data recorded successfully.")
                    completion(.success(true))
                } else {
                    print("⚠️ [TrackAPI.recordTrackData] Recording failed with status code: \(response.statusCode)")
                    completion(.success(false))
                }
            case .failure(let error):
                print("❌ [TrackAPI.recordTrackData] Request failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}
