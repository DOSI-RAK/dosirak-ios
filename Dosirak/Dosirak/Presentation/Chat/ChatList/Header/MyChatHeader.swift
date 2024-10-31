//
//  MyChatHeader.swift
//  Dosirak
//
//  Created by 권민재 on 10/26/24.
//



import UIKit
import SnapKit

class MyChatHeaderView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "내 채팅"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        return label
    }()

    public let viewAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("전체보기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.tintColor = .black
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(viewAllButton)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }

        viewAllButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
    }
}

