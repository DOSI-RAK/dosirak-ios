//
//  ListCell.swift
//  Dosirak
//
//  Created by 권민재 on 10/31/24.
//

import UIKit
import SnapKit

class ListCell: UICollectionViewCell {
    static let identifier = "ListCell"
    
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subTitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 12
                layer.shadowColor = UIColor.black.cgColor
                layer.shadowOpacity = 0.1
                layer.shadowOffset = CGSize(width: 0, height: 4)
                layer.shadowRadius = 8
                layer.masksToBounds = false
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        
        iconImageView.snp.makeConstraints {
            $0.centerY.equalTo(self)
            $0.leading.equalTo(self).inset(20)
            $0.width.height.equalTo(28)
        }
        
        titleLabel.font = .boldSystemFont(ofSize: 14)
        titleLabel.textColor = .black
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self).inset(10)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(10)
            
        }
        subTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.trailing.equalTo(self)
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
    }
    
    func configure(icon: UIImage?, title: String,subTitle: String) {
        iconImageView.image = icon
        titleLabel.text = title
        subTitleLabel.text = subTitle
        
    }
}
