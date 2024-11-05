//
//  StoreTableViewCell.swift
//  Dosirak
//
//  Created by 권민재 on 11/2/24.
//
import UIKit
import SnapKit
import Kingfisher

class StoreTableViewCell: UITableViewCell {
    static let identifier = "StoreTableViewCell"
    
    // UI Components
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let distanceLabel = UILabel()
    private let statusLabel = UILabel()
    private let benefitLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(distanceLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(benefitLabel)
        
        
        iconImageView.image = UIImage(systemName: "building.2.fill")
        iconImageView.tintColor = .gray
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.layer.cornerRadius = 8
        iconImageView.clipsToBounds = true
        
      
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 1
        
       
        distanceLabel.font = .systemFont(ofSize: 14)
        distanceLabel.textColor = .gray
        
      
        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.textColor = .red  // 운영 종료일 경우 빨간색으로 표시
        statusLabel.textAlignment = .right
        
   
        benefitLabel.font = .systemFont(ofSize: 12)
        benefitLabel.textColor = .systemBlue
        benefitLabel.text = "다회용기 혜택 제공 가게"
    }
    
    private func setupLayout() {
        
      
        iconImageView.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview().inset(10)
            $0.width.height.equalTo(90)
        }
        
       
        benefitLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(10)
            $0.top.equalToSuperview().inset(10)
        }
        
      
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(10)
            $0.top.equalTo(benefitLabel.snp.bottom).offset(2)
            $0.trailing.lessThanOrEqualTo(statusLabel.snp.leading).offset(-10)
        }
        
     
        distanceLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.bottom.equalToSuperview().inset(10)
        }
        
    
        statusLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.top.equalToSuperview().inset(10)
        }
    }
    
  
    func configure(store: Store) {
        titleLabel.text = store.storeName
        let url = URL(string: store.storeImg)
        iconImageView.kf.setImage(with: url)
        distanceLabel.text = "500m"
        if store.ifReward == " YES" {
            benefitLabel.text = "다회용기 혜택 제공 가게"
        }else {
            benefitLabel.text = nil
        }
        if store.ifValid == " YES" {
            statusLabel.text = "운영중"
            statusLabel.textColor = .red
        } else {
            statusLabel.text = "운영종료"
            statusLabel.textColor = .lightGray
        }
    }
}
