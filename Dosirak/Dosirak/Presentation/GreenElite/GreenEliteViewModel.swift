//
//  GreenEliteViewModel.swift
//  Dosirak
//
//  Created by 권민재 on 11/24/24.
//
import RxSwift
import RxRelay
import Moya
import Foundation

class GreenEliteViewModel {
    
    private let provider = MoyaProvider<EliteAPI>()
    
    // Outputs
    let userProfile = BehaviorRelay<EliteUserInfo?>(value: nil)
    let todayProblem = BehaviorRelay<TodayProblem?>(value: nil)
    let correctAnswers = BehaviorRelay<Int>(value: 0)
    let incorrectAnswers = BehaviorRelay<Int>(value: 0)
    
    // Fetch user information
    func fetchUserInfo(accessToken: String) -> Single<EliteUserInfo> {
        return provider.rx.request(.fetchUserInfo(accessToken: accessToken))
            .filterSuccessfulStatusCodes()
            .map(APIResponse<EliteUserInfo>.self)
            .flatMap { response in
                if response.status == "SUCCESS" {
                    self.userProfile.accept(response.data) // 직접 할당
                    return Single.just(response.data)
                } else {
                    let errorMessage = response.exception?.errorMessage ?? "Failed to fetch user info"
                    return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
            }
    }
    
    // Fetch today's problem
    func fetchTodayProblem(accessToken: String) -> Single<TodayProblem> {
        return provider.rx.request(.fetchTodayProblem(accessToken: accessToken))
            .filterSuccessfulStatusCodes()
            .map(APIResponse<TodayProblem>.self)
            .flatMap { response in
                if response.status == "SUCCESS" {
                    self.todayProblem.accept(response.data) // 직접 할당
                    return Single.just(response.data)
                } else {
                    let errorMessage = response.exception?.errorMessage ?? "Failed to fetch today's problem"
                    return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
            }
    }
    
    func fetchCorrectAnswers(accessToken: String) -> Single<[Problem]> {
        return provider.rx.request(.fetchCorrect(accessToken: accessToken))
            .filterSuccessfulStatusCodes()
            .map(APIResponse<[Problem]>.self) // 배열로 디코딩
            .flatMap { response in
                if response.status == "SUCCESS" {
                    return Single.just(response.data)
                } else {
                    let errorMessage = response.exception?.errorMessage ?? "Failed to fetch correct answers"
                    return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
            }
    }
    
    func fetchIncorrectAnswers(accessToken: String) -> Single<[Problem]> {
        return provider.rx.request(.fetchIncorrect(accessToken: accessToken))
            .filterSuccessfulStatusCodes()
            .map(APIResponse<[Problem]>.self) // 배열로 디코딩
            .flatMap { response in
                if response.status == "SUCCESS" {
                    return Single.just(response.data)
                } else {
                    let errorMessage = response.exception?.errorMessage ?? "Failed to fetch incorrect answers"
                    return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
            }
    }
    
    // Fetch problem detail
    func fetchProblemDetail(problemId: Int) -> Single<TodayProblem> {
        return provider.rx.request(.fetchProblemDetail(problemId: problemId))
            .filterSuccessfulStatusCodes()
            .map(APIResponse<TodayProblem>.self)
            .flatMap { response in
                if response.status == "SUCCESS" {
                    return Single.just(response.data) // 직접 반환
                } else {
                    let errorMessage = response.exception?.errorMessage ?? "Failed to fetch problem detail"
                    return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
            }
    }
    
    func recordAnswer(accessToken: String, problemId: Int, isCorrect: Bool) -> Single<Void> {
        // 요청 정보 출력
        print("=== Record Answer Request ===")
        print("Access Token: \(accessToken)")
        print("Problem ID: \(problemId)")
        print("Is Correct: \(isCorrect)")
        
        return provider.rx.request(.recordAnswer(accessToken: accessToken, problemId: problemId, isCorrect: isCorrect))
            .do(onSuccess: { response in
                // 응답 성공 시 디버깅 출력
                print("=== Response ===")
                print("Status Code: \(response.statusCode)")
                if let responseString = String(data: response.data, encoding: .utf8) {
                    print("Response Data: \(responseString)")
                } else {
                    print("Response Data: Unable to decode response data")
                }
            }, onError: { error in
                // 요청 실패 시 디버깅 출력
                if let moyaError = error as? MoyaError {
                    switch moyaError {
                    case .statusCode(let response):
                        print("=== Error Response ===")
                        print("Status Code: \(response.statusCode)")
                        if let responseString = String(data: response.data, encoding: .utf8) {
                            print("Error Data: \(responseString)")
                        } else {
                            print("Error Data: Unable to decode response data")
                        }
                    case .underlying(let nsError as NSError, _):
                        print("Underlying Error: \(nsError.localizedDescription)")
                    default:
                        print("Moya Error: \(moyaError.localizedDescription)")
                    }
                } else {
                    print("Unexpected Error: \(error.localizedDescription)")
                }
            })
            .filterSuccessfulStatusCodes()
            .map(APIResponse<Empty>.self)
            .flatMap { response in
                if response.status == "SUCCESS" {
                    print("Answer recorded successfully: \(isCorrect ? "Correct" : "Incorrect")")
                    return Single.just(())
                } else {
                    let errorMessage = response.exception?.errorMessage ?? "Failed to record answer"
                    print("Server returned failure: \(errorMessage)")
                    return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
            }
    }

    
    
}
