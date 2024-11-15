//
//  GreenCommitUsecase.swift
//  Dosirak
//
//  Created by 권민재 on 11/15/24.
//
import RxSwift
import Foundation

protocol CommitUsecaseType {
    func getMonthlyCommits(month: String) -> Single<MonthCommit>
    func getTodayCommit() -> Single<[CommitActivity]>
    func getDayCommit(date: String) -> Single<CommitActivity>
}

//class CommitUsecase: CommitUsecaseType {
//
//    private let commitRepository: CommitRepositoryType
//
//    init(repository: CommitRepositoryType) {
//        self.commitRepository = repository
//    }
//
//
//    func getMonthlyCommits(month: String) -> Single<MonthCommit> {
//        <#code#>
//    }
//
//    func getTodayCommit() -> Single<[CommitActivity]> {
//        <#code#>
//    }
//
//    func getDayCommit(date: String) -> Single<CommitActivity> {
//        <#code#>
//    }
//
//
//}
