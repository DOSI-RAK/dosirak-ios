//
//  GreenClubViewModel.swift
//  Dosirak
//
//  Created by 권민재 on 11/17/24.
//

import RxSwift
import RxCocoa
import Moya
import Foundation

class SaleStoresViewModel {
    
    // Input
    struct Input {
        let fetchTrigger: PublishRelay<Void>
        let address: BehaviorRelay<String>
    }
    
    // Output
    struct Output {
        let saleStores: PublishRelay<[SaleStore]>
        let isLoading: PublishRelay<Bool>
        let error: PublishRelay<String>
    }
    
    private let disposeBag = DisposeBag()
    private let provider = MoyaProvider<ClubAPI>()
    
    func transform(input: Input) -> Output {
        let saleStores = PublishRelay<[SaleStore]>()
        let isLoading = PublishRelay<Bool>()
        let error = PublishRelay<String>()
        
        input.fetchTrigger
            .withLatestFrom(input.address) // address 값 가져오기
            .flatMapLatest { [weak self] address -> Observable<Event<[SaleStore]>> in
                guard let self = self else { return Observable.empty() }
                
                isLoading.accept(true)
                return self.fetchSaleStores(address: address)
                    .asObservable()
                    .materialize()
            }
            .subscribe(onNext: { event in
                isLoading.accept(false)
                switch event {
                case .next(let stores):
                    saleStores.accept(stores)
                case .error(let apiError):
                    error.accept("Failed to fetch stores: \(apiError.localizedDescription)")
                case .completed:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        return Output(saleStores: saleStores, isLoading: isLoading, error: error)
    }
    
    private func fetchSaleStores(address: String) -> Single<[SaleStore]> {
        return provider.rx
            .request(.fetchSaleStores(accessToken: AppSettings.accessToken ?? "", address: address))
            .filterSuccessfulStatusCodes()
            .map { response in
                do {
                    let decodedResponse = try JSONDecoder().decode(APIResponse<[SaleStore]>.self, from: response.data)
                    return decodedResponse.data.map { store in
                        var mutableStore = store
                        // 거리 계산 추가
                        mutableStore.distance = Double(self.calculateDistance(
                            lat1: 37.497942, lon1: 127.027621,
                            lat2: Double(store.saleMapY)!, lon2: Double(store.saleMapX)!
                        ))
                        return mutableStore
                    }
                } catch {
                    // 디코딩 오류를 자세히 출력
                    if let decodingError = error as? DecodingError {
                        self.printDecodingError(decodingError, data: response.data)
                    } else {
                        print("Unknown error during decoding: \(error)")
                    }
                    throw error
                }
            }
    }

    private func printDecodingError(_ error: DecodingError, data: Data) {
        switch error {
        case .dataCorrupted(let context):
            print("Data corrupted: \(context.debugDescription)")
        case .keyNotFound(let key, let context):
            print("Key '\(key.stringValue)' not found:", context.debugDescription)
            print("CodingPath:", context.codingPath)
        case .typeMismatch(let type, let context):
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("CodingPath:", context.codingPath)
        case .valueNotFound(let type, let context):
            print("Value '\(type)' not found:", context.debugDescription)
            print("CodingPath:", context.codingPath)
        @unknown default:
            print("Unknown decoding error")
        }
        // 원본 JSON 출력 (문제가 되는 데이터를 확인)
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw JSON: \(jsonString)")
        }
    }

    private func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Int {
        let earthRadius = 6371.0 // 지구 반지름 (km)
        let dLat = (lat2 - lat1) * .pi / 180.0
        let dLon = (lon2 - lon1) * .pi / 180.0

        let a = sin(dLat / 2) * sin(dLat / 2) +
                cos(lat1 * .pi / 180.0) * cos(lat2 * .pi / 180.0) *
                sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))

        let distanceInKm = earthRadius * c
        let distanceInMeters = distanceInKm * 1000 // km to m
        return Int(distanceInMeters) // 소수점 버림
    }
}
