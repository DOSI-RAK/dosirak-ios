//
//  CommitCell.swift
//  Dosirak
//
//  Created by 권민재 on 11/5/24.
//

import UIKit
import SnapKit

class GreenCommitCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupView() {
        addSubview(activityImageView)
        addSubview(titleLabel)
        addSubview(dateLabel)
        
        activityImageView.snp.makeConstraints {
            $0.leading.equalTo(self).inset(20)
            $0.width.height.equalTo(20)
            $0.top.equalTo(self).inset(20)
        }
    }
    
    
    
    //MARK: UI
    let activityImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "footprint")
        return imageView
    }()
    let titleLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        return label
    }()
}
