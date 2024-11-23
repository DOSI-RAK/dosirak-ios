//
//  GreenCommitViewModel.swift
//  Dosirak
//
//  Created by 권민재 on 11/6/24.
//
import UIKit
import Moya

class GreenCommitViewModel {
    private let provider = MoyaProvider<CommitAPI>()

    // Fetch Monthly Commits
    func fetchMonthlyCommits(accessToken: String, month: String, completion: @escaping (Result<[MonthCommit], Error>) -> Void) {
        print("Fetching Monthly Commits for month: \(month)")

        provider.request(.fetchMonthlyCommits(accessToken: accessToken, month: month)) { result in
            switch result {
            case .success(let response):
                print("Response Status Code: \(response.statusCode)")
                if let responseString = String(data: response.data, encoding: .utf8) {
                    print("Response Body: \(responseString)")
                }
                do {
                    let decodedResponse = try JSONDecoder().decode(APIResponse<[MonthCommit]>.self, from: response.data)
                    if decodedResponse.status == "SUCCESS" {
                        print("Decoded Monthly Commits: \(decodedResponse.data)")
                        completion(.success(decodedResponse.data))
                    } else {
                        print("API Error: \(decodedResponse.message)")
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: decodedResponse.message])))
                    }
                } catch {
                    print("Decoding Error: \(error.localizedDescription)")
                    if let responseString = String(data: response.data, encoding: .utf8) {
                        print("Failed to decode: \(responseString)")
                    }
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Network Request Failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    func fetchTodayCommits(accessToken: String, completion: @escaping (Result<[CommitActivity], Error>) -> Void) {
        provider.request(.fetchTodayCommit(accessToken: accessToken)) { result in
            switch result {
            case .success(let response):
                do {
                    // JSON 출력 (디버깅)
                    if let responseBody = String(data: response.data, encoding: .utf8) {
                        print("Raw Response Body:", responseBody)
                    }
                    
                    // 디코딩
                    let decodedResponse = try JSONDecoder().decode(APIResponse<[CommitActivity]>.self, from: response.data)
                    if decodedResponse.status == "SUCCESS" {
                        print("Decoded Data:", decodedResponse.data)
                        completion(.success(decodedResponse.data))
                    } else {
                        print("Decoding Failed: \(decodedResponse.message)")
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: decodedResponse.message])))
                    }
                } catch {
                    print("Decoding Error:", error)
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Network Error:", error)
                completion(.failure(error))
            }
        }
    }

    // Fetch Day Commits
    func fetchDayCommits(accessToken: String, date: String, completion: @escaping (Result<[CommitActivity], Error>) -> Void) {
        print("Fetching Commits for Date: \(date)")

        provider.request(.fetchDayCommit(accessToken: accessToken, date: date)) { result in
            switch result {
            case .success(let response):
                print("Response Status Code: \(response.statusCode)")
                if let responseString = String(data: response.data, encoding: .utf8) {
                    print("Response Body: \(responseString)")
                }
                do {
                    let decodedResponse = try JSONDecoder().decode(APIResponse<[CommitActivity]>.self, from: response.data)
                    if decodedResponse.status == "SUCCESS" {
                        print("Decoded Day Commits: \(decodedResponse.data)")
                        completion(.success(decodedResponse.data))
                    } else {
                        print("API Error: \(decodedResponse.message)")
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: decodedResponse.message])))
                    }
                } catch {
                    print("Decoding Error: \(error.localizedDescription)")
                    if let responseString = String(data: response.data, encoding: .utf8) {
                        print("Failed to decode: \(responseString)")
                    }
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Network Request Failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}
