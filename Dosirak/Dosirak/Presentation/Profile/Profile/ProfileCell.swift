//
//  ProfileCell.swift
//  Dosirak
//
//  Created by 권민재 on 10/24/24.
//

import UIKit
import SnapKit

class ProfileCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: ProfileCell.reusableIdentifier)
        contentView.addSubview(imgView)
        contentView.addSubview(label)
        
        imgView.snp.makeConstraints {
            $0.leading.equalTo(contentView).inset(20)
            $0.width.height.equalTo(23)
            $0.centerY.equalTo(contentView)
        }
        label.snp.makeConstraints {
            $0.leading.equalTo(imgView.snp.trailing).offset(30)
            $0.trailing.equalTo(contentView)
            $0.centerY.equalTo(contentView)
        }
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let imgView = UIImageView()
    let label = UILabel()
}
