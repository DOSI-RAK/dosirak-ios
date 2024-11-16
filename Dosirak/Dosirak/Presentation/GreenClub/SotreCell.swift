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
        label.textColor = .black
        label.text = "가게 이름"
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let discountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .red
        label.textAlignment = .center
        label.text = "20%"
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        label.text = "최대 할인률\n20%"
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "500m"
        let iconAttachment = NSTextAttachment()
        iconAttachment.image = UIImage(systemName: "figure.walk.circle")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        iconAttachment.bounds = CGRect(x: 0, y: -3, width: 16, height: 16)
        let attributedText = NSMutableAttributedString(attachment: iconAttachment)
        attributedText.append(NSAttributedString(string: " 500m"))
        label.attributedText = attributedText
        return label
    }()
    
    private let discountTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemBlue
        label.text = "할인 시간 00:00 - 00:00"
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
            make.trailing.equalTo(discountLabel.snp.leading).offset(-16)
            make.top.equalToSuperview().offset(8)
        }
        
        discountTimeLabel.snp.makeConstraints { make in
            make.leading.equalTo(storeNameLabel)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
            make.top.equalTo(storeNameLabel.snp.bottom).offset(4)
        }
        
        distanceLabel.snp.makeConstraints { make in
            make.leading.equalTo(storeNameLabel)
            make.top.equalTo(discountTimeLabel.snp.bottom).offset(4)
        }
        
        discountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(50)
        }
    }
    
    func configure(with item: SaleStore) {
        storeNameLabel.text = item.saleStoreName
        discountLabel.text = "최대 할인률\n\(item.saleDiscount)%"
        discountTimeLabel.text = "할인 시간 \(item.saleOperationTime)"
        distanceLabel.text = "\(item.distance ?? 0)m"
        
        // 아이콘과 텍스트가 결합된 거리 표시
        let iconAttachment = NSTextAttachment()
        iconAttachment.image = UIImage(systemName: "figure.walk.circle")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        iconAttachment.bounds = CGRect(x: 0, y: -3, width: 16, height: 16)
        let attributedText = NSMutableAttributedString(attachment: iconAttachment)
        attributedText.append(NSAttributedString(string: " \(item.distance ?? 0)m"))
        distanceLabel.attributedText = attributedText
        
        // 이미지 로드
        storeImageView.kf.setImage(with: URL(string: item.saleStoreImg), placeholder: UIImage(named: "placeholder"))
    }
}
