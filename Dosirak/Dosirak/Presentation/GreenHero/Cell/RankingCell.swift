//
//  RankingCell.swift
//  Dosirak
//
//  Created by 권민재 on 11/18/24.
//
import UIKit
class RankingCell: UICollectionViewCell {
    static let identifier = "RankingCell"

    private let rankLabel = UILabel()
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let scoreLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(rankLabel)
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(scoreLabel)

        rankLabel.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
        }

        profileImageView.snp.makeConstraints {
            $0.leading.equalTo(rankLabel.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(40)
        }

        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
        }

        scoreLabel.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
        }
    }

    func configure(with rank: Rank) {
        rankLabel.text = "\(rank.rank)"
        nameLabel.text = rank.nickName
        scoreLabel.text = "\(rank.reward)점"
        profileImageView.kf.setImage(with: URL(string: rank.profileImg), placeholder: UIImage(named: "placeholder"))
    }
}
