//
//  NearbyInfoCell.swift
//  Dosirak
//
//  Created by 권민재 on 10/27/24.
//
import UIKit
import SnapKit

class NearbyInfoCell: UICollectionViewCell {
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        titleLabel.text = "동작구 상도동"
        
        titleLabel.font = .systemFont(ofSize: 19,weight: .bold)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self).inset(20)
            $0.leading.equalTo(self).inset(20)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
