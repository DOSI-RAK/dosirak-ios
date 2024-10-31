//
//  DoubleGridCell.swift
//  Dosirak
//
//  Created by 권민재 on 10/31/24.
//
import UIKit
import SnapKit

class DoubleGridCell: UICollectionViewCell {
    static let identifier = "DoubleGridCell"
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textColor = .white
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self).inset(20)
            make.top.equalTo(self).inset(20)
        }
        titleLabel.numberOfLines = 2
        
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.textColor = .black
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
        }
        subtitleLabel.numberOfLines = 2
    }
    
    func configure(image: UIImage?, title: String, subtitle: String) {
        imageView.image = image
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
