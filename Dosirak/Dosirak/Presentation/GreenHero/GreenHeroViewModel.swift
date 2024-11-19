//
//  GreenHeroViewModel.swift
//  Dosirak
//
//  Created by 권민재 on 11/17/24.
import Moya
import RxSwift
import RxCocoa

class GreenHeroViewModel {
    struct Input {
        let fetchTotalRankTrigger: PublishRelay<Void>
        let fetchMyRankTrigger: PublishRelay<Void>
    }
    
    struct Output {
        let firstRank: Driver<Rank?>
        let secondRank: Driver<Rank?>
        let thirdRank: Driver<Rank?>
        let myRank: Driver<Rank?>
        let rankList: Driver<[Rank]>
        let error: Driver<String>
    }
    
    private let disposeBag = DisposeBag()
    private let provider = MoyaProvider<HeroAPI>()
    
    func transform(input: Input) -> Output {
        let rankCards = BehaviorRelay<[Rank]>(value: [])
        let myRank = BehaviorRelay<Rank?>(value: nil)
        let rankList = BehaviorRelay<[Rank]>(value: [])
        let error = PublishRelay<String>()
        
        input.fetchTotalRankTrigger
            .flatMapLatest { [weak self] _ -> Observable<[Rank]> in
                guard let self = self else { return Observable.empty() }
                return self.fetchTotalRanks()
                    .asObservable()
                    .catch { err in
                        error.accept(err.localizedDescription)
                        return .empty()
                    }
            }
            .subscribe(onNext: { ranks in
                print("[DEBUG] All Ranks: \(ranks)")
                rankCards.accept(ranks)
                rankList.accept(Array(ranks.dropFirst(3)))
            })
            .disposed(by: disposeBag)

        input.fetchMyRankTrigger
            .flatMapLatest { [weak self] _ -> Observable<Rank?> in
                guard let self = self else { return Observable.empty() }
                return self.fetchMyRank()
                    .asObservable()
                    .catch { err in
                        error.accept(err.localizedDescription)
                        return .just(nil)
                    }
            }
            .bind(to: myRank)
            .disposed(by: disposeBag)

        let firstRank = rankCards.map { $0.first }.asDriver(onErrorJustReturn: nil)
        let secondRank = rankCards.map { $0.dropFirst().first }.asDriver(onErrorJustReturn: nil)
        let thirdRank = rankCards.map { $0.dropFirst(2).first }.asDriver(onErrorJustReturn: nil)

        return Output(
            firstRank: firstRank,
            secondRank: secondRank,
            thirdRank: thirdRank,
            myRank: myRank.asDriver(onErrorJustReturn: nil),
            rankList: rankList.asDriver(onErrorJustReturn: []),
            error: error.asDriver(onErrorJustReturn: "")
        )
    }
    
    private func fetchTotalRanks() -> Single<[Rank]> {
        return provider.rx
            .request(.fetchTotalRank(accessToken: AppSettings.accessToken ?? ""))
            .do(onSuccess: { response in
                print("[DEBUG] Total Ranks Response: \(response)")
                if let jsonString = String(data: response.data, encoding: .utf8) {
                    print("[DEBUG] Total Ranks JSON: \(jsonString)")
                }
            })
            .map(APIResponse<[Rank]>.self)
            .map { $0.data }
    }

    private func fetchMyRank() -> Single<Rank?> {
        return provider.rx
            .request(.fetchMyRank(accessToken: AppSettings.accessToken ?? ""))
            .do(onSuccess: { response in
                print("[DEBUG] My Rank Response: \(response)")
                if let jsonString = String(data: response.data, encoding: .utf8) {
                    print("[DEBUG] My Rank JSON: \(jsonString)")
                }
            })
            .map(APIResponse<Rank>.self)
            .map { $0.data }
    }
}
