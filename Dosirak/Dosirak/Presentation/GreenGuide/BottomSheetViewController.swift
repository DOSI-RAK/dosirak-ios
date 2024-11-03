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

class BottomSheetViewController: UIViewController {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    let tableView = UITableView()
    var reactor:
    GreenGuideReactor? // GuideReactor를 사용하기 위한 프로퍼티
    
    // MARK: - Life Cycle
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
    }
    
    // MARK: - Reactor Binding
    func bind(reactor: GreenGuideReactor) {
        // 상점 목록 데이터를 tableView에 바인딩
        reactor.state
            .map { $0.stores }
            .bind(to: tableView.rx.items(cellIdentifier: StoreTableViewCell.identifier, cellType: StoreTableViewCell.self)) { index, store, cell in
                cell.configure(store: store)
            }
            .disposed(by: disposeBag)
        
        // 로딩 상태 표시
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .subscribe(onNext: { isLoading in
                if isLoading {
                    print("Loading...")
                } else {
                    print("Loading finished.")
                }
            })
            .disposed(by: disposeBag)
    }
}
