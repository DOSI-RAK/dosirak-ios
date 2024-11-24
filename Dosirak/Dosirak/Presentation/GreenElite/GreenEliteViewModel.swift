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
    
    // Fetch correct answers count
    func fetchCorrectAnswers(accessToken: String) -> Single<Int> {
        return provider.rx.request(.fetchCorrect(accessToken: accessToken))
            .filterSuccessfulStatusCodes()
            .map(APIResponse<Int>.self)
            .flatMap { response in
                if response.status == "SUCCESS" {
                    self.correctAnswers.accept(response.data) // 직접 할당
                    return Single.just(response.data)
                } else {
                    let errorMessage = response.exception?.errorMessage ?? "Failed to fetch correct answers"
                    return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
            }
    }
    
    // Fetch incorrect answers count
    func fetchIncorrectAnswers(accessToken: String) -> Single<Int> {
        return provider.rx.request(.fetchIncorrect(accessToken: accessToken))
            .filterSuccessfulStatusCodes()
            .map(APIResponse<Int>.self)
            .flatMap { response in
                if response.status == "SUCCESS" {
                    self.incorrectAnswers.accept(response.data) // 직접 할당
                    return Single.just(response.data)
                } else {
                    let errorMessage = response.exception?.errorMessage ?? "Failed to fetch incorrect answers"
                    return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
            }
    }
    
    // Fetch problem detail
    func fetchProblemDetail(problemId: Int) -> Single<Problem> {
        return provider.rx.request(.fetchProblemDetail(problemId: problemId))
            .filterSuccessfulStatusCodes()
            .map(APIResponse<Problem>.self)
            .flatMap { response in
                if response.status == "SUCCESS" {
                    return Single.just(response.data) // 직접 반환
                } else {
                    let errorMessage = response.exception?.errorMessage ?? "Failed to fetch problem detail"
                    return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
            }
    }
}
