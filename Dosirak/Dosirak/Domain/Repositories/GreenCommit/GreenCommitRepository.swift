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
    
}
