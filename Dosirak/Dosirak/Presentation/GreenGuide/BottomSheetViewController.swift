//
//  BottomSheetViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/2/24.
//

import UIKit
import SnapKit
import RxSwift
import ReactorKit

class BottomSheetViewController: UIViewController, View {
   
    var disposeBag = DisposeBag()
    let tableView = UITableView()
    let storeSelected = PublishSubject<Store>()
    
    var reactor: GreenGuideReactor? {
        didSet {
            if let reactor = reactor {
                self.bind(reactor: reactor)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        tableView.register(StoreTableViewCell.self, forCellReuseIdentifier: StoreTableViewCell.identifier)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    func bind(reactor: GreenGuideReactor) {
           // Reactor 상태의 검색 결과와 일반 리스트를 합쳐서 테이블 뷰에 바인딩
           Observable.combineLatest(
               reactor.state.map { $0.searchResults },   // 검색 결과
               reactor.state.map { $0.stores },         // 전체 상점 리스트
               reactor.state.map { $0.categoryStores }, // 카테고리별 상점 리스트
               reactor.state.map { $0.selectedCategory } // 선택된 카테고리
           )
           .map { searchResults, stores, categoryStores, selectedCategory -> [Store] in
               if !searchResults.isEmpty {
                   // 검색어가 있을 때는 검색 결과만 반환
                   return searchResults
               } else {
                   // 검색어가 없을 때는 카테고리에 따라 리스트 반환
                   return selectedCategory == "전체" ? stores : categoryStores
               }
           }
           .bind(to: tableView.rx.items(cellIdentifier: StoreTableViewCell.identifier, cellType: StoreTableViewCell.self)) { index, store, cell in
               // 강남역 기준 거리 계산
               let coordinate = AppSettings.userLocation
               let distance = self.haversineDistance(
                   lat1: coordinate.latitude,
                   lon1: coordinate.longitude,
                   lat2: store.mapY,
                   lon2: store.mapX
               ) / 1000.0
               
               cell.configure(store: store, distance: distance)
           }
           .disposed(by: disposeBag)
           
           tableView.rx
               .modelSelected(Store.self)
               .bind(to: storeSelected)
               .disposed(by: disposeBag)
       }
    func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let radius: Double = 6371000
        
        let dLat = degreesToRadians(lat2 - lat1)
        let dLon = degreesToRadians(lon2 - lon1)
        
        let a = sin(dLat / 2) * sin(dLat / 2) +
                cos(degreesToRadians(lat1)) * cos(degreesToRadians(lat2)) *
                sin(dLon / 2) * sin(dLon / 2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        return radius * c
    }
    func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * .pi / 180
    }
    
}

extension BottomSheetViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
