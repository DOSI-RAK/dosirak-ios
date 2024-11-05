//
//  CommitCell.swift
//  Dosirak
//
//  Created by 권민재 on 11/5/24.
//

import UIKit
import SnapKit

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
        label.text = "12시 41분" // 기본 시간 텍스트
        return label
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
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
            $0.leading.equalTo(self).inset(20)
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
    
    // MARK: - Configure Cell
    func configure(title: String, imageName: String) {
        titleLabel.text = title
        activityImageView.image = UIImage(named: imageName)
    }
}
