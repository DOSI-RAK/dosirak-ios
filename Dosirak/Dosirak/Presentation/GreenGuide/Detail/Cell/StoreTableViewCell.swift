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
    
    private let benefitImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "reuse")
        return view
    }()
    
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
        contentView.addSubview(benefitImageView)
        
        
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
        
        statusLabel.textAlignment = .right
        
   
        benefitLabel.font = .systemFont(ofSize: 12)
        benefitLabel.textColor = .gray
    }
    
    private func setupLayout() {
        
      
        iconImageView.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview().inset(10)
            $0.width.height.equalTo(90)
        }
        benefitImageView.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(10)
            $0.top.equalToSuperview().inset(20)
            $0.width.equalTo(23)
            $0.height.equalTo(12)
        }
        
       
        benefitLabel.snp.makeConstraints {
            $0.leading.equalTo(benefitImageView.snp.trailing).offset(5)
            $0.top.equalTo(benefitImageView)
            $0.height.equalTo(12)
       
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
            $0.width.equalTo(82)
            $0.height.equalTo(32)
        }
        
    
        statusLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.centerY.equalToSuperview()
        }
    }
    
  
    func configure(store: Store, distance: Double?) {
        titleLabel.text = store.storeName
        let url = URL(string: store.storeImg)
        iconImageView.kf.setImage(with: url)
        
        if let distance = distance {
            distanceLabel.text = String(format: "%.2f km", distance)
        } else {
            distanceLabel.text = "Distance unavailable"
        }
        
        
        distanceLabel.backgroundColor = .bgColor
        distanceLabel.layer.cornerRadius = 20
        distanceLabel.textAlignment = .center

        // `benefitLabel`의 특정 텍스트를 파란색으로 설정
        let benefitText = store.ifValid
        let highlightText = "다회용기 혜택"
        
        // `NSMutableAttributedString`을 사용하여 부분 색상 변경
        let attributedText = NSMutableAttributedString(string: benefitText)
        
        // `highlightText` 부분에 파란색 적용
        if let range = benefitText.range(of: highlightText) {
            let nsRange = NSRange(range, in: benefitText)
            attributedText.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: nsRange)
        }
        
        // `benefitLabel`에 `attributedText` 설정
        benefitLabel.attributedText = attributedText
        benefitLabel.font = UIFont.systemFont(ofSize: 12)

        // 운영 상태에 따른 statusLabel 설정
        statusLabel.text = store.operating ? "운영중" : "운영종료"
        statusLabel.textColor = store.operating ? .red : .lightGray
    }
}
