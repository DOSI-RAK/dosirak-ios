//
//  ChatListCell.swift
//  Dosirak
//
//  Created by 권민재 on 10/27/24.
//
import UIKit
import SnapKit

class ChatListCell: UICollectionViewCell {
    let titleLabel = UILabel()
    let lastMessageLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        contentView.addSubview(lastMessageLabel)

        titleLabel.font = .boldSystemFont(ofSize: 16)
        lastMessageLabel.font = .systemFont(ofSize: 12)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(10)
        }
        lastMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(10)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
