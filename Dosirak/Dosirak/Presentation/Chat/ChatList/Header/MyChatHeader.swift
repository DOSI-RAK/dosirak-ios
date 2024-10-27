//
//  MyChatHeader.swift
//  Dosirak
//
//  Created by 권민재 on 10/26/24.
//
import UIKit
import SnapKit

class MyChatHeader: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    
    }
    
    private func setupView() {
        addSubview(titleLable)
        addSubview(detailButton)
        
        titleLable.snp.makeConstraints {
            $0.leading.equalTo(self).inset(20)
            $0.centerY.equalTo(self)
        }
        detailButton.snp.makeConstraints {
            $0.trailing.equalTo(self).inset(20)
            $0.centerY.equalTo(self)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleLable: UILabel = {
        let label = UILabel()
        label.text = "내 채팅"
        //label.textAlignment = .center

        return label
    }()
    
    lazy var detailButton: UIButton = {
        let button = UIButton()
        button.setTitle("전체보기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
}

