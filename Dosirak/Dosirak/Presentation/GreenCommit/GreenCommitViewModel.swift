//
//  GreenCommitViewModel.swift
//  Dosirak
//
//  Created by 권민재 on 11/6/24.
//
import RxSwift
import RxCocoa
import Moya

class GreenCommitViewModel {
    // Provider와 Access Token 설정
    var provider = MoyaProvider<CommitAPI>(plugins: [NetworkLoggerPlugin()]) // 네트워크 로그 플러그인 추가
    var accessToken = AppSettings.accessToken

    // Input
    struct Input {
        let fetchMonthlyCommitsTrigger: Observable<String> // month
        let fetchTodayCommitTrigger: Observable<Void>
        let fetchDayCommitTrigger: Observable<String> // date
    }
    
    // Output
    struct Output {
        let monthlyCommits: Driver<MonthCommit>
        let todayCommits: Driver<[CommitActivity]>
        let dayCommit: Driver<CommitActivity>
        let error: Driver<String>
    }
    
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let errorRelay = PublishRelay<String>()
        
        let monthlyCommits = input.fetchMonthlyCommitsTrigger
            .map { month -> String in
                // "2023-11" -> "2023-11-01"
                return "\(month)-01"
            }
            .flatMapLatest { formattedMonth in
                self.provider.rx.request(.fetchMonthlyCommits(accessToken: self.accessToken ?? "", month: formattedMonth))
                    .do(onSuccess: { response in
                        print("Monthly Commits Request Successful")
                        print("Status Code: \(response.statusCode)")
                        print("Response Body: \(String(data: response.data, encoding: .utf8) ?? "No data")")
                    }, onError: { error in
                        print("Monthly Commits Request Failed: \(error.localizedDescription)")
                    })
                    .filterSuccessfulStatusCodes()
                    .map(APIResponse<MonthCommit>.self)
                    .do(onSuccess: { response in
                        print("Parsed Monthly Commits Response: \(response)")
                    }, onError: { error in
                        print("Error Parsing Monthly Commits: \(error.localizedDescription)")
                    })
                    .asObservable()
                    .catch { error in
                        errorRelay.accept(error.localizedDescription)
                        return .empty()
                    }
            }
            .compactMap { response -> MonthCommit? in
                response.status == "SUCCESS" ? response.data : nil
            }
            .asDriver(onErrorDriveWith: .empty())
        
        // Fetch today's commits
        let todayCommits = input.fetchTodayCommitTrigger
            .flatMapLatest {
                self.provider.rx.request(.fetchTodayCommit(accessToken: self.accessToken ?? ""))
                    .do(onSuccess: { response in
                        print("Today's Commits Request Successful")
                        print("Status Code: \(response.statusCode)")
                        print("Response Body: \(String(data: response.data, encoding: .utf8) ?? "No data")")
                    }, onError: { error in
                        print("Today's Commits Request Failed: \(error.localizedDescription)")
                    })
                    .filterSuccessfulStatusCodes()
                    .map(APIResponse<[CommitActivity]>.self)
                    .do(onSuccess: { response in
                        print("Parsed Today's Commits Response: \(response)")
                    }, onError: { error in
                        print("Error Parsing Today's Commits: \(error.localizedDescription)")
                    })
                    .asObservable()
                    .catch { error in
                        errorRelay.accept(error.localizedDescription)
                        return .empty()
                    }
            }
            .compactMap { response -> [CommitActivity]? in
                response.status == "SUCCESS" ? response.data : nil
            }
            .asDriver(onErrorDriveWith: .empty())
        
        // Fetch specific day's commit
        let dayCommit = input.fetchDayCommitTrigger
            .flatMapLatest { date in
                self.provider.rx.request(.fetchDayCommit(accessToken: self.accessToken ?? "", date: date))
                    .do(onSuccess: { response in
                        print("Day Commit Request Successful")
                        print("Status Code: \(response.statusCode)")
                        print("Response Body: \(String(data: response.data, encoding: .utf8) ?? "No data")")
                    }, onError: { error in
                        print("Day Commit Request Failed: \(error.localizedDescription)")
                    })
                    .filterSuccessfulStatusCodes()
                    .map(APIResponse<CommitActivity>.self)
                    .do(onSuccess: { response in
                        print("Parsed Day Commit Response: \(response)")
                    }, onError: { error in
                        print("Error Parsing Day Commit: \(error.localizedDescription)")
                    })
                    .asObservable()
                    .catch { error in
                        errorRelay.accept(error.localizedDescription)
                        return .empty()
                    }
            }
            .compactMap { response -> CommitActivity? in
                response.status == "SUCCESS" ? response.data : nil
            }
            .asDriver(onErrorDriveWith: .empty())
        
        // 에러 로그 출력
        errorRelay
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { error in
                print("Error Occurred: \(error)")
            })
            .disposed(by: disposeBag)
        
        return Output(
            monthlyCommits: monthlyCommits,
            todayCommits: todayCommits,
            dayCommit: dayCommit,
            error: errorRelay.asDriver(onErrorDriveWith: .empty())
        )
    }
}
