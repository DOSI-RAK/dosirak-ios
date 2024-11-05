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
       
        reactor.state
            .map { $0.stores }
            .bind(to: tableView.rx.items(cellIdentifier: StoreTableViewCell.identifier, cellType: StoreTableViewCell.self)) { index, store, cell in
                cell.configure(store: store)
            }
            .disposed(by: disposeBag)
        

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




extension BottomSheetViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
