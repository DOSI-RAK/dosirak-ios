//
//  NearbyInfoHeader.swift
//  Dosirak
//
//  Created by 권민재 on 10/26/24.
//
import UIKit
import SnapKit

class NearbyInfoHeader: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    private func setupView() {
        addSubview(titleLable)
     
        
        titleLable.snp.makeConstraints {
            $0.leading.equalTo(self).inset(20)
            $0.centerY.equalTo(self)
        }
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleLable: UILabel = {
        let label = UILabel()
        label.text = "내 주변"
        //label.textAlignment = .center

        return label
    }()
}

