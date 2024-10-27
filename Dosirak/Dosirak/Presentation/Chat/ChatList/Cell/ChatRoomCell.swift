//
//  ChatRoomCell.swift
//  Dosirak
//
//  Created by 권민재 on 10/27/24.
//
import UIKit
import SnapKit

class ChatRoomCell: UICollectionViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        return view
    }()
    
    private let iconLabel: UILabel = {
        let label = UILabel()
        label.text = "🌲"
        label.font = .systemFont(ofSize: 30)
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let memberCountView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let memberIcon: UILabel = {
        let label = UILabel()
        label.text = "👤"
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    private let memberCountLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    func configure(title: String, message: String, memberCount: Int) {
        titleLabel.text = title
        messageLabel.text = message
        memberCountLabel.text = "\(memberCount)"
    }
}
