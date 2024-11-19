//
//  ChatMessageCell.swift
//  Dosirak
//
//  Created by 권민재 on 10/28/24.
//
import UIKit
import SnapKit
import Kingfisher

class ChatMessageCell: UITableViewCell {
    static let identifier = "ChatMessageCell"
    
    private let messageBubble: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20 // 원형 이미지
        return imageView
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .darkGray
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .darkGray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.addSubview(profileImageView)
        contentView.addSubview(messageBubble)
        messageBubble.addSubview(messageLabel)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(timeLabel)
    }
    
    func configure(with message: Message) {
        
        
        
        if message.messageType == .chat {
            messageLabel.text = message.content
            let imageURL = URL(string: message.userChatRoomResponse.profileImg)
            profileImageView.kf.setImage(with: imageURL)
            nicknameLabel.text = message.userChatRoomResponse.nickName
            timeLabel.text = Date.formattedDateString(from: message.createdAt)
            
            print("nickName ==========\(UserInfo.nickName)")
            
            if message.userChatRoomResponse.nickName == UserInfo.nickName {
               
                messageBubble.backgroundColor = .white
                messageLabel.textColor = .black
                
                profileImageView.snp.remakeConstraints { make in
                    make.top.equalToSuperview().offset(10)
                    make.trailing.equalToSuperview().inset(10)
                    make.width.height.equalTo(40)
                }
                
                messageBubble.snp.remakeConstraints { make in
                    make.top.equalToSuperview().offset(10)
                    make.trailing.equalTo(profileImageView.snp.leading).offset(-10)
                    make.width.lessThanOrEqualTo(250)
                    make.bottom.equalToSuperview().offset(-10)
                }
                
                messageLabel.snp.remakeConstraints { make in
                    make.edges.equalTo(messageBubble).inset(10)
                }
                nicknameLabel.snp.remakeConstraints { make in
                    make.top.equalToSuperview().offset(10)
                    make.leading.equalTo(profileImageView.snp.trailing).offset(10)
                    make.trailing.lessThanOrEqualToSuperview().offset(-10)
                }
                
                timeLabel.snp.remakeConstraints { make in
                    make.bottom.equalTo(messageBubble)
                    make.trailing.equalTo(messageBubble.snp.leading).offset(-5)
                }
                
            } else {
                messageBubble.backgroundColor = .white
                messageLabel.textColor = .black
                
                profileImageView.snp.remakeConstraints { make in
                    make.top.equalToSuperview().offset(10)
                    make.leading.equalToSuperview().offset(10)
                    make.width.height.equalTo(40)
                }
                
                nicknameLabel.snp.remakeConstraints { make in
                    make.top.equalToSuperview().offset(10)
                    make.leading.equalTo(profileImageView.snp.trailing).offset(10)
                    make.trailing.lessThanOrEqualToSuperview().offset(-10)
                }
                
                messageBubble.snp.remakeConstraints { make in
                    make.top.equalTo(nicknameLabel.snp.bottom).offset(4)
                    make.leading.equalTo(profileImageView.snp.trailing).offset(10)
                    make.width.lessThanOrEqualTo(250)
                    make.bottom.equalToSuperview().offset(-10)
                }
                
                messageLabel.snp.remakeConstraints { make in
                    make.edges.equalTo(messageBubble).inset(10)
                }
                
                timeLabel.snp.remakeConstraints { make in
                    make.bottom.equalTo(messageBubble)
                    make.leading.equalTo(messageBubble.snp.trailing).offset(5)
                    make.trailing.lessThanOrEqualToSuperview().offset(-10)
                }
            }
        } else {
            print("Hello World!")
        }
    }
}
