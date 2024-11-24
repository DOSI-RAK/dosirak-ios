//
//  EmptyCell.swift
//  Dosirak
//
//  Created by 권민재 on 11/24/24.
//

import UIKit
import SnapKit

class EmptyCell: UICollectionViewCell {
    
    static let identifier = "EmptyCell"

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "이날은 기록이 아직 없어요"
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        addSubview(messageLabel)
        messageLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self).inset(20)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
