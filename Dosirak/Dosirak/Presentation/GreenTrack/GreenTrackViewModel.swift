//
//  GreenTrackViewModel.swift
//  Dosirak
//
//  Created by 권민재 on 11/27/24.
//

import RxSwift
import RxCocoa
import Moya

class GreenTrackViewModel {
    
    struct Input {
        let fetchBicycleTrigger: Observable<(Double, Double)>
        let recordTrackTrigger: Observable<(String, Double, Double)>
    }
    
    
    struct Output {
        let bicycleData: Driver<[String: Any]>
        let recordTrackResult: Driver<Bool>
        let error: Driver<String>
    }
    

    private let provider: MoyaProvider<TrackAPI>
    private let disposeBag = DisposeBag()
    
    init(provider: MoyaProvider<TrackAPI> = MoyaProvider<TrackAPI>()) {
        self.provider = provider
    }
    
    func transform(input: Input) -> Output {
        let errorSubject = PublishSubject<String>()
        
        
        let bicycleData = input.fetchBicycleTrigger
            .flatMapLatest { [weak self] latitude, longitude -> Observable<[String: Any]> in
                guard let self = self else { return .empty() }
                return self.provider.rx.request(.fetchBicycle(latitude: latitude, longitude: longitude))
                    .asObservable()
                    .mapJSON()
                    .map { $0 as? [String: Any] ?? [:] }
                    .catch { error in
                        errorSubject.onNext("Failed to fetch bicycle data: \(error.localizedDescription)")
                        return .just([:])
                    }
            }
            .asDriver(onErrorJustReturn: [:])
        
        let recordTrackResult = input.recordTrackTrigger
            .flatMapLatest { [weak self] accessToken, shortestDistance, moveDistance -> Observable<Bool> in
                guard let self = self else { return .empty() }
                return self.provider.rx.request(.recordTrackData(accessToken: accessToken, shortestDistance: shortestDistance, moveDistance: moveDistance))
                    .asObservable()
                    .map { $0.statusCode == 200 }
                    .catch { error in
                        errorSubject.onNext("Failed to record track data: \(error.localizedDescription)")
                        return .just(false)
                    }
            }
            .asDriver(onErrorJustReturn: false)
        
    
        let error = errorSubject.asDriver(onErrorJustReturn: "An unknown error occurred.")
        
        return Output(
            bicycleData: bicycleData,
            recordTrackResult: recordTrackResult,
            error: error
        )
    }
}
