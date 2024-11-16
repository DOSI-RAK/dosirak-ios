//
//  SotreCell.swift
//  Dosirak
//
//  Created by 권민재 on 11/17/24.
//

import UIKit
import SnapKit
import Kingfisher

// MARK: - Custom StoreCell
class StoreCell: UITableViewCell {
    static let identifier = "StoreCell"
    
    private let storeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let storeNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "가게 이름"
        return label
    }()
    
    private let discountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .red
        label.textAlignment = .center
        label.text = "20%"
        return label
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let discountTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .blue
        label.text = "할인 시간"
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(storeImageView)
        contentView.addSubview(storeNameLabel)
        contentView.addSubview(discountLabel)
        contentView.addSubview(distanceLabel)
        contentView.addSubview(discountTimeLabel)
    }
    
    private func setupConstraints() {
        storeImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        storeNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(storeImageView.snp.trailing).offset(16)
            make.top.equalToSuperview().offset(10)
        }
        
        discountTimeLabel.snp.makeConstraints { make in
            make.leading.equalTo(storeNameLabel)
            make.top.equalTo(storeNameLabel.snp.bottom).offset(4)
        }
        
        distanceLabel.snp.makeConstraints { make in
            make.leading.equalTo(storeNameLabel)
            make.top.equalTo(discountTimeLabel.snp.bottom).offset(4)
        }
        
        discountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(with item: SaleStore) {
        storeNameLabel.text = item.saleStoreName
        discountLabel.text = String(item.saleDiscount)
        discountTimeLabel.text = item.saleOperationTime
        storeImageView.kf.setImage(with: URL(string: item.saleStoreImg))
    }
}
