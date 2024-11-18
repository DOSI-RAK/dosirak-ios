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
        return provider.rx
            .request(.fetchTotalRank(accessToken: AppSettings.accessToken ?? ""))
            .do(onSuccess: { response in
                print("[DEBUG] Response StatusCode: \(response.statusCode)")
                if let jsonString = String(data: response.data, encoding: .utf8) {
                    print("[DEBUG] Raw JSON: \(jsonString)")
                }
            })
            .map(APIResponse<[Rank]>.self)
            .map { $0.data }
    }

    private func fetchMyRank() -> Single<Rank> {
        print("[DEBUG] fetchMyRank called.")
        return provider.rx
            .request(.fetchMyRank(accessToken: AppSettings.accessToken ?? ""))
            .do(onSuccess: { response in
                print("[DEBUG] Response received for fetchMyRank:")
                print("[DEBUG] StatusCode: \(response.statusCode)")
                if let jsonString = String(data: response.data, encoding: .utf8) {
                    print("[DEBUG] Response JSON: \(jsonString)")
                }
            }, onError: { error in
                print("[DEBUG] fetchMyRank error: \(error)")
            })
            .filterSuccessfulStatusCodes()
            .map(APIResponse<Rank>.self)
            .map { apiResponse in
                print("[DEBUG] Parsed My Rank: \(apiResponse.data)")
                return apiResponse.data
            }
    }
}
