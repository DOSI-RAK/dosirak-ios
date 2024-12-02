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
    
    func fetchBicycleData(accessToken: String,latitude: Double, longitude: Double, completion: @escaping (Result<[Track], Error>) -> Void) {
        print("🚀 [TrackAPI.fetchBicycle] Requesting bicycle data...")
        print("📍 Latitude: \(latitude), Longitude: \(longitude)")
        
        provider.request(.fetchBicycle(accessToken: accessToken, latitude: latitude, longitude: longitude)) { result in
            switch result {
            case .success(let response):
                do {
                    print("✅ [TrackAPI.fetchBicycle] Response received with status code: \(response.statusCode)")

                    // Raw Response 디버깅용 출력
                    if let rawResponse = String(data: response.data, encoding: .utf8) {
                        print("📋 [TrackAPI.fetchBicycle] Raw Response Data: \(rawResponse)")
                    }

                    // APIResponse 디코딩
                    let apiResponse = try JSONDecoder().decode(APIResponse<[Track]>.self, from: response.data)
                    print("✅ [TrackAPI.fetchBicycle] Decoded APIResponse: \(apiResponse)")

                    // 성공 시 데이터 반환
                    completion(.success(apiResponse.data))
                } catch {
                    print("❌ [TrackAPI.fetchBicycle] Failed to decode JSON: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("❌ [TrackAPI.fetchBicycle] Request failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    /// 이동 데이터를 서버에 기록합니다.
    func recordTrackData(accessToken: String, shortestDistance: Decimal, moveDistance: Decimal, storeName: String, completion: @escaping (Result<Bool, Error>) -> Void) {
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
                // 200번대 상태 코드 확인
                if (200...299).contains(response.statusCode) {
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
