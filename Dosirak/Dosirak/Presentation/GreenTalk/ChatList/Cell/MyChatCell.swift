//
//  MyChatCell.swift
//  Dosirak
//
//  Created by 권민재 on 10/29/24.
//
import UIKit
import SnapKit

class MyChatCell: UICollectionViewCell {
    
    var chatRoomId: Int? 

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 25 // 둥근 모서리 적용
        imageView.clipsToBounds = true
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)

        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(self.contentView).inset(10)
            make.top.equalToSuperview().offset(5)
            make.width.height.equalTo(32)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
        }

        // 배경 및 스타일 설정
        contentView.backgroundColor = .mainColor
        contentView.layer.cornerRadius = 20
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
