//
//  MyChatListTableViewCell.swift
//  Dosirak
//
//  Created by 권민재 on 10/30/24.
//

import UIKit
import SnapKit

class MyChatListTableViewCell: UITableViewCell {
    
    let chatImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 13 // Adjust for rounded image view
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }()

    let lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 2
        label.textColor = .gray
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.textAlignment = .center // Align to the right
        return label
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray // 라이트 그레이 색상
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // 셀의 contentView에 서브뷰를 추가합니다.
        contentView.addSubview(chatImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(lastMessageLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(separatorView) // 구분선 추가

        // Auto Layout 설정
        chatImageView.snp.makeConstraints { make in
            make.width.height.equalTo(58) // Set the image size
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(10)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.equalTo(chatImageView.snp.trailing).offset(10)
            make.trailing.equalTo(dateLabel.snp.leading).offset(-10)
        }

        lastMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(chatImageView.snp.trailing).offset(10)
            make.trailing.equalTo(dateLabel.snp.leading).offset(-10)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(10)
            make.width.equalTo(60) // Adjust as needed
        }
        
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(0.8) // 구분선 높이
            make.leading.trailing.equalToSuperview().inset(20) // 양쪽 가장자리 맞춤
            make.bottom.equalToSuperview() // 셀 하단에 맞춤
        }
    }
}
