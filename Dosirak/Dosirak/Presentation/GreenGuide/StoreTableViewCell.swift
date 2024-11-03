//
//  StoreTableViewCell.swift
//  Dosirak
//
//  Created by 권민재 on 11/2/24.
//
import UIKit
import SnapKit

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
        
        // 아이콘 이미지 뷰
        iconImageView.image = UIImage(systemName: "building.2.fill")
        iconImageView.tintColor = .gray
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.layer.cornerRadius = 8
        iconImageView.clipsToBounds = true
        
        // 상점명 라벨
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 1
        
        // 거리 라벨
        distanceLabel.font = .systemFont(ofSize: 14)
        distanceLabel.textColor = .gray
        
        // 상태 라벨 (운영중, 운영종료 등)
        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.textColor = .red  // 운영 종료일 경우 빨간색으로 표시
        statusLabel.textAlignment = .right
        
        // 혜택 라벨
        benefitLabel.font = .systemFont(ofSize: 12)
        benefitLabel.textColor = .systemBlue
        benefitLabel.text = "다회용기 혜택 제공 가게"
    }
    
    private func setupLayout() {
        // 아이콘 이미지 뷰 레이아웃
        iconImageView.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview().inset(10)
            $0.width.height.equalTo(50)
        }
        
        // 혜택 라벨 레이아웃
        benefitLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(10)
            $0.top.equalToSuperview().inset(10)
        }
        
        // 상점명 라벨 레이아웃
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(10)
            $0.top.equalTo(benefitLabel.snp.bottom).offset(2)
            $0.trailing.lessThanOrEqualTo(statusLabel.snp.leading).offset(-10)
        }
        
        // 거리 라벨 레이아웃
        distanceLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.bottom.equalToSuperview().inset(10)
        }
        
        // 상태 라벨 레이아웃
        statusLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.top.equalToSuperview().inset(10)
        }
    }
    
    // 셀 데이터 설정 메서드
    func configure(store: Store) {
        titleLabel.text = store.storeName
        distanceLabel.text = "500m"
        statusLabel.text = store.ifValid
        benefitLabel.text = store.ifReward
        statusLabel.textColor = store.storeCategory == "운영종료" ? .gray : .systemRed
    }
}
