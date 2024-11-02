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
        messageLabel.text = message.content
        let imageURL = URL(string: message.userChatRoomResponse.profileImg)
        profileImageView.kf.setImage(with: imageURL)
        nicknameLabel.text = message.userChatRoomResponse.nickName
        timeLabel.text = message.createdAt

        if message.userChatRoomResponse.nickName == "Test" {
            // 내가 보낸 메시지: 오른쪽 정렬
            messageBubble.backgroundColor = .systemBlue
            messageLabel.textColor = .white
            profileImageView.isHidden = true
            nicknameLabel.isHidden = true
            
            // 오른쪽 정렬 레이아웃 설정
            messageBubble.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(10)
                make.trailing.equalToSuperview().offset(-10)
                make.width.lessThanOrEqualTo(250)
                make.bottom.equalToSuperview().offset(-10)
            }
            
            messageLabel.snp.remakeConstraints { make in
                make.edges.equalTo(messageBubble).inset(10)
            }
            
            timeLabel.snp.remakeConstraints { make in
                make.bottom.equalTo(messageBubble)
                make.trailing.equalTo(messageBubble.snp.leading).offset(-5)
            }
            
        } else {
            // 상대방이 보낸 메시지: 왼쪽 정렬
            messageBubble.backgroundColor = .white
            messageLabel.textColor = .black
            profileImageView.isHidden = false
            nicknameLabel.isHidden = false
            
            // 왼쪽 정렬 레이아웃 설정
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
    }
}
