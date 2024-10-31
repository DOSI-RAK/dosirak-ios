//
//  ChatMessageCell.swift
//  Dosirak
//
//  Created by 권민재 on 10/28/24.
//
import UIKit
import SnapKit

class ChatMessageCell: UITableViewCell {
    static let identifier = "ChatMessageCell"
    
    private let messageBubble: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 15
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
        imageView.layer.cornerRadius = 20 // Make profile image circular
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
        self.backgroundColor = .clear
        contentView.addSubview(profileImageView)
        contentView.addSubview(messageBubble)
        messageBubble.addSubview(messageLabel)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(timeLabel)
        
        // Auto Layout configuration
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
            make.width.height.equalTo(40)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10) // Cell의 최상단에 위치
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
            make.trailing.lessThanOrEqualToSuperview().offset(-10)
        }
        
        messageBubble.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(4) // 닉네임 바로 아래
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
            make.width.lessThanOrEqualTo(200) // 최대 너비 설정
            make.bottom.equalToSuperview().offset(-10)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.edges.equalTo(messageBubble).inset(10)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(messageBubble) // 메시지 버블의 수직 중심에 정렬
            make.leading.equalTo(messageBubble.snp.trailing).offset(5) // 메시지 버블의 오른쪽
            make.trailing.lessThanOrEqualToSuperview().offset(-10)
        }
    }
    
    func configure(with message: ChatMessage) {
        messageLabel.text = message.text
        profileImageView.image = UIImage(named: message.profileImageName)
        nicknameLabel.text = message.nickname
        timeLabel.text = message.time
        messageBubble.backgroundColor = message.isSentByCurrentUser ? .systemBlue : .white
        messageLabel.textColor = message.isSentByCurrentUser ? .white : .black
    }
}
