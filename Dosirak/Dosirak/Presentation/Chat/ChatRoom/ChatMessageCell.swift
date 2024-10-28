//
//  ChatMessageCell.swift
//  Dosirak
//
//  Created by 권민재 on 10/28/24.
//
import UIKit


class ChatMessageCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "ChatMessageCell"
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = .darkGray
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0 // 라벨이 여러 줄로 확장되도록 설정
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.backgroundColor = .lightGray.withAlphaComponent(0.2)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .lightGray
        return label
    }()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(timeLabel)
    }
    
    // MARK: - Layout Update
    func configure(with message: ChatMessage) {
        messageLabel.text = message.text
        nicknameLabel.text = message.nickname
        profileImageView.image = UIImage(named: "profile")
        timeLabel.text = message.time
        
        updateLayout(for: message.isSentByCurrentUser)
    }
    
    private func updateLayout(for isSentByCurrentUser: Bool) {
        // 기존 제약 조건 제거 후 다시 추가
        messageLabel.snp.removeConstraints()
        nicknameLabel.snp.removeConstraints()
        profileImageView.snp.removeConstraints()
        timeLabel.snp.removeConstraints()

        let padding: CGFloat = 10
        let imageSize: CGFloat = 40
        
        if isSentByCurrentUser {
            // 내 메시지인 경우 오른쪽 정렬
            profileImageView.isHidden = true
            nicknameLabel.isHidden = true
            
            messageLabel.snp.remakeConstraints { make in
                make.top.equalToSuperview().inset(padding)
                make.right.equalToSuperview().inset(padding)
                make.left.greaterThanOrEqualToSuperview().offset(80)
            }
            
            timeLabel.snp.remakeConstraints { make in
                make.top.equalTo(messageLabel.snp.bottom).offset(4)
                make.right.equalTo(messageLabel.snp.right)
                make.bottom.equalToSuperview().inset(padding)
            }
        } else {
            // 상대방의 메시지인 경우 왼쪽 정렬
            profileImageView.isHidden = false
            nicknameLabel.isHidden = false
            
            profileImageView.snp.remakeConstraints { make in
                make.left.equalToSuperview().inset(padding)
                make.top.equalToSuperview().inset(padding)
                make.width.height.equalTo(imageSize)
            }
            
            nicknameLabel.snp.remakeConstraints { make in
                make.left.equalTo(profileImageView.snp.right).offset(8)
                make.top.equalTo(profileImageView)
                make.right.lessThanOrEqualToSuperview().offset(-padding)
            }
            
            messageLabel.snp.remakeConstraints { make in
                make.top.equalTo(nicknameLabel.snp.bottom).offset(4)
                make.left.equalTo(profileImageView.snp.right).offset(8)
                make.right.lessThanOrEqualToSuperview().inset(padding)
            }
            
            timeLabel.snp.remakeConstraints { make in
                make.top.equalTo(messageLabel.snp.bottom).offset(4)
                make.left.equalTo(messageLabel)
                make.bottom.equalToSuperview().inset(padding)
            }
        }
    }
}
