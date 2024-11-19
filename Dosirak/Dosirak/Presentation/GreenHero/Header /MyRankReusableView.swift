//
//  MyRankReusableView.swift``
//  Dosirak
//
//  Created by 권민재 on 11/18/24.
//
import UIKit
import Kingfisher
import SnapKit

class MyRankReusableView: UICollectionReusableView {
    static let identifier = "MyRankReusableView"
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor(hexCode: "#F7F8FA")
        
        addSubview(내등수라벨)
        addSubview(dateLabel)
        addSubview(myRankView)
        
        // 내 등수와 날짜 레이아웃
        내등수라벨.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(16)
        }
        
        dateLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalTo(내등수라벨)
        }
        
        // 내 등수 상세 뷰 레이아웃
        myRankView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(내등수라벨.snp.bottom).offset(10)
            $0.height.equalTo(60)
        }
        
        myRankView.addSubview(rankLabel)
        myRankView.addSubview(profileImageView)
        myRankView.addSubview(nameLabel)
        myRankView.addSubview(scoreLabel)
        
        rankLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(30)
        }

        profileImageView.snp.makeConstraints { make in
            make.leading.equalTo(rankLabel.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(scoreLabel.snp.leading).offset(-8)
        }

        scoreLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }

    func configure(with rank: Rank) {
        rankLabel.text = "\(rank.rank)"
        nameLabel.text = rank.nickName
        profileImageView.kf.setImage(with: URL(string: rank.profileImg ?? ""), placeholder: UIImage(named: "placeholder"))
        scoreLabel.text = "\(rank.reward)점"
        
        // 날짜 설정
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        dateLabel.text = "\(dateFormatter.string(from: Date())) 기준"
    }
    
    // 내 등수 라벨
    private let 내등수라벨: UILabel = {
        let label = UILabel()
        label.text = "내 등수"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    // 날짜 라벨
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.gray
        return label
    }()
    
    // 내 등수 상세 뷰
    private let myRankView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()

    // 등수 라벨
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()
    
    // 프로필 이미지 뷰
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    // 이름 라벨
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    // 점수 라벨
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(hexCode: "#006ae6")
        label.textAlignment = .right
        return label
    }()
}
