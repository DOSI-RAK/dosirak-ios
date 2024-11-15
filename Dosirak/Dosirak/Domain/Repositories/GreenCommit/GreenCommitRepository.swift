//
//  GreenCommitRepository.swift
//  Dosirak
//
//  Created by 권민재 on 11/10/24.
//

import UIKit
import RxSwift
import Moya

protocol CommitRepositoryType {
    func fetchMonthlyCommits(accessToken: String, month: String) -> Single<MonthCommit>
    func fetchTodayCommit(accessToken: String) -> Single<[CommitActivity]>
    func fetchDayCommit(accessToken: String, date: String) -> Single<CommitActivity>
    
    
}

class CommitRepository: CommitRepositoryType {
    
    
    private let provider: MoyaProvider<CommitAPI>
    private let accessToken: String
    
    
    
    init(provider: MoyaProvider<CommitAPI>, accessToken: String) {
        
        self.provider = provider
        self.accessToken = accessToken
    }
    
    func fetchMonthlyCommits(accessToken: String, month: String) -> Single<MonthCommit> {
        print("Calling fetchMonthlyCommits")
        return provider.rx.request(.fetchMonthlyCommits(accessToken: accessToken, month: month))
            .filterSuccessfulStatusCodes()
            .map(APIResponse<MonthCommit>.self)
            .flatMap { response in
                if response.status == "SUCCESS" {
                    return Single.just(response.data)
                } else {
                    return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch chat room summary"]))
                }
            }
    }
    
    func fetchTodayCommit(accessToken: String) -> Single<[CommitActivity]> {
        return provider.rx.request(.fetchTodayCommit(accessToken: accessToken))
            .filterSuccessfulStatusCodes()
            .map(APIResponse<[CommitActivity]>.self)
            .flatMap { response in
                if response.status == "SUCCESS" {
                    return Single.just(response.data)
                } else {
                    return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch chat room summary"]))
                }
            }
    }
    
    func fetchDayCommit(accessToken: String, date: String) -> Single<CommitActivity> {
        return provider.rx.request(.fetchDayCommit(accessToken: accessToken, date: date))
            .filterSuccessfulStatusCodes()
            .map(APIResponse<CommitActivity>.self)
            .flatMap { response in
                if response.status == "SUCCESS" {
                    return Single.just(response.data)
                } else {
                    return Single.error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch chat room summary"]))
                }
            }
    }
    
}
