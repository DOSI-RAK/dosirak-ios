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
        let totalRanks: PublishRelay<[Rank]>
        let myRank: PublishRelay<Rank?>
        let isLoading: PublishRelay<Bool>
        let error: PublishRelay<String>
    }
    
    private let disposeBag = DisposeBag()
    private let provider = MoyaProvider<HeroAPI>()
    
    func transform(input: Input) -> Output {
        let totalRanks = PublishRelay<[Rank]>()
        let myRank = PublishRelay<Rank?>()
        let isLoading = PublishRelay<Bool>()
        let error = PublishRelay<String>()
        
        input.fetchTotalRankTrigger
            .flatMapLatest { [weak self] _ -> Observable<Event<[Rank]>> in
                guard let self = self else { return Observable.empty() }
                print("[DEBUG] fetchTotalRankTrigger triggered.")
                isLoading.accept(true)
                return self.fetchTotalRanks()
                    .asObservable()
                    .materialize()
            }
            .subscribe(onNext: { event in
                isLoading.accept(false)
                switch event {
                case .next(let ranks):
                    print("[DEBUG] Total ranks fetched successfully. Count: \(ranks.count)")
                    totalRanks.accept(ranks)
                case .error(let apiError):
                    print("[DEBUG] Failed to fetch total ranks: \(apiError.localizedDescription)")
                    error.accept("전체 랭킹 데이터를 가져오는 데 실패했습니다: \(apiError.localizedDescription)")
                case .completed:
                    print("[DEBUG] fetchTotalRankTrigger completed.")
                }
            })
            .disposed(by: disposeBag)
        
        input.fetchMyRankTrigger
            .flatMapLatest { [weak self] _ -> Observable<Event<Rank>> in
                guard let self = self else { return Observable.empty() }
                print("[DEBUG] fetchMyRankTrigger triggered.")
                isLoading.accept(true)
                return self.fetchMyRank()
                    .asObservable()
                    .materialize()
            }
            .subscribe(onNext: { event in
                isLoading.accept(false)
                switch event {
                case .next(let rank):
                    print("[DEBUG] My rank fetched successfully: \(rank)")
                    myRank.accept(rank)
                case .error(let apiError):
                    print("[DEBUG] Failed to fetch my rank: \(apiError.localizedDescription)")
                    error.accept("내 랭킹 데이터를 가져오는 데 실패했습니다: \(apiError.localizedDescription)")
                case .completed:
                    print("[DEBUG] fetchMyRankTrigger completed.")
                }
            })
            .disposed(by: disposeBag)
        
        return Output(
            totalRanks: totalRanks,
            myRank: myRank,
            isLoading: isLoading,
            error: error
        )
    }
    
    private func fetchTotalRanks() -> Single<[Rank]> {
        print("[DEBUG] Sending request to fetchTotalRanks.")
        return provider.rx
            .request(.fetchTotalRank(accessToken: AppSettings.accessToken ?? ""))
            .filterSuccessfulStatusCodes()
            .do(onSuccess: { response in
                print("[DEBUG] Response received for fetchTotalRanks: StatusCode: \(response.statusCode), Data Length: \(response.data.count)")
                if let jsonString = String(data: response.data, encoding: .utf8) {
                    print("[DEBUG] Response JSON for fetchTotalRanks: \(jsonString)")
                }
            }, onError: { error in
                print("[DEBUG] Error during fetchTotalRanks request: \(error.localizedDescription)")
            })
            .map(APIResponse<[Rank]>.self)
            .map { $0.data }
    }
    
    private func fetchMyRank() -> Single<Rank> {
        print("[DEBUG] Sending request to fetchMyRank.")
        return provider.rx
            .request(.fetchMyRank(accessToken: AppSettings.accessToken ?? ""))
            .filterSuccessfulStatusCodes()
            .do(onSuccess: { response in
                print("[DEBUG] Response received for fetchMyRank: StatusCode: \(response.statusCode), Data Length: \(response.data.count)")
                if let jsonString = String(data: response.data, encoding: .utf8) {
                    print("[DEBUG] Response JSON for fetchMyRank: \(jsonString)")
                }
            }, onError: { error in
                print("[DEBUG] Error during fetchMyRank request: \(error.localizedDescription)")
            })
            .map(APIResponse<Rank>.self)
            .map { $0.data }
    }
}
