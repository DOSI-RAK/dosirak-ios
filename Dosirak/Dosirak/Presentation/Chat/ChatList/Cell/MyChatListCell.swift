//
//  MyChatListCell.swift
//  Dosirak
//
//  Created by 권민재 on 10/27/24.
//
import UIKit
import SnapKit

class MyChatListCell: UICollectionViewCell {
    // Define views as properties
    let chatImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20 // Adjust for rounded image view
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()

    let lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set the background color and corner radius
        self.contentView.backgroundColor = .mainColor // Your desired background color
        self.contentView.layer.cornerRadius = 20 // Adjust for capsule shape
        self.contentView.clipsToBounds = true // Ensures the corners are clipped
        
        // Add subviews to content view
        contentView.addSubview(chatImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(lastMessageLabel)

        // Set up constraints
        chatImageView.snp.makeConstraints { make in
            make.width.height.equalTo(40) // Set the image size
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(10)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.equalTo(chatImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(10)
        }

        lastMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(chatImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(10)
        }

        // Ensures the cell itself has rounded corners
        self.layer.cornerRadius = 20 // Adjust for capsule shape
        self.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
