//
//  RankCardView.swift
//  Dosirak
//
//  Created by 권민재 on 11/18/24.
//
import UIKit
import SnapKit
import Kingfisher

class RankCardView: UIView {
    private let backgroundImageView = UIImageView()
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let scoreLabel = UILabel()

    init(rank: Int) {
        super.init(frame: .zero)
        setupUI(rank: rank)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(rank: Int) {
        addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        backgroundImageView.layer.cornerRadius = 12
        backgroundImageView.clipsToBounds = true

        // 프로필 이미지
        addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.width.height.equalTo(48)
        }
        profileImageView.layer.cornerRadius = 24
        profileImageView.clipsToBounds = true

        // 이름
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        nameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        nameLabel.textColor = .black
        nameLabel.textAlignment = .center

        // 점수
        addSubview(scoreLabel)
        scoreLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        scoreLabel.font = UIFont.systemFont(ofSize: 12)
        scoreLabel.textColor = .gray

        // 순위별 배경 설정
        switch rank {
        case 1:
            backgroundImageView.image = UIImage(named: "1등")
        case 2:
            backgroundImageView.image = UIImage(named: "2등")
        case 3:
            backgroundImageView.image = UIImage(named: "3등")
        default:
            backgroundImageView.image = nil
        }
    }

    func configure(with rank: Rank) {
        nameLabel.text = rank.nickName
        scoreLabel.text = "\(rank.reward)점"
        profileImageView.kf.setImage(with: URL(string: rank.profileImg ?? "profile"), placeholder: UIImage(named: "placeholder"))
    }
}
