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
    
    let provider: MoyaProvider<CommitAPI>
    
    
    
    init(provider: MoyaProvider<CommitAPI>) {
        
        self.provider = provider   }
    
    func fetchMonthlyCommits(accessToken: String, month: String) -> Single<MonthCommit> {
        
    }
    
    func fetchTodayCommit(accessToken: String) -> RxSwift.Single<[CommitActivity]> {
        <#code#>
    }
    
    func fetchDayCommit(accessToken: String, date: String) -> RxSwift.Single<CommitActivity> {
        <#code#>
    }
}
