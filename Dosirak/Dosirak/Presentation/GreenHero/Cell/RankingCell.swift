//
//  RankingCell.swift
//  Dosirak
//
//  Created by 권민재 on 11/18/24.
//
import UIKit
import SnapKit
import Kingfisher

class RankingCell: UITableViewCell {
    static let identifier = "RankingCell"
    
    private let rankLabel = UILabel()
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let scoreLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        self.backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(rankLabel)
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(scoreLabel)
        
        // 순위 라벨
        rankLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(30) // 고정된 폭
        }
        rankLabel.font = UIFont.boldSystemFont(ofSize: 16)
        rankLabel.textColor = .black
        rankLabel.textAlignment = .center

        // 프로필 이미지
        profileImageView.snp.makeConstraints { make in
            make.leading.equalTo(rankLabel.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40) // 정사각형
        }
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill

        // 이름 라벨
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(scoreLabel.snp.leading).offset(-8)
        }
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        nameLabel.textColor = .black
        nameLabel.lineBreakMode = .byTruncatingTail // 길면 말줄임

        // 점수 라벨
        scoreLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        scoreLabel.font = UIFont.systemFont(ofSize: 14)
        scoreLabel.textColor = UIColor.gray
        scoreLabel.textAlignment = .right
    }

    func configure(with rank: Rank) {
        rankLabel.text = "\(rank.rank)"
        nameLabel.text = rank.nickName
        scoreLabel.text = "\(rank.reward)점"
        profileImageView.kf.setImage(with: URL(string: rank.profileImg ?? "profile"), placeholder: UIImage(named: "placeholder"))
    }
}
