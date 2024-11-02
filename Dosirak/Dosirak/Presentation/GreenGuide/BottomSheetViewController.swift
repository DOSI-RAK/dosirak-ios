//
//  BottomSheetViewController.swift
//  Dosirak
//
//  Created by 권민재 on 11/2/24.
//

import UIKit

class BottomSheetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(StoreTableViewCell.self, forCellReuseIdentifier: StoreTableViewCell.identifier)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
    }
    
    // TableView DataSource & Delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StoreTableViewCell.identifier, for: indexPath) as? StoreTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(title: "가게 이름 \(indexPath.row)", distance: "\(indexPath.row * 100)m", status: "운영중")
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 100
        }
}
