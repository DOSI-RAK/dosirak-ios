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
        // Background ImageView 설정 (크라운 포함)
        addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.layer.cornerRadius = 12
        
        // Profile ImageView 설정
        addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(50) // 프로필 위치를 크라운 아래로 설정
            make.width.height.equalTo(48)
        }
        profileImageView.layer.cornerRadius = 24
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill

        // Name Label 설정
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
        }
        nameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        nameLabel.textAlignment = .center
        nameLabel.textColor = .white // 배경과 잘 어울리도록 흰색으로 설정

        // Score Label 설정
        addSubview(scoreLabel)
        scoreLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(8)
        }
        scoreLabel.font = UIFont.systemFont(ofSize: 12)
        scoreLabel.textAlignment = .center
        scoreLabel.textColor = .white // 배경과 잘 어울리도록 흰색으로 설정

        // Rank에 따라 배경 이미지 설정
        switch rank {
        case 1:
            backgroundImageView.image = UIImage(named: "2등") // 1등용 이미지 (크라운 포함)
        case 2:
            backgroundImageView.image = UIImage(named: "1등") // 2등용 이미지
        case 3:
            backgroundImageView.image = UIImage(named: "3등") // 3등용 이미지
        default:
            backgroundImageView.image = UIImage(named: "default_card") // 기본 카드 이미지
        }
    }

    func configure(with rank: Rank) {
        nameLabel.text = rank.nickName
        scoreLabel.text = "\(rank.reward)점"
        profileImageView.kf.setImage(with: URL(string: rank.profileImg), placeholder: UIImage(named: "profile"))
    }
}
