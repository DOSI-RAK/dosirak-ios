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
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .gray
        label.textAlignment = .center
        label.clipsToBounds = true
        label.backgroundColor = .white
        label.text = "최대 할인률"
        label.numberOfLines = 2
        return label
    }()
    private let percentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "500m"
        let iconAttachment = NSTextAttachment()
        iconAttachment.bounds = CGRect(x: 2, y: -3, width: 16, height: 16)
        let attributedText = NSMutableAttributedString(attachment: iconAttachment)
        attributedText.append(NSAttributedString(string: " 500m"))
        label.attributedText = attributedText
        label.backgroundColor = .white
        label.layer.cornerRadius = 13
        label.textAlignment = .center
        return label
    }()
    
    private let discountTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemBlue
        label.text = "할인 시간 00:00 - 00:00"
        return label
    }()
    
    let baseView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 14
        return view
    }()
    
    
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .bgColor
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(storeImageView)
        contentView.addSubview(storeNameLabel)
        contentView.addSubview(distanceLabel)
        contentView.addSubview(discountTimeLabel)
        contentView.addSubview(baseView)
        baseView.addSubview(discountLabel)
        baseView.addSubview(percentLabel)
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
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        
         baseView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(80)
        }
        
        discountLabel.snp.makeConstraints {
            $0.top.equalTo(baseView.snp.top).offset(20)
            $0.leading.trailing.equalTo(baseView)
            
        }
        percentLabel.snp.makeConstraints {
            $0.centerX.equalTo(baseView)
            $0.top.equalTo(discountLabel.snp.bottom).offset(5)
        }
    }
    
    func configure(with item: SaleStore) {
        storeNameLabel.text = item.saleStoreName
        discountTimeLabel.text = "할인 시간 \(item.saleOperationTime)"
        distanceLabel.text = "\(item.distance ?? 0)m"
        percentLabel.text = item.saleDiscount + "%"
        
        // 아이콘과 텍스트가 결합된 거리 표시
        let attributedText = NSMutableAttributedString(string: "\(item.distance ?? 0)m ")

        // 아이콘 Attachment 생성
        let iconAttachment = NSTextAttachment()
        iconAttachment.image = UIImage(named: "footprint")
        iconAttachment.bounds = CGRect(x: 0, y: -3, width: 16, height: 16)

        // 아이콘을 텍스트 뒤에 추가
        attributedText.append(NSAttributedString(attachment: iconAttachment))

        // 설정된 Attributed Text를 UILabel에 적용
        distanceLabel.attributedText = attributedText
        
        // 이미지 로드
        storeImageView.kf.setImage(with: URL(string: item.saleStoreImg), placeholder: UIImage(named: "placeholder"))
    }
}
