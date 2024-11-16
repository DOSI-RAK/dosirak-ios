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
    let gangnamLatitude = 37.497942
    let gangnamLongitude = 127.027621
    
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
        reactor.state
            .map { state -> [Store] in
                state.selectedCategory == "전체" ? state.stores : state.categoryStores
            }
            .bind(to: tableView.rx.items(cellIdentifier: StoreTableViewCell.identifier, cellType: StoreTableViewCell.self)) { index, store, cell in
                // 강남역 기준 거리 계산
                let distance = self.haversineDistance(
                    lat1: self.gangnamLatitude,
                    lon1: self.gangnamLongitude,
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
        let radius: Double = 6371000 // 지구의 반지름 (미터)
        
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
