//
//  MyChatCell.swift
//  Dosirak
//
//  Created by 권민재 on 10/27/24.
//
import UIKit
import SnapKit
// MARK: - Custom Cells
class MyChatCell: UICollectionViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainColor
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let iconLabel: UILabel = {
        let label = UILabel()
        label.text = "🌲"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconLabel)
        containerView.addSubview(titleLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconLabel.snp.trailing).offset(4)
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}
