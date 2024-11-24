//
//  CommitCell.swift
//  Dosirak
//
//  Created by 권민재 on 11/5/24.
//

import UIKit
import SnapKit
import Kingfisher

class GreenCommitCell: UICollectionViewCell {
    
    
    // MARK: - UI Components
    private let activityImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.text = "12시 41분"
        return label
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        setupView()
        setupShadow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Views
    private func setupView() {
        addSubview(activityImageView)
        addSubview(titleLabel)
        addSubview(dateLabel)
        
        activityImageView.snp.makeConstraints {
            $0.leading.equalTo(self).inset(10)
            $0.centerY.equalTo(self)
            $0.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(activityImageView.snp.trailing).offset(10)
            $0.centerY.equalTo(self)
        }
        
        dateLabel.snp.makeConstraints {
            $0.trailing.equalTo(self.snp.trailing).inset(20)
            $0.centerY.equalTo(self)
        }
    }
    private func setupShadow() {
        self.layer.cornerRadius = 8 // 셀의 모서리를 둥글게 설정
        self.layer.masksToBounds = false // 그림자가 잘리지 않도록 설정
        self.layer.shadowColor = UIColor.black.cgColor // 그림자 색상
        self.layer.shadowOpacity = 0.1 // 그림자 투명도
        self.layer.shadowRadius = 4 // 그림자 퍼짐 정도
        self.layer.shadowOffset = CGSize(width: 0, height: 2) // 그림자의 위치
    }
    
    // MARK: - Configure Cell
    func configure(commit: CommitActivity) {
        titleLabel.text = commit.activityMessage
        activityImageView.kf.setImage(with: URL(string: commit.iconImageUrl))
        dateLabel.text = commit.createAtTime
    }
}
